"""Digest a `claude -p --output-format stream-json` transcript.

Prints a PLUGINS line from the init event, the ordered tool calls, then the final text.
"""
import json
import sys


def main(path):
    plugins, calls, final = None, [], ""
    with open(path, encoding="utf-8") as f:
        for raw in f:
            raw = raw.strip()
            if not raw.startswith("{"):
                continue
            try:
                event = json.loads(raw)
            except json.JSONDecodeError:
                continue
            kind = event.get("type")
            if kind == "system" and event.get("subtype") == "init":
                plugins = [p.get("name", "?") for p in event.get("plugins", [])]
            elif kind == "assistant":
                for block in event.get("message", {}).get("content", []):
                    if block.get("type") == "tool_use":
                        args = json.dumps(block.get("input", {}), ensure_ascii=False)
                        calls.append(f"{block.get('name')} {args[:300]}")
            elif kind == "result":
                final = event.get("result") or (
                    f"{event.get('subtype')} (is_error={json.dumps(bool(event.get('is_error')))})"
                )
                final = final.replace("\n", " ⏎ ")
    print("PLUGINS: " + (", ".join(plugins) if plugins is not None else "(unknown)"))
    for i, call in enumerate(calls, 1):
        print(f"{i}. {call}")
    print(f"FINAL: {final[:2000]}")


if __name__ == "__main__":
    main(sys.argv[1])
