"""Exercise config migration with KDE's real configuration writer."""

import configparser
import os
from pathlib import Path
import shutil
import stat
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
WRITER = os.environ.get("KWRITECONFIG6") or shutil.which("kwriteconfig6")
SETTINGS = """[KDE]
widgetStyle=Fusion
[Recent Dirs]
KdenliveProjectsFolder[$e]=$HOME/Videos,$HOME/Documents
[UiSettings]
ColorSchemePath=BreezeLight.colors
CustomPreference=keep me
[version]
version=26.04.3
"""


@unittest.skipUnless(WRITER, "set KWRITECONFIG6 to the pinned kwriteconfig6 binary")
class KdenliveConfigMigrationTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="kdenlive-migration-")
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.config = self.base / "config" / "kdenliverc"
        self.config.parent.mkdir()
        self.original = self.base / "original"
        self.original.write_text(SETTINGS)

    def migrate(self, writer=WRITER):
        return subprocess.run(
            [
                "bash",
                str(ROOT / "kdenlive/migrate-config.sh"),
                str(self.config),
                str(ROOT / "kdenlive/kdenliverc"),
                str(writer),
            ],
            capture_output=True,
            text=True,
        )

    def backups(self):
        return list(self.config.parent.glob("kdenliverc.before-github-dark-studio.*"))

    def test_symlink_is_backed_up_and_other_preferences_survive(self):
        self.original.chmod(0o444)
        self.config.symlink_to(self.original)
        result = self.migrate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.config.is_symlink())
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)
        self.assertEqual(self.original.read_text(), SETTINGS)
        backup, = self.backups()
        self.assertFalse(backup.is_symlink())
        self.assertEqual(backup.read_text(), SETTINGS)
        self.assertEqual(stat.S_IMODE(backup.stat().st_mode), 0o600)
        settings = configparser.ConfigParser(interpolation=None)
        settings.optionxform = str
        settings.read(self.config)
        self.assertEqual(settings["UiSettings"]["ColorSchemePath"], "GitHubDarkStudio.colors")
        self.assertEqual(settings["UiSettings"]["CustomPreference"], "keep me")
        self.assertEqual(settings["KDE"]["widgetStyle"], "Fusion")
        self.assertEqual(
            settings["Recent Dirs"]["KdenliveProjectsFolder[$e]"],
            "$HOME/Videos,$HOME/Documents",
        )
        self.assertEqual(settings["version"]["version"], "26.04.3")
        self.original.unlink()
        self.assertEqual(backup.read_text(), SETTINGS)

    def test_regular_file_and_later_gui_choices_are_untouched(self):
        self.config.write_text(SETTINGS)
        result = self.migrate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(), SETTINGS)
        self.assertEqual(self.backups(), [])

    def test_fresh_config_is_seeded_once(self):
        self.config.parent.rmdir()
        result = self.migrate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("ColorSchemePath=GitHubDarkStudio.colors", self.config.read_text())
        self.assertIn("widgetStyle=Fusion", self.config.read_text())
        self.assertEqual(self.backups(), [])
        self.config.write_text(SETTINGS)
        self.assertEqual(self.migrate().returncode, 0)
        self.assertEqual(self.config.read_text(), SETTINGS)

    def test_dangling_link_is_not_replaced(self):
        missing = self.base / "missing"
        self.config.symlink_to(missing)
        self.assertNotEqual(self.migrate().returncode, 0)
        self.assertTrue(self.config.is_symlink())
        self.assertEqual(self.config.readlink(), missing)

    def test_writer_failure_preserves_link_and_backup(self):
        self.config.symlink_to(self.original)
        result = self.migrate(writer="/bin/false")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.readlink(), self.original)
        backup, = self.backups()
        self.assertEqual(backup.read_text(), SETTINGS)
        self.assertEqual(list(self.config.parent.glob("kdenliverc.tmp.*")), [])

    def test_backup_names_do_not_overwrite_previous_backups(self):
        self.config.symlink_to(self.original)
        self.assertEqual(self.migrate().returncode, 0)
        first_backup, = self.backups()
        self.config.unlink()
        self.config.symlink_to(self.original)
        self.assertEqual(self.migrate().returncode, 0)
        self.assertEqual(len(self.backups()), 2)
        self.assertEqual(first_backup.read_text(), SETTINGS)


if __name__ == "__main__":
    unittest.main()
