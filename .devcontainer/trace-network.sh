#!/bin/bash
# eBPF network connection tracer for Claude Code devcontainer
#
# Uses bpftrace kprobes on tcp_v4_connect / tcp_v6_connect to trace outbound
# TCP connections. Filtered by cgroup to capture only this container's traffic.
# Resolves destination IPs to hostnames via reverse DNS (cached).
#
# Log format (pipe-delimited):
#   timestamp|hostname|ip|port|protocol|pid|command
#
# Usage:
#   trace-network.sh               Start tracer daemon
#   trace-network.sh --status      Check tracer status
#   trace-network.sh --stop        Stop tracer daemon
#   trace-network.sh --log [N]     Show last N entries (default: 50)
#   trace-network.sh --tail        Follow log in real-time

set -euo pipefail

FOLDER_NAME="$(basename "${DEVCONTAINER_HOST_PATH:-.}")"
LOG_DIR="/home/ubuntu/.claude/networklogs/${FOLDER_NAME}"
LOG_FILE="${LOG_DIR}/$(date '+%Y%m%d-%H%M')-$(hostname).log"
PID_FILE="/var/run/network-trace.pid"

ensure_tracefs() {
    if ! mountpoint -q /sys/kernel/debug 2>/dev/null; then
        mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null || true
    fi
}

start_daemon() {
    if ! command -v bpftrace &>/dev/null; then
        echo "ERROR: bpftrace not found" >&2
        exit 1
    fi

    ensure_tracefs
    ulimit -l unlimited 2>/dev/null || true

    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
        stop_tracer quiet
    fi

    mkdir -p "$LOG_DIR"
    chmod 755 "$LOG_DIR"
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
    echo "# trace started $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"

    (
        declare -A dns_cache

        resolve() {
            local ip=$1
            if [[ -z "${dns_cache[$ip]+_}" ]]; then
                dns_cache[$ip]=$(dig +short +timeout=2 +tries=1 -x "$ip" 2>/dev/null | head -1 | sed 's/\.$//')
                [[ -z "${dns_cache[$ip]}" ]] && dns_cache[$ip]="-"
            fi
            printf '%s' "${dns_cache[$ip]}"
        }

        bpftrace -B line -e '
kprobe:tcp_v4_connect /cgroup == cgroupid("/sys/fs/cgroup")/ {
    @sk[tid] = arg0;
}
kretprobe:tcp_v4_connect /@sk[tid]/ {
    $sk = (struct sock *)@sk[tid];
    $dport = ($sk->__sk_common.skc_dport >> 8) |
             (($sk->__sk_common.skc_dport & 0xff) << 8);
    printf("%s|%s|%d|tcp|%d|%s\n",
        strftime("%Y-%m-%d %H:%M:%S", nsecs),
        ntop($sk->__sk_common.skc_daddr),
        $dport, pid, comm);
    delete(@sk[tid]);
}
kprobe:tcp_v6_connect /cgroup == cgroupid("/sys/fs/cgroup")/ {
    @sk6[tid] = arg0;
}
kretprobe:tcp_v6_connect /@sk6[tid]/ {
    $sk = (struct sock *)@sk6[tid];
    $dport = ($sk->__sk_common.skc_dport >> 8) |
             (($sk->__sk_common.skc_dport & 0xff) << 8);
    printf("%s|%s|%d|tcp|%d|%s\n",
        strftime("%Y-%m-%d %H:%M:%S", nsecs),
        ntop(10, $sk->__sk_common.skc_v6_daddr.in6_u.u6_addr8),
        $dport, pid, comm);
    delete(@sk6[tid]);
}
END { clear(@sk); clear(@sk6); }
' 2>> "$LOG_FILE" | while IFS='|' read -r ts ip port proto pid_num comm; do
            [[ "$ts" =~ ^[0-9]{4}- ]] || continue
            host=$(resolve "$ip")
            echo "${ts}|${host}|${ip}|${port}|${proto}|${pid_num}|${comm}"
        done >> "$LOG_FILE"
    ) &

    local daemon_pid=$!
    echo "$daemon_pid" > "$PID_FILE"
    chmod 644 "$PID_FILE"

    sleep 2
    if ! kill -0 "$daemon_pid" 2>/dev/null; then
        echo "WARNING: Tracer failed to start. See $LOG_FILE for details." >&2
        rm -f "$PID_FILE"
        return 0
    fi

    echo "eBPF tracer started (PID: $daemon_pid, log: $LOG_FILE)"
}

stop_tracer() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null) || true
        if [ -n "$pid" ]; then
            local pgid
            pgid=$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ') || true
            if [ -n "$pgid" ] && [ "$pgid" != "0" ]; then
                kill -- -"$pgid" 2>/dev/null || true
            else
                kill "$pid" 2>/dev/null || true
            fi
        fi
        rm -f "$PID_FILE"
        [ "${1:-}" != "quiet" ] && echo "Tracer stopped"
    else
        [ "${1:-}" != "quiet" ] && echo "No tracer running"
    fi
}

show_status() {
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
        echo "Tracer running (PID: $(cat "$PID_FILE"))"
        local count
        count=$(grep -cE '^[0-9]{4}-' "$LOG_FILE" 2>/dev/null || echo 0)
        echo "Log entries: $count"
        echo "Log file: $LOG_FILE"
    else
        echo "Tracer not running"
    fi
}

show_log() {
    local n=${1:-50}
    if [ ! -f "$LOG_FILE" ]; then
        echo "No log file found"
        return
    fi
    printf "%-19s  %-40s  %-15s  %5s  %-4s  %-6s  %s\n" \
        "TIMESTAMP" "HOST" "IP" "PORT" "PROTO" "PID" "COMMAND"
    printf '%0.s-' {1..110}
    echo
    grep -E '^[0-9]{4}-' "$LOG_FILE" | tail -n "$n" | \
        while IFS='|' read -r ts host ip port proto pid_num comm; do
            printf "%-19s  %-40s  %-15s  %5s  %-4s  %-6s  %s\n" \
                "$ts" "$host" "$ip" "$port" "$proto" "$pid_num" "$comm"
        done
}

tail_log() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "No log file found"
        exit 1
    fi
    printf "%-19s  %-40s  %-15s  %5s  %-4s  %-6s  %s\n" \
        "TIMESTAMP" "HOST" "IP" "PORT" "PROTO" "PID" "COMMAND"
    printf '%0.s-' {1..110}
    echo
    tail -n 0 -f "$LOG_FILE" | while IFS='|' read -r ts host ip port proto pid_num comm; do
        if [[ "$ts" =~ ^[0-9]{4}- ]]; then
            printf "%-19s  %-40s  %-15s  %5s  %-4s  %-6s  %s\n" \
                "$ts" "$host" "$ip" "$port" "$proto" "$pid_num" "$comm"
        else
            echo "$ts"
        fi
    done
}

case "${1:-}" in
    --status) show_status ;;
    --stop)   stop_tracer ;;
    --log)    show_log "${2:-50}" ;;
    --tail)   tail_log ;;
    *)        start_daemon ;;
esac
