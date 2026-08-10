#!/usr/bin/env python3
import json
import os
import sys
import tempfile
import time
from pathlib import Path

STATE = Path.home() / ".config" / "waybar" / "time-tracker.json"


def load():
    try:
        with STATE.open() as file:
            state = json.load(file)
            return float(state.get("elapsed", 0)), state.get("started")
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError, ValueError):
        return 0, None


def save(elapsed, started):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", dir=STATE.parent, delete=False) as file:
        json.dump({"elapsed": elapsed, "started": started}, file)
        file.flush()
        os.fsync(file.fileno())
        temporary = file.name
    os.replace(temporary, STATE)


def main():
    elapsed, started = load()
    now = time.time()
    action = sys.argv[1] if len(sys.argv) > 1 else "show"

    if action == "toggle":
        if started is None:
            started = now
        else:
            elapsed += max(0, now - started)
            started = None
        save(elapsed, started)
    elif action == "reset":
        save(0, None)
        elapsed, started = 0, None

    if started is not None:
        elapsed += max(0, now - started)
    seconds = int(elapsed)
    print(f"{seconds // 3600:02d}:{seconds // 60 % 60:02d}:{seconds % 60:02d}")


if __name__ == "__main__":
    main()
