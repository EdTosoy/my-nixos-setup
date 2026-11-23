import importlib.util
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/codex-question-notify.py"
SPEC = importlib.util.spec_from_file_location("detector", SCRIPT)
detector = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(detector)

# The 0.171.0 freeform/chord snapshot, as plain text from capture-pane.
FREEFORM = """
  Question 1/1 (1 unanswered)
  Share details.

  › Type your answer (optional)



  ⌃x enter to submit answer | esc to interrupt
"""
CHOICES = """
• I found two possible settings.

  Question 1/1 (1 unanswered)
  When should Sway lock your screen
  automatically?

  › 1. After 15 minutes (Recommended)  Lock after a longer break.
    2. After 5 minutes               Lock sooner.
    3. Only before suspend           Keep the current behavior.
    4. None of the above

  tab to add notes | enter to submit answer | esc to interrupt
"""
PERMISSION = """
  Would you like to run the following command?

  › 1. Yes, proceed
    2. No, and tell Codex what to do differently

  Press enter to confirm or esc to cancel
"""
QUESTION = "When should Sway lock your screen automatically?"


def pane(number, command="codex", dead=0, project="nixos-setup"):
    return f"123\t%{number}\t{dead}\t{command}\t/work/{project}"


class QuestionnaireTests(unittest.TestCase):
    def test_freeform_and_wrapped_options(self):
        self.assertEqual(detector.questionnaire(FREEFORM), (1, 1, "Share details."))
        self.assertEqual(detector.questionnaire(CHOICES), (1, 1, QUESTION))
        countdown = CHOICES.replace(
            "unanswered)", "unanswered) · auto-resolves in 1m 00s"
        )
        self.assertEqual(detector.questionnaire(countdown), (1, 1, QUESTION))
        narrow = CHOICES.replace(" | esc to interrupt", "\nesc to interrupt")
        self.assertEqual(detector.questionnaire(narrow), (1, 1, QUESTION))

    def test_ignores_malformed_completed_and_approval_screens(self):
        for output in (
            "",
            "\n\n",
            "Question 1/1 (1 unanswered)\nWhat next?",
            "• Question 1/1 (1 unanswered)\nenter to submit answer",
            "Question 1/1 (1 unanswered)\n\nenter to submit answer",
            CHOICES.replace("1/1", "2/1"),
            CHOICES.replace(" (1 unanswered)", ""),
            CHOICES + "\n› Improve the configuration",
            PERMISSION,
            "• The permission request was reviewed automatically.",
        ):
            with self.subTest(output=output):
                self.assertIsNone(detector.questionnaire(output))


class PollTests(unittest.TestCase):
    def setUp(self):
        self.panes = pane(1)
        self.screens = {"%1": CHOICES}
        capture = patch.object(detector, "capture", side_effect=self.capture)
        notify = patch.object(detector, "notify", return_value=True)
        self.capture_mock = capture.start()
        self.notify = notify.start()
        self.addCleanup(capture.stop)
        self.addCleanup(notify.stop)

    def capture(self, tmux, no_start, command, *args):
        self.assertEqual((tmux, no_start), ("tmux", "-N"))
        if command == "list-panes":
            self.assertEqual(args, ("-a", "-F", detector.PANE_FORMAT))
            return self.panes
        self.assertEqual(command, "capture-pane")
        self.assertEqual(args[:2], ("-p", "-t"))
        return self.screens.get(args[-1], "")

    def poll(self, previous=None):
        return detector.poll("tmux", "notify-send", previous or {})

    def test_suppresses_duplicates_and_resets_after_close(self):
        state = self.poll()
        self.assertEqual(self.poll(state), state)
        self.notify.assert_called_once_with("notify-send", "nixos-setup", QUESTION)
        self.panes = ""
        self.assertEqual(self.poll(state), {})
        self.panes = pane(1)
        self.assertEqual(self.poll(), state)
        self.assertEqual(self.notify.call_count, 2)

    def test_multi_question_navigation_and_new_prompt(self):
        first = CHOICES.replace("1/1 (1", "1/2 (2")
        second = FREEFORM.replace("1/1", "2/2").replace("submit answer", "submit all")
        self.screens["%1"] = first
        state = self.poll()
        self.screens["%1"] = second
        state = self.poll(state)
        self.screens["%1"] = first.replace("2 unanswered", "1 unanswered")
        self.assertEqual(self.poll(state), state)
        self.assertEqual(
            [call.args[-1] for call in self.notify.call_args_list],
            [
                QUESTION,
                "Share details.",
            ],
        )
        self.screens["%1"] = first.replace("automatically?", "on battery?")
        self.poll(state)
        self.assertEqual(self.notify.call_count, 3)

    def test_independent_sessions_and_missing_or_non_codex_panes(self):
        self.panes = "\n".join(
            [
                pane(1),
                pane(1),
                pane(2, project="second project"),
                pane(3, "nvim"),
                pane(4, dead=1),
                pane(5),
                "malformed",
            ]
        )
        self.screens.update({"%2": CHOICES, "%3": CHOICES, "%4": CHOICES})
        state = self.poll()
        self.assertEqual(set(state), {"123:%1", "123:%2"})
        self.assertEqual(self.notify.call_count, 2)
        self.notify.assert_called_with("notify-send", "second project", QUESTION)
        self.assertEqual(
            [call.args[-1] for call in self.capture_mock.call_args_list[1:]],
            ["%1", "%2", "%5"],
        )

    def test_retries_failed_delivery_and_persists_only_hashes(self):
        with tempfile.TemporaryDirectory() as directory:
            self.notify.side_effect = [False, True]
            detector.main("tmux", "notify-send", directory)
            detector.main("tmux", "notify-send", directory)
            detector.main("tmux", "notify-send", directory)
            self.assertEqual(self.notify.call_count, 2)
            cache = (Path(directory) / "seen.json").read_text()
            self.assertNotIn(QUESTION, cache)
            self.assertNotIn("nixos-setup", cache)


class DeliveryTests(unittest.TestCase):
    def test_notification_text_and_markup_escaping(self):
        with patch.object(detector.subprocess, "run") as run:
            run.return_value.returncode = 0
            self.assertTrue(detector.notify("notify-send", "a&b", "Use <this>?"))
        command = run.call_args.args[0]
        self.assertEqual(
            command[-3:],
            [
                "--",
                "Codex — a&amp;b",
                "<b>❓ Your input needed</b>\n\nUse &lt;this&gt;?",
            ],
        )


if __name__ == "__main__":
    unittest.main()
