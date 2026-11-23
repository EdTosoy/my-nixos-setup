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
# Filtered from the live Codex 0.171.0 tmux capture. The countdown is optional.
QUEUED = f"""? {QUESTION}

  • After 15 minutes of inactivity
  • After 5 minutes of inactivity
  • Only before suspend

• Working (34s • esc to interrupt)

• Queued follow-up inputs
  ? 1 question · 13s
    shift+← to answer

› Ask Codex to do anything
"""
SECOND = "Should Sway dim the screen before locking?"
THIRD = "Should Sway lock when the lid closes?"


def queued_screen(count, *cards):
    history = "".join(f"? {card}\n\n  • Yes\n  • No\n\n" for card in cards)
    suffix = "question" if count == 1 else "questions"
    queue = (
        f"• Queued follow-up inputs\n  ? {count} {suffix} · 3s\n    shift+← to answer\n"
    )
    return f"{history}• Working (15s • esc to interrupt)\n\n{queue if count else ''}"


def pane(number, command="codex", dead=0, project="nixos-setup"):
    return f"123\t%{number}\t{dead}\t{command}\t/work/{project}"


class QuestionnaireTests(unittest.TestCase):
    def test_queue_requires_live_count_and_answer_binding(self):
        self.assertEqual(detector.queued_question(QUEUED), (1, QUESTION))
        wrapped = QUEUED.replace("screen automatically?", "screen\n  automatically?")
        self.assertEqual(detector.queued_question(wrapped), (1, QUESTION))
        messages = QUEUED.replace("  ? 1 question · 13s", "  ↳ Run the checks")
        history_only = QUEUED.split("• Queued follow-up inputs")[0]
        read_only = QUEUED.replace("to answer", "edit last queued message")
        bogus = "• " + QUEUED.replace("\n", "\n  ")
        for output in (history_only, messages, read_only, bogus, PERMISSION, ""):
            with self.subTest(output=output):
                self.assertIsNone(detector.queued_question(output))

    def test_multiple_queued_questions_use_latest_visible_card(self):
        for count in (1, 2, 3):
            with self.subTest(count=count):
                screen = queued_screen(count, "Should Sway dim\n  before locking?")
                self.assertEqual(
                    detector.queued_question(screen),
                    (count, "Should Sway dim before locking?"),
                )
                self.assertEqual(
                    detector.queued_question(queued_screen(count)), (count, None)
                )
        screen = queued_screen(2, QUESTION, SECOND)
        self.assertEqual(detector.queued_question(screen), (2, SECOND))
        conversational = "• Should we continue?\n› Do you need anything else?\n"
        self.assertEqual(
            detector.queued_question(conversational + queued_screen(2)), (2, None)
        )

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

    def test_queued_question_counts_down_and_opens_without_duplicate(self):
        self.screens["%1"] = QUEUED
        state = self.poll()
        self.notify.assert_called_once_with("notify-send", "nixos-setup", QUESTION)
        self.screens["%1"] = QUEUED.replace("34s", "37s").replace(" · 13s", "")
        self.assertEqual(self.poll(state), state)
        self.screens["%1"] = CHOICES
        state = self.poll(state)
        self.screens["%1"] = QUEUED
        self.poll(state)
        self.assertEqual(self.notify.call_count, 1)

    def test_queue_falls_back_when_card_is_missing_and_resets_when_resolved(self):
        status = QUEUED[QUEUED.index("• Queued follow-up inputs") :]
        self.screens["%1"] = status
        state = self.poll()
        self.notify.assert_called_once_with(
            "notify-send", "nixos-setup", "Codex has 1 question waiting for your input."
        )
        self.screens["%1"] = QUEUED
        state = self.poll(state)
        self.screens["%1"] = status.replace("1 question", "2 questions")
        state = self.poll(state)
        self.notify.assert_called_with(
            "notify-send",
            "nixos-setup",
            "Codex has 2 questions waiting for your input.",
        )
        self.screens["%1"] = status
        state = self.poll(state)
        self.assertEqual(self.notify.call_count, 2)
        self.screens["%1"] = PERMISSION
        self.assertEqual(self.poll(state), {})
        self.screens["%1"] = QUEUED
        self.poll()
        self.assertEqual(self.notify.call_count, 3)

    def test_opening_a_form_does_not_reset_the_queue_count(self):
        self.screens["%1"] = QUEUED.replace("1 question", "2 questions")
        state = self.poll()
        self.screens["%1"] = CHOICES
        state = self.poll(state)
        deliveries = self.notify.call_count
        self.screens["%1"] = QUEUED.replace("1 question", "2 questions")
        self.poll(state)
        self.assertEqual(self.notify.call_count, deliveries)

    def test_new_visible_question_in_same_queue(self):
        self.screens["%1"] = QUEUED
        state = self.poll()
        new_question = "Should Sway dim the screen first?"
        self.screens["%1"] = QUEUED.replace(QUESTION, new_question)
        self.poll(state)
        self.assertEqual(self.notify.call_count, 2)
        self.notify.assert_called_with("notify-send", "nixos-setup", new_question)

    def test_queue_growth_drop_clear_and_countdown(self):
        state = {}
        for count, cards, deliveries in (
            (0, (), 0),
            (1, (QUESTION,), 1),
            (2, (SECOND,), 2),
            (1, (QUESTION, SECOND), 2),
            (0, (), 2),
            (1, (QUESTION,), 3),
            (2, (QUESTION, SECOND), 4),
            (3, (QUESTION, SECOND, THIRD), 5),
        ):
            with self.subTest(count=count, deliveries=deliveries):
                self.screens["%1"] = queued_screen(count, *cards)
                state = self.poll(state)
                self.screens["%1"] = self.screens["%1"].replace(" · 3s", " · 2s")
                self.assertEqual(self.poll(state), state)
                self.assertEqual(self.notify.call_count, deliveries)
                if not count:
                    self.assertEqual(state, {})
        self.assertEqual(
            [call.args[-1] for call in self.notify.call_args_list],
            [QUESTION, SECOND, QUESTION, SECOND, THIRD],
        )

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
