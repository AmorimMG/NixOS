import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from catalog import Entry, collect_tools
from main import Library, QApplication


class DiscoveryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def command(self, package, name, executable=True):
        directory = self.root / package / "bin"
        directory.mkdir(parents=True, exist_ok=True)
        command = directory / name
        command.write_text("#!/bin/sh\n")
        command.chmod(0o755 if executable else 0o644)
        return command

    def metadata(self, package, **extra):
        return {"name": package, "path": str(self.root / package), **extra}

    def test_groups_commands_and_prefers_main_program(self):
        self.command("tools", "extra")
        self.command("tools", "primary")
        package = self.metadata(
            "tools", mainProgram="primary", description="Network utilities"
        )
        entries = collect_tools([package, package], path=str(self.root / "tools/bin"))
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0].commands, ["primary", "extra"])
        self.assertEqual(entries[0].category, "Internet & network")

    def test_respects_path_precedence_and_profile_symlinks(self):
        old = self.command("old", "tool")
        new = self.command("new", "tool")
        profile = self.root / "profile"
        profile.mkdir()
        (profile / "tool").symlink_to(new)
        entries = collect_tools(
            [self.metadata("old"), self.metadata("new")],
            path=os.pathsep.join([str(profile), str(old.parent)]),
        )
        self.assertEqual([entry.name for entry in entries], ["new"])

    def test_excludes_gui_commands_wrappers_and_non_executables(self):
        self.command("tools", "gui-app")
        self.command("tools", ".hidden")
        self.command("tools", "tool-wrapped")
        self.command("tools", "readme", executable=False)
        self.command("tools", "helper")
        entries = collect_tools(
            [self.metadata("tools")],
            ["gui-app"],
            path=str(self.root / "tools/bin"),
        )
        self.assertEqual(entries[0].commands, ["helper"])

    def test_unknown_commands_and_missing_packages(self):
        command = self.command("custom", "my-tool")
        entries = collect_tools([self.metadata("missing")], path=str(command.parent))
        self.assertEqual(entries[0].name, "my-tool")
        self.assertEqual(entries[0].commands, ["my-tool"])

    def test_searches_all_words_across_descriptions_and_commands(self):
        entry = Entry(
            "Tools", "Network diagnostics", "CLI tools", "System", "", ["doggo"]
        )
        self.assertTrue(entry.matches("DOGGO network"))
        self.assertFalse(entry.matches("doggo audio"))


class WindowTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = QApplication.instance() or QApplication([])

    def setUp(self):
        self.reload = patch.object(Library, "reload")
        self.reload.start()
        self.addCleanup(self.reload.stop)
        self.window = Library()
        self.addCleanup(self.window.close)
        self.window.loaded(
            [
                Entry(
                    "Browser",
                    "Browse the web",
                    "Applications",
                    "Internet & network",
                    "",
                    desktop_file="/tmp/browser.desktop",
                ),
                Entry(
                    "Network tools",
                    "DNS diagnostics",
                    "CLI tools",
                    "Internet & network",
                    "",
                    ["doggo", "dns-helper"],
                ),
                Entry("Editor", "Edit text", "Applications", "Development", ""),
            ],
            "",
        )
        self.app.processEvents()

    def test_type_search_and_empty_state(self):
        self.assertEqual(self.window.grid.count(), 3)
        self.window.kind.setCurrentText("CLI tools")
        self.assertEqual(self.window.grid.count(), 1)
        self.window.search.setText("dns-helper")
        self.assertEqual(self.window.selected().name, "Network tools")
        self.window.search.setText("nothing-matches")
        self.assertEqual(self.window.grid.count(), 0)
        self.assertTrue(self.window.detail.isHidden())
        self.assertFalse(self.window.empty.isHidden())

    def test_category_filter(self):
        self.window.categories.setCurrentRow(1)
        self.assertEqual(self.window.selected().name, "Editor")
        self.assertEqual(self.window.grid.count(), 1)

    def test_cli_opens_terminal_without_executing_command(self):
        self.window.kind.setCurrentText("CLI tools")
        self.window.commands.addItem("tool;touch /tmp/should-not-exist")
        self.window.commands.setCurrentIndex(2)
        with patch("main.subprocess.Popen") as spawn:
            self.window.activate()
        args = spawn.call_args.args[0]
        self.assertEqual(args[:5], ["ghostty", "-e", "zsh", "-i", "-c"])
        self.assertNotIn("touch", args[5])
        self.assertEqual(args[-1], "'tool;touch /tmp/should-not-exist'")
        self.assertNotIn("shell", spawn.call_args.kwargs)

    def test_gui_uses_desktop_entry_launcher(self):
        with patch("main.GioUnix.DesktopAppInfo.new_from_filename") as desktop:
            self.window.activate()
            desktop.assert_called_once_with("/tmp/browser.desktop")
            desktop.return_value.launch.assert_called_once_with([], None)

    def test_copy_selected_command(self):
        self.window.kind.setCurrentText("CLI tools")
        self.window.commands.setCurrentIndex(1)
        self.window.copy_command()
        self.assertEqual(self.app.clipboard().text(), "dns-helper")


if __name__ == "__main__":
    unittest.main()
