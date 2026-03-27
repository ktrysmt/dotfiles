#!/bin/bash
# eBPF network connection tracer for Claude Code devcontainer
#
# Uses bpftrace kprobes on tcp_v4_connect / tcp_v6_connect to trace outbound
# TCP connections. Filtered by cgroup to capture only this container's traffic.
# Resolves IPs to hostnames via forward DNS snooping (getaddrinfo uprobe).
#
# Log format (pipe-delimited):
#   timestamp|host|ip|port|protocol|command
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

    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
        stop_tracer quiet
    fi

    mkdir -p "$LOG_DIR"
    chmod 755 "$LOG_DIR"
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
    echo "# trace started $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"

    # Resolve libc path for getaddrinfo uprobe
    local libc
    libc=$(ldconfig -p 2>/dev/null | grep -oP '/\S+/libc\.so\.6' | head -1)
    if [ -z "$libc" ]; then
        libc="/lib/x86_64-linux-gnu/libc.so.6"
    fi

    (
        bpftrace -B line -e "
/*
 * Forward DNS snooping: capture hostname from getaddrinfo(node, ...) calls.
 * The hostname is saved per-tid and associated with the next tcp connect.
 */
uprobe:${libc}:getaddrinfo /cgroup == cgroupid(\"/sys/fs/cgroup\")/ {
    \$name = str(arg0);
    if (\$name != \"0\") {
        @dns[tid] = \$name;
    }
}

kprobe:tcp_v4_connect /cgroup == cgroupid(\"/sys/fs/cgroup\")/ {
    @sk[tid] = arg0;
    if (@dns[tid] != \"\") {
        @host[tid] = @dns[tid];
    }
    delete(@dns[tid]);
}
kretprobe:tcp_v4_connect /@sk[tid]/ {
    \$sk = (struct sock *)@sk[tid];
    \$dport = (\$sk->__sk_common.skc_dport >> 8) |
             ((\$sk->__sk_common.skc_dport & 0xff) << 8);
    \$host = @host[tid];
    printf(\"%s|%s|%s|%d|tcp|%s\n\",
        strftime(\"%Y-%m-%d %H:%M:%S\", nsecs),
        \$host,
        ntop(\$sk->__sk_common.skc_daddr),
        \$dport, comm);
    delete(@sk[tid]);
    delete(@host[tid]);
}

kprobe:tcp_v6_connect /cgroup == cgroupid(\"/sys/fs/cgroup\")/ {
    @sk6[tid] = arg0;
    if (@dns[tid] != \"\") {
        @host6[tid] = @dns[tid];
    }
    delete(@dns[tid]);
}
kretprobe:tcp_v6_connect /@sk6[tid]/ {
    \$sk = (struct sock *)@sk6[tid];
    \$dport = (\$sk->__sk_common.skc_dport >> 8) |
             ((\$sk->__sk_common.skc_dport & 0xff) << 8);
    \$host = @host6[tid];
    printf(\"%s|%s|%s|%d|tcp|%s\n\",
        strftime(\"%Y-%m-%d %H:%M:%S\", nsecs),
        \$host,
        ntop(10, \$sk->__sk_common.skc_v6_daddr.in6_u.u6_addr8),
        \$dport, comm);
    delete(@sk6[tid]);
    delete(@host6[tid]);
}
END {
    clear(@dns); clear(@sk); clear(@sk6);
    clear(@host); clear(@host6);
}
" 2>> "$LOG_FILE" | while IFS='|' read -r ts host ip port proto comm; do
            [[ "$ts" =~ ^[0-9]{4}- ]] || continue
            # Clean empty host from bpftrace (prints empty string for unset map value)
            [[ -z "$host" || "$host" == " " ]] && host="-"
            echo "${ts}|${host}|${ip}|${port}|${proto}|${comm}"
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
    printf "%-19s  %-40s  %-39s  %5s  %-4s  %s\n" \
        "TIMESTAMP" "HOST" "IP" "PORT" "PROTO" "COMMAND"
    printf '%0.s-' {1..120}
    echo
    grep -E '^[0-9]{4}-' "$LOG_FILE" | tail -n "$n" | \
        while IFS='|' read -r ts host ip port proto comm; do
            printf "%-19s  %-40s  %-39s  %5s  %-4s  %s\n" \
                "$ts" "$host" "$ip" "$port" "$proto" "$comm"
        done
}

tail_log() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "No log file found"
        exit 1
    fi
    printf "%-19s  %-40s  %-39s  %5s  %-4s  %s\n" \
        "TIMESTAMP" "HOST" "IP" "PORT" "PROTO" "COMMAND"
    printf '%0.s-' {1..120}
    echo
    tail -n 0 -f "$LOG_FILE" | while IFS='|' read -r ts host ip port proto comm; do
        if [[ "$ts" =~ ^[0-9]{4}- ]]; then
            printf "%-19s  %-40s  %-39s  %5s  %-4s  %s\n" \
                "$ts" "$host" "$ip" "$port" "$proto" "$comm"
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
