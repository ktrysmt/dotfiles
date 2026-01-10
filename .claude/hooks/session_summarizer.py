#!/usr/bin/env python3
"""
Claude Code SessionEnd Hook
セッション履歴をサマライズして、日付+要約名のmarkdownファイルとして保存
"""

import json
import sys
import os
import re
import subprocess
from datetime import datetime
from pathlib import Path


def load_transcript(transcript_path: str) -> list[dict]:
    """JSONLトランスクリプトを読み込む"""
    messages = []
    if transcript_path and os.path.exists(transcript_path):
        with open(transcript_path, "r", encoding="utf-8") as f:
            for line in f:
                if line.strip():
                    try:
                        messages.append(json.loads(line))
                    except json.JSONDecodeError:
                        continue
    return messages


def extract_conversation(messages: list[dict]) -> str:
    """会話内容をテキストに変換"""
    conversation = []
    for m in messages:
        msg_type = m.get("type", "")
        if msg_type == "user":
            content = m.get("message", {}).get("content", "")
            if isinstance(content, list):
                content = " ".join(
                    str(c.get("text", "")) for c in content if isinstance(c, dict)
                )
            conversation.append(f"User: {str(content)[:500]}")
        elif msg_type == "assistant":
            content = m.get("message", {}).get("content", "")
            if isinstance(content, list):
                content = " ".join(
                    str(c.get("text", "")) for c in content if isinstance(c, dict)
                )
            conversation.append(f"Assistant: {str(content)[:300]}")
    return "\n".join(conversation[:30])  # 最初の30メッセージまで


def generate_summary_name(conversation: str) -> str:
    """claude CLIを使ってセッションの要約名を生成"""
    prompt = f"""以下の会話セッションの内容を表す簡潔な要約名を生成してください。

要件:
- 20〜60文字程度の日本語
- ファイル名として使える文字のみ
- 会話の主要なトピックや目的を反映
- 要約名のみを出力（説明や装飾不要）

会話:
{conversation[:3000]}

要約名:"""

    try:
        result = subprocess.run(
            ["claude", "-p", prompt, "--model", "haiku", "--output-format", "text"],
            capture_output=True,
            text=True,
            timeout=30,
        )

        if result.returncode == 0 and result.stdout.strip():
            return sanitize_filename(result.stdout.strip())
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        print(f"claude command error: {e}", file=sys.stderr)

    # フォールバック
    return fallback_summary_name(conversation)


def fallback_summary_name(conversation: str) -> str:
    """claudeコマンドが使えない場合のフォールバック"""
    lines = conversation.split("\n")
    for line in lines:
        if line.startswith("User:"):
            text = line[5:].strip()[:40]
            return sanitize_filename(text) or "session"
    return "session"


def sanitize_filename(name: str) -> str:
    """ファイル名として安全な文字列に変換"""
    # 改行を除去
    name = name.replace("\n", " ").replace("\r", "")
    # スペースをハイフンに
    name = name.replace(" ", "-").replace("　", "-")
    # ファイル名に使えない文字を除去
    name = re.sub(r'[<>:"/\\|?*]', "", name)
    # 連続ハイフンを1つに
    name = re.sub(r"-+", "-", name)
    # 先頭・末尾のハイフンを除去
    name = name.strip("-")
    # 長さ制限
    return name[:80] if name else "session"


def generate_markdown_summary(
    messages: list[dict], session_id: str, summary_name: str
) -> str:
    """マークダウン形式のサマリーを生成"""
    lines = [
        f"# {summary_name}",
        "",
        f"- **Session ID**: `{session_id}`",
        f"- **Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"- **Events**: {len(messages)}",
        "",
        "---",
        "",
    ]

    for m in messages:
        msg_type = m.get("type", "")
        if msg_type == "user":
            content = m.get("message", {}).get("content", "")
            if isinstance(content, list):
                content = " ".join(
                    str(c.get("text", "")) for c in content if isinstance(c, dict)
                )
            lines.append("## User")
            lines.append(f"{str(content)[:2000]}")
            lines.append("")
        elif msg_type == "assistant":
            content = m.get("message", {}).get("content", "")
            if isinstance(content, list):
                content = " ".join(
                    str(c.get("text", "")) for c in content if isinstance(c, dict)
                )
            lines.append("## Assistant")
            lines.append(f"{str(content)[:2000]}")
            lines.append("")

    return "\n".join(lines)


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error reading input: {e}", file=sys.stderr)
        sys.exit(1)

    session_id = input_data.get("session_id", "unknown")
    transcript_path = input_data.get("transcript_path", "")

    # トランスクリプト読み込み
    messages = load_transcript(transcript_path)
    if not messages:
        print("No messages in transcript, skipping")
        sys.exit(0)

    # 会話内容を抽出
    conversation = extract_conversation(messages)
    if not conversation.strip():
        print("No conversation content, skipping")
        sys.exit(0)

    # 要約名を生成
    summary_name = generate_summary_name(conversation)

    # 保存先（任意の場所に変更可能）
    summary_dir = Path.home() / ".claude/session-summaries"
    summary_dir.mkdir(parents=True, exist_ok=True)

    # ファイル名: yyyy-mm-dd-<summary-name>.md
    date_str = datetime.now().strftime("%Y-%m-%d")
    filename = f"{date_str}-{summary_name}.md"
    output_path = summary_dir / filename

    # 同名ファイルが存在する場合は連番を付加
    counter = 1
    while output_path.exists():
        filename = f"{date_str}-{summary_name}-{counter}.md"
        output_path = summary_dir / filename
        counter += 1

    # マークダウン生成と保存
    markdown = generate_markdown_summary(messages, session_id, summary_name)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(markdown)

    print(f"Saved: {output_path}")


if __name__ == "__main__":
    main()
