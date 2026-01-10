#!/usr/bin/env python3
"""
Claude Code SessionEnd Hook
セッション履歴をサマライズして、日付+要約名のmarkdownファイルとして保存
Anthropic APIを直接呼び出し（標準ライブラリのみ、SDKなし）
"""

import json
import sys
import os
import re
import subprocess
import logging
import time
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

# ログ設定
LOG_FILE = Path.home() / ".claude/hooks/session_summarizer.log"
LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
# 環境変数でDEBUGモードを有効化: DEBUG=1 で実行
LOG_LEVEL = logging.DEBUG if os.environ.get("DEBUG") else logging.INFO
logging.basicConfig(
    filename=LOG_FILE,
    level=LOG_LEVEL,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

# Anthropic API設定
ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
ANTHROPIC_MODEL = "claude-3-5-haiku-latest"


def call_anthropic_api(prompt: str, max_tokens: int = 500) -> str | None:
    """Anthropic APIを直接呼び出す（標準ライブラリのみ）"""
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        logging.error("ANTHROPIC_API_KEY not set")
        return None

    data = json.dumps(
        {
            "model": ANTHROPIC_MODEL,
            "max_tokens": max_tokens,
            "messages": [{"role": "user", "content": prompt}],
        }
    ).encode("utf-8")

    req = urllib.request.Request(
        ANTHROPIC_API_URL,
        data=data,
        headers={
            "Content-Type": "application/json",
            "x-api-key": api_key,
            "anthropic-version": "2023-06-01",
        },
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            result = json.loads(resp.read().decode("utf-8"))
            return result["content"][0]["text"]
    except urllib.error.HTTPError as e:
        logging.error(f"Anthropic API HTTP error: {e.code} {e.reason}")
        return None
    except urllib.error.URLError as e:
        logging.error(f"Anthropic API URL error: {e.reason}")
        return None
    except Exception as e:
        logging.error(f"Anthropic API error: {e}")
        return None


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


def clean_system_tags(text: str) -> str:
    """システムタグとその内容を除去"""
    tags_to_remove = [
        "system-reminder",
        "local-command-caveat",
        "env",
        "claude_background_info",
        "antml:thinking",
        "antml:function_calls",
        "function_results",
        "bash-input",
        "bash-stdout",
        "bash-stderr",
    ]

    result = text
    for tag in tags_to_remove:
        pattern = rf"<{tag}[^>]*>.*?</{tag}>"
        result = re.sub(pattern, "", result, flags=re.DOTALL | re.IGNORECASE)
        result = re.sub(rf"<{tag}[^>]*/?>", "", result, flags=re.IGNORECASE)

    # @ファイル参照を除去（.で始まる隠しディレクトリにも対応）
    result = re.sub(r"@\.?[\w./-]+(?:\.\w+)?(?:#L\d+(?:-\d+)?)?\s*", "", result)
    # #シンボル参照を除去
    result = re.sub(r"(?<!#)#([a-zA-Z_][a-zA-Z0-9_]*)\b", r"\1", result)
    # Markdown見出し記号を除去
    result = re.sub(r"^#{1,6}\s*", "", result, flags=re.MULTILINE)
    # 空行整理
    result = re.sub(r"\n{3,}", "\n\n", result)
    return result.strip()


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
            content = clean_system_tags(str(content))
            if content:
                conversation.append(f"User: {content[:500]}")
        elif msg_type == "assistant":
            content = m.get("message", {}).get("content", "")
            if isinstance(content, list):
                content = " ".join(
                    str(c.get("text", "")) for c in content if isinstance(c, dict)
                )
            content = clean_system_tags(str(content))
            if content:
                conversation.append(f"Assistant: {content[:300]}")
    return "\n".join(conversation[:30])


def is_valid_summary_name(name: str) -> bool:
    """要約名として有効かチェック"""
    if not name or len(name) < 5:
        return False
    if re.search(r"[/\\@]", name):
        return False
    if re.search(r"\.\w{1,4}$", name):
        return False
    if re.match(r"^[\d\-]+$", name):
        return False
    return True


def generate_summary_name(conversation: str) -> str:
    """Anthropic APIを使ってセッションの要約名を生成"""
    prompt = f"""以下の会話セッションの内容を表す簡潔な要約名を生成してください。

要件:
- 20〜60文字程度の日本語
- ファイル名として使える文字のみ（/や@は使わない）
- 会話の主要なトピックや目的を反映
- 要約名のみを出力（説明や装飾不要）
- ファイルパスは要約名にしないでください

会話:
{conversation}

要約名:"""

    result = call_anthropic_api(prompt, max_tokens=100)

    if result:
        logging.debug(f"Haiku name result: {result}")
        lines = [line.strip() for line in result.split("\n") if line.strip()]
        for line in lines:
            sanitized = sanitize_filename(line)
            if is_valid_summary_name(sanitized):
                logging.info(f"Valid summary name found: {sanitized}")
                return sanitized

        if lines:
            sanitized = sanitize_filename(lines[0])
            if sanitized and len(sanitized) >= 3:
                logging.info(f"Using first line as summary name: {sanitized}")
                return sanitized

    logging.warning("No valid summary name from API, using fallback")
    fallback = fallback_summary_name(conversation)
    logging.info(f"Fallback summary name: {fallback}")
    return fallback


def generate_summary_content(conversation: str) -> str:
    """Anthropic APIで会話の要約を生成"""
    prompt = f"""以下の会話セッションを要約してください。

要件:
- フォーマットは箇条書き、テーブル表記などを組み合わせわかりやすく
- 何を議論/作業したかを記録
- 主要な決定事項や成果物
- 未解決の課題があれば記載
- 最低でも100文字以上の要約を生成

会話:
{conversation}

要約:"""

    result = call_anthropic_api(prompt, max_tokens=1000)

    if result and len(result) >= 50:
        logging.info(f"Summary generated: {len(result)} chars")
        return result

    logging.warning("API summary failed or too short, using fallback")
    return generate_fallback_summary(conversation)


def generate_fallback_summary(conversation: str) -> str:
    """フォールバック用の要約を生成"""
    lines = []
    user_messages = []
    assistant_messages = []

    for line in conversation.split("\n"):
        if line.startswith("User:"):
            user_messages.append(line[5:].strip())
        elif line.startswith("Assistant:"):
            assistant_messages.append(line[10:].strip())

    if user_messages:
        lines.append("### ユーザーの質問/リクエスト")
        for msg in user_messages[:5]:
            lines.append(f"- {msg[:100]}")

    if assistant_messages:
        lines.append("\n### アシスタントの対応")
        for msg in assistant_messages[:3]:
            lines.append(f"- {msg[:100]}")

    return "\n".join(lines) if lines else "要約生成失敗"


def fallback_summary_name(conversation: str) -> str:
    """APIが使えない場合のフォールバック"""
    lines = conversation.split("\n")
    for line in lines:
        if line.startswith("User:"):
            text = line[5:].strip()[:40]
            return sanitize_filename(text) or "session"
    return "session"


def get_repository_name(cwd: str | None = None) -> str:
    """Gitリポジトリ名を取得"""
    try:
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            capture_output=True,
            text=True,
            timeout=5,
            cwd=cwd,
        )
        if result.returncode == 0 and result.stdout.strip():
            url = result.stdout.strip()
            match = re.search(r"[/:]([^/:]+?)(?:\.git)?$", url)
            if match:
                return sanitize_filename(match.group(1))
    except Exception:
        pass

    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            timeout=5,
            cwd=cwd,
        )
        if result.returncode == 0 and result.stdout.strip():
            return sanitize_filename(Path(result.stdout.strip()).name)
    except Exception as e:
        logging.warning(f"Failed to get repository name: {e}")

    if cwd:
        return sanitize_filename(Path(cwd).name)
    return "unknown"


def sanitize_filename(name: str) -> str:
    """ファイル名として安全な文字列に変換"""
    name = name.replace("\n", " ").replace("\r", "")
    name = name.replace(" ", "-").replace("　", "-")
    name = re.sub(r'[<>:"/\\|?*@#]', "", name)
    name = re.sub(r"-+", "-", name)
    name = name.strip("-")
    return name[:80] if name else "session"


def generate_markdown_summary(
    messages: list[dict], session_id: str, summary_name: str, summary_content: str
) -> str:
    """マークダウン形式のサマリーを生成"""
    lines = [
        f"# {summary_name}",
        "",
        f"- **Session ID**: `{session_id}`",
        f"- **Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"- **Events**: {len(messages)}",
        "",
        "## 要約",
        "",
        summary_content,
        "",
    ]
    return "\n".join(lines)


def main():
    start_time = time.time()

    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        logging.error(f"JSON decode error: {e}")
        sys.exit(1)

    session_id = input_data.get("session_id", "unknown")
    transcript_path = input_data.get("transcript_path", "")

    messages = load_transcript(transcript_path)
    if not messages:
        sys.exit(0)

    conversation = extract_conversation(messages)
    if not conversation.strip():
        logging.info("No conversation content extracted, exiting")
        sys.exit(0)

    logging.debug(
        f"Extracted conversation ({len(conversation)} chars):\n{conversation[:500]}"
    )

    summary_name = generate_summary_name(conversation)
    summary_content = generate_summary_content(conversation)

    cwd = input_data.get("cwd")
    repo_name = get_repository_name(cwd)

    summary_dir = Path.home() / ".claude/session-summaries" / repo_name
    summary_dir.mkdir(parents=True, exist_ok=True)

    date_str = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    filename = f"{date_str}_{summary_name}.md"
    output_path = summary_dir / filename

    counter = 1
    while output_path.exists():
        filename = f"{date_str}-{summary_name}-{counter}.md"
        output_path = summary_dir / filename
        counter += 1

    try:
        markdown = generate_markdown_summary(
            messages, session_id, summary_name, summary_content
        )
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(markdown)
        elapsed = time.time() - start_time
        logging.info(f"Saved: {filename} ({elapsed:.1f}s)")
    except Exception as e:
        logging.error(f"Write failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
