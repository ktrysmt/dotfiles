#!/usr/bin/env python3
"""
Claude Code SessionEnd Hook
セッション履歴をサマライズして、日付+要約名のmarkdownファイルとして保存
Claude Code CLIをsubprocessで直接呼び出し（標準ライブラリのみ）
"""

import json
import sys
import os
import re
import subprocess
import logging
import logging.handlers
import time
from datetime import datetime
from pathlib import Path

# ログ設定
LOG_FILE = Path.home() / ".claude/hooks/session_summarizer.log"
LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
LOG_LEVEL = logging.DEBUG if os.environ.get("DEBUG") else logging.INFO
_handler = logging.handlers.RotatingFileHandler(
    LOG_FILE, maxBytes=100 * 1024, backupCount=2,
)
_handler.setFormatter(logging.Formatter(
    "%(asctime)s [%(levelname)s] %(message)s", datefmt="%Y-%m-%d %H:%M:%S",
))
logging.basicConfig(level=LOG_LEVEL, handlers=[_handler])

CLAUDE_MODEL = "haiku"
MIN_USER_TURNS = 2

# システムタグ除去用の正規表現をモジュールレベルで事前コンパイル
_SYSTEM_TAGS = [
    "system-reminder", "local-command-caveat", "env", "claude_background_info",
    "antml:thinking", "antml:function_calls", "function_results",
    "bash-input", "bash-stdout", "bash-stderr",
]
_TAG_PATTERNS = []
for _tag in _SYSTEM_TAGS:
    _TAG_PATTERNS.append(re.compile(rf"<{_tag}[^>]*>.*?</{_tag}>", re.DOTALL | re.IGNORECASE))
    _TAG_PATTERNS.append(re.compile(rf"<{_tag}[^>]*/?>", re.IGNORECASE))
_RE_FILE_REF = re.compile(r"@\.?[\w./-]+(?:\.\w+)?(?:#L\d+(?:-\d+)?)?\s*")
_RE_SYMBOL_REF = re.compile(r"(?<!#)#([a-zA-Z_][a-zA-Z0-9_]*)\b")
_RE_MD_HEADING = re.compile(r"^#{1,6}\s*", re.MULTILINE)
_RE_BLANK_LINES = re.compile(r"\n{3,}")
_RE_PREAMBLE = re.compile(
    r"^(会話内容を踏まえて|以下[のが]|要約[名タイトル]*[をは]?|提案します)[：:、。\s]*"
)
_RE_UNSAFE_CHARS = re.compile(r'[<>:"/\\|?*@#]')
_RE_MULTI_DASH = re.compile(r"-+")


def call_claude_cli(prompt: str) -> str | None:
    """Claude Code CLIをsubprocessで呼び出す"""
    try:
        env = os.environ.copy()
        env["CLAUDE_SUMMARIZER_RUNNING"] = "1"
        result = subprocess.run(
            ["claude", "-p", prompt, "--model", CLAUDE_MODEL, "--output-format", "text", "--no-session-persistence"],
            capture_output=True,
            text=True,
            timeout=120,
            env=env,
        )

        if result.returncode != 0:
            logging.error(f"Claude CLI error: {result.stderr}")
            return None

        response = result.stdout.strip()
        logging.debug(f"Claude CLI output: {response[:200]}")
        return response if response else None

    except subprocess.TimeoutExpired:
        logging.error("Claude CLI timeout")
        return None
    except FileNotFoundError:
        logging.error("Claude CLI not found. Please install: npm install -g @anthropic-ai/claude-code")
        return None
    except Exception as e:
        logging.error(f"Claude CLI error: {e}")
        return None


def load_transcript(transcript_path: str) -> list[dict]:
    """JSONLトランスクリプトを読み込む"""
    messages = []
    if not transcript_path or not os.path.exists(transcript_path):
        return messages
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
    result = text
    for pattern in _TAG_PATTERNS:
        result = pattern.sub("", result)
    result = _RE_FILE_REF.sub("", result)
    result = _RE_SYMBOL_REF.sub(r"\1", result)
    result = _RE_MD_HEADING.sub("", result)
    result = _RE_BLANK_LINES.sub("\n\n", result)
    return result.strip()


def _extract_text(content) -> str:
    """メッセージcontentからテキストを抽出"""
    if isinstance(content, list):
        return " ".join(
            str(c.get("text", "")) for c in content if isinstance(c, dict)
        )
    return str(content)


def extract_conversation(messages: list[dict]) -> str:
    """会話内容をテキストに変換"""
    conversation = []
    for m in messages:
        msg_type = m.get("type", "")
        if msg_type not in ("user", "assistant"):
            continue
        content = m.get("message", {}).get("content", "")
        content = clean_system_tags(_extract_text(content))
        if not content:
            continue
        limit = 500 if msg_type == "user" else 300
        conversation.append(f"{'User' if msg_type == 'user' else 'Assistant'}: {content[:limit]}")
    return "\n".join(conversation[:30])


def is_valid_summary_name(name: str) -> bool:
    """要約名として有効かチェック"""
    if not name or len(name) < 5:
        return False
    if re.search(r"[/\\@]", name):
        return False
    if re.search(r"\.\w{1,4}$", name):
        return False
    return not re.match(r"^[\d\-]+$", name)


def generate_summary_name(conversation: str) -> str:
    """Claude CLIを使ってセッションの要約名を生成"""
    prompt = f"""会話セッションの要約タイトルを1つだけ出力せよ。

ルール:
- 20〜60文字の日本語タイトル
- 前置き・説明・装飾は一切不要
- 「〜の実装」「〜の修正」「〜についての議論」のような名詞句で終わる形式
- ファイル名に使えない文字（/\\:*?"<>|@#）は使用禁止

良い例:
- セッション要約スクリプトのバグ修正
- Git worktree対応の追加実装
- TypeScript型エラーの調査と解決

悪い例:
- 「要約名を提案します：〜」← 前置き禁止
- 「## タイトル」← マークダウン記号禁止
- 「以下が要約です」← 説明禁止

会話:
{conversation}

タイトル（1行のみ）:"""

    result = call_claude_cli(prompt)

    if result:
        logging.debug(f"Summary name result: {result}")
        cleaned = _RE_PREAMBLE.sub("", result.strip())
        if "：" in cleaned:
            cleaned = cleaned.split("：", 1)[-1].strip()
        if ":" in cleaned:
            cleaned = cleaned.split(":", 1)[-1].strip()

        lines = [line.strip() for line in cleaned.split("\n") if line.strip()]
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

    logging.warning("No valid summary name from CLI, using fallback")
    fallback = fallback_summary_name(conversation)
    logging.info(f"Fallback summary name: {fallback}")
    return fallback


def generate_summary_content(conversation: str) -> str:
    """Claude CLIで会話の要約を生成"""
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

    result = call_claude_cli(prompt)

    if result and len(result) >= 50:
        logging.info(f"Summary generated: {len(result)} chars")
        return result

    logging.warning("CLI summary failed or too short, using fallback")
    return generate_fallback_summary(conversation)


def generate_fallback_summary(conversation: str) -> str:
    """フォールバック用の要約を生成"""
    user_messages = []
    assistant_messages = []

    for line in conversation.split("\n"):
        if line.startswith("User:"):
            user_messages.append(line[5:].strip())
        elif line.startswith("Assistant:"):
            assistant_messages.append(line[10:].strip())

    lines = []
    if user_messages:
        lines.append("### ユーザーの質問/リクエスト")
        lines.extend(f"- {msg[:100]}" for msg in user_messages[:5])
    if assistant_messages:
        lines.append("\n### アシスタントの対応")
        lines.extend(f"- {msg[:100]}" for msg in assistant_messages[:3])

    return "\n".join(lines) if lines else "要約生成失敗"


def fallback_summary_name(conversation: str) -> str:
    """CLIが使えない場合のフォールバック"""
    for line in conversation.split("\n"):
        if line.startswith("User:"):
            text = line[5:].strip()[:40]
            return sanitize_filename(text) or "session"
    return "session"


def get_repository_info(cwd: str | None = None) -> tuple[str, str | None]:
    """Gitリポジトリ名とworktree名を取得"""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel", "--git-common-dir"],
            capture_output=True,
            text=True,
            timeout=5,
            cwd=cwd,
        )
        if result.returncode == 0 and result.stdout.strip():
            lines = result.stdout.strip().split("\n")
            toplevel = Path(lines[0])
            common_dir = Path(lines[1]).resolve() if len(lines) > 1 else None

            if common_dir and common_dir != (toplevel / ".git").resolve():
                repo_name = sanitize_filename(common_dir.parent.name)
                worktree_name = sanitize_filename(toplevel.name)
                logging.info(f"Worktree detected: repo={repo_name}, worktree={worktree_name}")
                return repo_name, worktree_name

            return sanitize_filename(toplevel.name), None

    except Exception as e:
        logging.warning(f"Failed to get repository info: {e}")

    if cwd:
        return sanitize_filename(Path(cwd).name), None
    return "unknown", None


def sanitize_filename(name: str) -> str:
    """ファイル名として安全な文字列に変換"""
    name = name.replace("\n", " ").replace("\r", "")
    name = name.replace(" ", "-").replace("\u3000", "-")
    name = _RE_UNSAFE_CHARS.sub("", name)
    name = _RE_MULTI_DASH.sub("-", name).strip("-")
    return name[:80] if name else "session"


def make_markdown(
    messages: list[dict],
    session_id: str,
    summary_name: str,
    summary_content: str,
    cwd: str | None = None,
) -> str:
    """マークダウン形式のサマリーを生成"""
    return "\n".join([
        f"# {summary_name}",
        "",
        f"- **Session ID**: `{session_id}`",
        f"- **CWD**: `{cwd or 'unknown'}`",
        f"- **Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"- **Events**: {len(messages)}",
        "",
        "## 要約",
        "",
        summary_content,
        "",
    ])


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

    user_turns = sum(1 for m in messages if m.get("type") == "user")
    if user_turns < MIN_USER_TURNS:
        logging.info(f"Too few user turns ({user_turns}), skipping")
        sys.exit(0)

    conversation = extract_conversation(messages)
    if not conversation.strip():
        logging.info("No conversation content extracted, exiting")
        sys.exit(0)

    logging.debug(f"Extracted conversation ({len(conversation)} chars):\n{conversation[:500]}")

    summary_name = generate_summary_name(conversation)
    summary_content = generate_summary_content(conversation)

    cwd = input_data.get("cwd")
    repo_name, worktree_name = get_repository_info(cwd)

    if worktree_name:
        summary_dir = Path.home() / ".claude/session-summaries" / repo_name / worktree_name
    else:
        summary_dir = Path.home() / ".claude/session-summaries" / repo_name
    summary_dir.mkdir(parents=True, exist_ok=True)

    date_str = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    filename = f"{date_str}_{summary_name}.md"
    output_path = summary_dir / filename

    counter = 1
    while output_path.exists():
        filename = f"{date_str}_{summary_name}_{counter}.md"
        output_path = summary_dir / filename
        counter += 1

    try:
        markdown = make_markdown(messages, session_id, summary_name, summary_content, cwd)
        output_path.write_text(markdown, encoding="utf-8")
        elapsed = time.time() - start_time
        logging.info(f"Saved: {filename} ({elapsed:.1f}s)")
    except Exception as e:
        logging.error(f"Write failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
