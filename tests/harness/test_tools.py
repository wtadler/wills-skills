import pathlib
import subprocess
import sys
import unittest

HERE = pathlib.Path(__file__).parent


class ToolsDigestTest(unittest.TestCase):
    def test_lists_tool_calls_in_order_then_final_text(self):
        out = subprocess.run(
            [sys.executable, str(HERE / "tools.py"), str(HERE / "fixtures" / "sample.jsonl")],
            capture_output=True, text=True, check=True,
        ).stdout
        lines = out.strip().splitlines()
        self.assertTrue(lines[0].startswith("1. Bash "), lines[0])
        self.assertIn("echo hi", lines[0])
        self.assertTrue(lines[-1].startswith("FINAL: "), lines[-1])

    def test_missing_file_exits_nonzero(self):
        proc = subprocess.run([sys.executable, str(HERE / "tools.py"), "/nonexistent.jsonl"], capture_output=True)
        self.assertNotEqual(proc.returncode, 0)


if __name__ == "__main__":
    unittest.main()
