"""Poll the visible screen of each Codex pane on the default tmux server."""

import hashlib
import json
import re
import subprocess
import sys
from html import escape
from pathlib import Path


PROGRESS = re.compile(
    r"Question ([1-9][0-9]?)/([1-9][0-9]?)"
    r" \(([1-9][0-9]?) unanswered\)(?: · auto-resolves in .+)?"
)
OPTION = re.compile(r"^(?:›\s*)?[1-9][0-9]*\.\s")
FOOTER = re.compile(r"\bto submit (?:answer|all)(?:\s*\||\s*…|$)")
FOOTER_CONTINUATION = re.compile(
    r"\b(?:to (?:navigate questions|interrupt)|change question)$"
)
PANE_FORMAT = (
    "#{pid}\t#{pane_id}\t#{pane_dead}\t#{pane_current_command}\t#{pane_current_path}"
)


def questionnaire(screen):
    lines = [line.strip() for line in screen.splitlines()]
    while lines and not lines[-1]:
        lines.pop()
    # Codex renders its submit shortcut in the bottom overlay, below the prompt.
    footer = len(lines)
    while (
        footer
        and FOOTER_CONTINUATION.search(lines[footer - 1])
        and not FOOTER.search(lines[footer - 1])
    ):
        footer -= 1
    if not footer or not FOOTER.search(lines[footer - 1]):
        return None
    for row in range(footer - 2, -1, -1):
        progress = PROGRESS.fullmatch(lines[row])
        if progress is None:
            continue
        index, total, unanswered = map(int, progress.groups())
        if max(index, unanswered) > total:
            return None
        prompt = []
        for line in lines[row + 1 : footer - 1]:
            if not line or line.startswith("›") or OPTION.match(line):
                break
            prompt.append(line)
        if prompt:
            return index, total, " ".join(" ".join(prompt).split())
        return None
    return None


def capture(*command):
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=2,
        )
    except (OSError, subprocess.TimeoutExpired):
        return ""
    return result.stdout if result.returncode == 0 else ""


def notify(notify_send, project, question):
    try:
        result = subprocess.run(
            [
                notify_send,
                "--app-name=Codex",
                "--urgency=normal",
                "--",
                f"Codex — {escape(project)}",
                f"<b>❓ Your input needed</b>\n\n{escape(question)}",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=2,
        )
    except (OSError, subprocess.TimeoutExpired):
        return False
    return result.returncode == 0


def poll(tmux, notify_send, previous):
    current = {}
    panes = capture(tmux, "-N", "list-panes", "-a", "-F", PANE_FORMAT)
    for line in panes.split("\n"):
        fields = line.split("\t", 4)
        if len(fields) != 5:
            continue
        server, pane, dead, command, directory = fields
        if dead != "0" or command != "codex" or not re.fullmatch(r"%[0-9]+", pane):
            continue
        key = f"{server}:{pane}"
        if key in current:
            continue
        screen = capture(tmux, "-N", "capture-pane", "-p", "-t", pane)
        question = questionnaire(screen)
        if question is None:
            continue
        index, total, text = question
        slot = f"{index}/{total}"
        project = Path(directory).name or "/"
        fingerprint = hashlib.sha256(f"{project}\0{text}".encode()).hexdigest()
        seen = previous.get(key, {})
        # A changed prompt in the same slot or a changed total starts a new form.
        if any(not item.endswith(f"/{total}") for item in seen) or (
            slot in seen and seen[slot] != fingerprint
        ):
            seen = {}
        if seen.get(slot) != fingerprint and notify(notify_send, project, text):
            seen = {**seen, slot: fingerprint}
        current[key] = seen
    return current


def main(tmux, notify_send, state_directory):
    state_file = Path(state_directory) / "seen.json"
    try:
        previous = json.loads(state_file.read_text())
    except (FileNotFoundError, ValueError):
        previous = {}

    current = poll(tmux, notify_send, previous)
    if current != previous:
        temporary = state_file.with_suffix(".tmp")
        temporary.write_text(json.dumps(current))
        temporary.replace(state_file)


if __name__ == "__main__":
    main(*sys.argv[1:])
