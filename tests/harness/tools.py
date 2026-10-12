"""Digest a `claude -p --output-format stream-json` transcript: ordered tool calls, then the final text."""
import json
import sys


def main(path):
    calls, final = [], ""
    with open(path, encoding="utf-8") as f:
        for raw in f:
            raw = raw.strip()
            if not raw.startswith("{"):
                continue
            event = json.loads(raw)
            if event.get("type") == "assistant":
                for block in event.get("message", {}).get("content", []):
                    if block.get("type") == "tool_use":
                        args = json.dumps(block.get("input", {}), ensure_ascii=False)
                        calls.append(f"{block.get('name')} {args[:300]}")
            elif event.get("type") == "result":
                final = (event.get("result") or "").replace("\n", " ⏎ ")
    for i, call in enumerate(calls, 1):
        print(f"{i}. {call}")
    print(f"FINAL: {final[:2000]}")


if __name__ == "__main__":
    main(sys.argv[1])
