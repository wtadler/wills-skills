import os
import pathlib
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest

HERE = pathlib.Path(__file__).parent
ROOT = HERE.parent.parent


def digest(fixture):
    return subprocess.run(
        [sys.executable, str(HERE / "tools.py"), str(HERE / "fixtures" / fixture)],
        capture_output=True, text=True, check=True,
    ).stdout.strip().splitlines()


class ToolsDigestTest(unittest.TestCase):
    def test_lists_tool_calls_in_order_then_final_text(self):
        lines = digest("sample.jsonl")
        self.assertTrue(lines[1].startswith("1. Bash "), lines[1])
        self.assertIn("echo hi", lines[1])
        self.assertTrue(lines[-1].startswith("FINAL: "), lines[-1])

    def test_first_line_lists_plugins_from_the_init_event(self):
        lines = digest("with-init.jsonl")
        self.assertEqual(lines[0], "PLUGINS: wills-skills, superpowers")

    def test_first_line_flags_a_transcript_with_no_init_event(self):
        self.assertEqual(digest("sample.jsonl")[0], "PLUGINS: (unknown)")

    def test_skips_stray_brace_lines_that_are_not_json(self):
        lines = digest("with-init.jsonl")
        self.assertEqual(lines[1], '1. Skill {"skill": "superpowers:test-driven-development"}')
        self.assertEqual(lines[-1], "FINAL: all done")

    def test_error_result_prints_subtype_and_is_error(self):
        self.assertEqual(digest("error-result.jsonl")[-1], "FINAL: error_max_turns (is_error=true)")

    def test_missing_file_exits_nonzero(self):
        proc = subprocess.run([sys.executable, str(HERE / "tools.py"), "/nonexistent.jsonl"], capture_output=True)
        self.assertNotEqual(proc.returncode, 0)


class BaselineGuardTest(unittest.TestCase):
    """run.sh refuses a baseline run whose init event lists wills-skills."""

    def setUp(self):
        self.tmp = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp, True)
        scenario = self.tmp / "guard-group" / "guard-scenario"
        scenario.mkdir(parents=True)
        (scenario / "setup.sh").write_text('#!/usr/bin/env bash\nmkdir -p "$1"\n')
        (scenario / "prompt.md").write_text("hi\n")
        self.scenario = scenario
        # Fake claude: emits an init event listing $FAKE_PLUGINS, then a success result.
        bin_dir = self.tmp / "bin"
        bin_dir.mkdir()
        fake = bin_dir / "claude"
        fake.write_text(
            "#!/usr/bin/env bash\n"
            "python3 - <<'PY'\n"
            "import json, os\n"
            "names = [n for n in os.environ['FAKE_PLUGINS'].split(',') if n]\n"
            "print(json.dumps({'type': 'system', 'subtype': 'init', 'plugins': [{'name': n} for n in names]}))\n"
            "print(json.dumps({'type': 'result', 'subtype': 'success', 'is_error': False, 'result': 'ok'}))\n"
            "PY\n"
        )
        fake.chmod(fake.stat().st_mode | stat.S_IEXEC)
        self.bin_dir = bin_dir
        self.addCleanup(shutil.rmtree, ROOT / "tests" / "results" / "guard-group", True)

    def run_arm(self, arm, plugins):
        env = dict(os.environ, PATH=f"{self.bin_dir}:{os.environ['PATH']}", FAKE_PLUGINS=plugins)
        return subprocess.run(
            ["bash", str(HERE / "run.sh"), str(self.scenario), arm, "1"],
            capture_output=True, text=True, env=env,
        )

    def test_baseline_with_wills_skills_loaded_is_invalid(self):
        proc = self.run_arm("baseline", "wills-skills,superpowers")
        self.assertNotEqual(proc.returncode, 0)
        self.assertIn("INVALID BASELINE: wills-skills loaded", proc.stdout + proc.stderr)

    def test_baseline_without_wills_skills_runs_normally(self):
        proc = self.run_arm("baseline", "superpowers")
        self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)
        self.assertIn("PLUGINS: superpowers", proc.stdout)

    def test_skill_arm_may_load_wills_skills(self):
        proc = self.run_arm("skill", "wills-skills,superpowers")
        self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)


if __name__ == "__main__":
    unittest.main()
