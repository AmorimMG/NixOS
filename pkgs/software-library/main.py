import json
import os
import shlex
import subprocess
import sys
from pathlib import Path

import gi

gi.require_version("Gio", "2.0")
gi.require_version("GioUnix", "2.0")
from catalog import CATEGORIES, Entry, collect_tools
from gi.repository import Gio, GioUnix, GLib
from PyQt6.QtCore import (
    QLockFile,
    QRect,
    QSize,
    QStandardPaths,
    Qt,
    QThread,
    QTimer,
    QUrl,
    pyqtSignal,
)
from PyQt6.QtGui import (
    QDesktopServices,
    QFont,
    QFontMetrics,
    QIcon,
    QKeySequence,
    QPalette,
    QShortcut,
)
from PyQt6.QtNetwork import QLocalServer, QLocalSocket
from PyQt6.QtWidgets import (
    QApplication,
    QComboBox,
    QFrame,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListView,
    QListWidget,
    QListWidgetItem,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QSizePolicy,
    QSplitter,
    QStyle,
    QStyledItemDelegate,
    QVBoxLayout,
    QWidget,
)


def collect_apps():
    entries = []
    commands = set()
    for app in Gio.AppInfo.get_all():
        if not isinstance(app, GioUnix.DesktopAppInfo) or not app.should_show():
            continue
        executable = app.get_executable() or ""
        command = Path(executable).name
        if command and command not in {"env", "sh", "bash", "zsh", "flatpak"}:
            commands.add(command)
        categories = (app.get_categories() or "").split(";")
        category = next(
            (label for key, label in CATEGORIES.items() if key in categories),
            "Utilities",
        )
        icon = app.get_icon()
        icon_name = "application-x-executable"
        if isinstance(icon, Gio.ThemedIcon):
            icon_name = next(iter(icon.get_names()), icon_name)
        elif isinstance(icon, Gio.FileIcon):
            icon_name = icon.get_file().get_path() or icon_name
        entries.append(
            Entry(
                app.get_display_name(),
                app.get_description() or app.get_generic_name() or category,
                "Applications",
                category,
                icon_name,
                desktop_file=app.get_filename(),
                keywords=" ".join(app.get_keywords() or []) + " " + executable,
            )
        )
    return entries, commands


class Loader(QThread):
    loaded = pyqtSignal(list, str)

    def run(self):
        entries = []
        warning = ""
        try:
            entries, commands = collect_apps()
            config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
            try:
                packages = json.loads(
                    (config / "software-library/packages.json").read_text()
                )
            except (OSError, ValueError) as error:
                packages = []
                warning = f"Package descriptions could not be loaded: {error}"
            entries.extend(collect_tools(packages, commands))
            entries.sort(
                key=lambda entry: (entry.kind != "Applications", entry.name.casefold())
            )
        except (
            OSError,
            ValueError,
            TypeError,
            KeyError,
            RuntimeError,
            GLib.Error,
        ) as error:
            warning = f"Could not finish loading software: {error}"
        self.loaded.emit(entries, warning)


class Cards(QStyledItemDelegate):
    def paint(self, painter, option, index):
        entry = index.data(Qt.ItemDataRole.UserRole)
        painter.save()
        rect = option.rect.adjusted(5, 5, -5, -5)
        palette = option.palette
        selected = bool(option.state & QStyle.StateFlag.State_Selected)
        hovered = bool(option.state & QStyle.StateFlag.State_MouseOver)
        painter.setPen(palette.color(QPalette.ColorRole.Mid))
        painter.setBrush(
            palette.highlight()
            if selected
            else palette.alternateBase()
            if hovered
            else palette.base()
        )
        painter.drawRoundedRect(rect, 8, 8)
        icon = (
            QIcon(entry.icon)
            if os.path.isabs(entry.icon)
            else QIcon.fromTheme(entry.icon)
        )
        if icon.isNull():
            icon = QIcon.fromTheme("application-x-executable")
        icon.paint(painter, QRect(rect.left() + 14, rect.top() + 14, 40, 40))
        painter.setPen(
            palette.color(
                QPalette.ColorRole.HighlightedText
                if selected
                else QPalette.ColorRole.Text
            )
        )
        font = QFont(option.font)
        font.setBold(True)
        painter.setFont(font)
        title = QFontMetrics(font).elidedText(
            entry.name, Qt.TextElideMode.ElideRight, rect.width() - 80
        )
        painter.drawText(
            QRect(rect.left() + 66, rect.top() + 12, rect.width() - 80, 42),
            Qt.AlignmentFlag.AlignVCenter,
            title,
        )
        painter.setFont(option.font)
        metrics = QFontMetrics(option.font)
        description = metrics.elidedText(
            entry.description, Qt.TextElideMode.ElideRight, rect.width() - 28
        )
        painter.drawText(
            rect.adjusted(14, 64, -14, -30), Qt.AlignmentFlag.AlignTop, description
        )
        font.setBold(False)
        font.setPointSizeF(max(8, option.font.pointSizeF() - 1))
        painter.setFont(font)
        label = f"{'App' if entry.kind == 'Applications' else 'CLI'} · {entry.category}"
        painter.drawText(
            rect.adjusted(14, rect.height() - 29, -14, -8),
            Qt.AlignmentFlag.AlignVCenter,
            label,
        )
        if option.state & QStyle.StateFlag.State_HasFocus:
            painter.setBrush(Qt.BrushStyle.NoBrush)
            painter.setPen(palette.color(QPalette.ColorRole.Highlight))
            painter.drawRoundedRect(rect.adjusted(2, 2, -2, -2), 6, 6)
        painter.restore()


def label(text="", bold=False):
    widget = QLabel(text)
    widget.setTextFormat(Qt.TextFormat.PlainText)
    widget.setWordWrap(True)
    if bold:
        font = widget.font()
        font.setBold(True)
        widget.setFont(font)
    return widget


class Library(QMainWindow):
    def __init__(self):
        super().__init__()
        self.entries = []
        self.setWindowTitle("Software Library")
        self.setWindowIcon(QIcon.fromTheme("applications-all"))
        self.resize(1180, 780)
        self.setMinimumSize(720, 500)
        root = QWidget()
        self.setCentralWidget(root)
        layout = QVBoxLayout(root)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(14)
        header = QHBoxLayout()
        heading = label("Software Library", True)
        font = heading.font()
        font.setPointSizeF(font.pointSizeF() * 1.6)
        heading.setFont(font)
        header.addWidget(heading)
        header.addStretch()
        self.refresh = QPushButton(QIcon.fromTheme("view-refresh"), "Refresh")
        self.refresh.clicked.connect(self.reload)
        header.addWidget(self.refresh)
        layout.addLayout(header)
        layout.addWidget(
            label(
                "Explore the applications and terminal tools installed on your computer."
            )
        )
        search_row = QHBoxLayout()
        self.search = QLineEdit()
        self.search.setPlaceholderText("Search names, descriptions and commands…")
        self.search.setClearButtonEnabled(True)
        self.search.setAccessibleName("Search software")
        self.search.textChanged.connect(self.filter)
        search_row.addWidget(self.search, 1)
        self.kind = QComboBox()
        self.kind.addItems(["All software", "Applications", "CLI tools"])
        self.kind.setAccessibleName("Software type")
        self.kind.currentTextChanged.connect(self.filter)
        search_row.addWidget(self.kind)
        layout.addLayout(search_row)
        splitter = QSplitter()
        self.categories = QListWidget()
        self.categories.setAccessibleName("Categories")
        self.categories.setMinimumWidth(160)
        self.categories.setMaximumWidth(230)
        self.categories.currentTextChanged.connect(self.filter)
        splitter.addWidget(self.categories)
        self.grid = QListWidget()
        self.grid.setAccessibleName("Installed software")
        self.grid.setViewMode(QListView.ViewMode.IconMode)
        self.grid.setResizeMode(QListView.ResizeMode.Adjust)
        self.grid.setMovement(QListView.Movement.Static)
        self.grid.setGridSize(QSize(270, 140))
        self.grid.setUniformItemSizes(True)
        self.grid.setWordWrap(True)
        self.grid.setMouseTracking(True)
        self.grid.setItemDelegate(Cards(self.grid))
        self.grid.currentItemChanged.connect(self.select)
        self.grid.itemActivated.connect(self.activate)
        splitter.addWidget(self.grid)
        splitter.setStretchFactor(1, 1)
        layout.addWidget(splitter, 1)
        self.empty = label("Loading installed software…")
        layout.addWidget(self.empty)
        self.detail = QFrame()
        self.detail.setFrameShape(QFrame.Shape.StyledPanel)
        details = QVBoxLayout(self.detail)
        self.name = label(bold=True)
        self.description = label()
        self.description.setTextInteractionFlags(
            Qt.TextInteractionFlag.TextSelectableByMouse
        )
        details.addWidget(self.name)
        details.addWidget(self.description)
        actions = QHBoxLayout()
        self.commands = QComboBox()
        self.commands.setAccessibleName("Command")
        self.commands.setSizePolicy(
            QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed
        )
        actions.addWidget(self.commands, 1)
        self.copy = QPushButton(QIcon.fromTheme("edit-copy"), "Copy command")
        self.copy.clicked.connect(self.copy_command)
        actions.addWidget(self.copy)
        self.website = QPushButton(QIcon.fromTheme("help-browser"), "Website")
        self.website.clicked.connect(self.open_website)
        actions.addWidget(self.website)
        self.open = QPushButton()
        self.open.clicked.connect(self.activate)
        actions.addWidget(self.open)
        details.addLayout(actions)
        self.hint = label()
        details.addWidget(self.hint)
        layout.addWidget(self.detail)
        self.detail.hide()
        self.warning = label()
        layout.addWidget(self.warning)
        self.warning.hide()
        self.count = label()
        layout.addWidget(self.count)
        QShortcut(QKeySequence("Ctrl+F"), self, activated=self.search.setFocus)
        QShortcut(QKeySequence("Escape"), self, activated=self.close)
        QShortcut(QKeySequence("F5"), self, activated=self.reload)
        self.loader = Loader(self)
        self.loader.loaded.connect(self.loaded)
        self.search.setFocus()
        QTimer.singleShot(0, self.reload)

    def reload(self):
        if self.loader.isRunning():
            return
        self.refresh.setEnabled(False)
        self.count.setText("Loading installed software…")
        self.loader.start()

    def loaded(self, entries, warning):
        self.entries = entries
        previous = self.categories.currentItem()
        category = previous.text() if previous else "All categories"
        self.categories.blockSignals(True)
        self.categories.clear()
        categories = ["All categories", *sorted({entry.category for entry in entries})]
        self.categories.addItems(categories)
        self.categories.setCurrentRow(
            categories.index(category) if category in categories else 0
        )
        self.categories.blockSignals(False)
        self.warning.setText(warning)
        self.warning.setVisible(bool(warning))
        self.refresh.setEnabled(True)
        self.filter()

    def filter(self):
        category = self.categories.currentItem()
        category = category.text() if category else "All categories"
        kind = self.kind.currentText()
        self.grid.clear()
        for entry in self.entries:
            if kind != "All software" and entry.kind != kind:
                continue
            if category != "All categories" and entry.category != category:
                continue
            if not entry.matches(self.search.text()):
                continue
            item = QListWidgetItem(entry.name)
            item.setData(Qt.ItemDataRole.UserRole, entry)
            item.setData(Qt.ItemDataRole.AccessibleDescriptionRole, entry.description)
            item.setToolTip(f"{entry.name}\n{entry.description}")
            item.setSizeHint(QSize(270, 140))
            self.grid.addItem(item)
        count = self.grid.count()
        self.count.setText(
            f"{count} shown · {sum(e.kind == 'Applications' for e in self.entries)} applications · {sum(e.kind == 'CLI tools' for e in self.entries)} CLI tools / toolsets"
        )
        self.empty.setText(
            "No software matches these filters. Try another search or category."
        )
        self.empty.setVisible(count == 0)
        if count:
            self.grid.setCurrentRow(0)
        else:
            self.detail.hide()

    def selected(self):
        item = self.grid.currentItem()
        return item.data(Qt.ItemDataRole.UserRole) if item else None

    def select(self, current, _previous):
        if current is None:
            self.detail.hide()
            return
        entry = current.data(Qt.ItemDataRole.UserRole)
        self.name.setText(entry.name)
        self.description.setText(entry.description)
        cli = entry.kind == "CLI tools"
        self.commands.clear()
        self.commands.addItems(entry.commands)
        self.commands.setVisible(cli)
        self.copy.setVisible(cli)
        self.website.setVisible(QUrl(entry.homepage).scheme() in {"https", "http"})
        self.open.setText("Open terminal" if cli else "Launch application")
        self.open.setIcon(
            QIcon.fromTheme("utilities-terminal" if cli else "media-playback-start")
        )
        self.hint.setText(
            "Choose a command to copy, or open a terminal with the command shown for reference."
            if cli
            else f"{entry.category} · Double-click a card or press Enter to launch."
        )
        self.detail.show()

    def copy_command(self):
        QApplication.clipboard().setText(shlex.quote(self.commands.currentText()))

    def open_website(self):
        entry = self.selected()
        if entry and QUrl(entry.homepage).scheme() in {"https", "http"}:
            QDesktopServices.openUrl(QUrl(entry.homepage))

    def activate(self, *_args):
        entry = self.selected()
        if entry is None:
            return
        try:
            if entry.desktop_file:
                app = GioUnix.DesktopAppInfo.new_from_filename(entry.desktop_file)
                if app is None or not app.launch([], None):
                    raise RuntimeError(
                        "The application could not be launched. Refresh the library and try again."
                    )
            else:
                command = shlex.quote(self.commands.currentText())
                subprocess.Popen(
                    [
                        "ghostty",
                        "-e",
                        "zsh",
                        "-i",
                        "-c",
                        'print -r -- "Command: $1"; print; exec zsh -i',
                        "software-library",
                        command,
                    ],
                    start_new_session=True,
                )
        except (OSError, RuntimeError, GLib.Error) as error:
            QMessageBox.warning(self, "Could not open software", str(error))

    def closeEvent(self, event):
        self.loader.wait()
        event.accept()


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("software-library")
    app.setDesktopFileName("software-library")
    runtime = QStandardPaths.writableLocation(
        QStandardPaths.StandardLocation.RuntimeLocation
    )
    address = str(Path(runtime) / "software-library.socket")
    client = QLocalSocket()
    client.connectToServer(address)
    if client.waitForConnected(250):
        client.disconnectFromServer()
        return 0
    lock = QLockFile(address + ".lock")
    if not lock.tryLock(100):
        return 0
    QLocalServer.removeServer(address)
    server = QLocalServer()
    server.setSocketOptions(QLocalServer.SocketOption.UserAccessOption)
    if not server.listen(address):
        QMessageBox.warning(None, "Software Library", server.errorString())
        return 1
    window = Library()

    def show_window():
        connection = server.nextPendingConnection()
        if connection:
            connection.close()
            connection.deleteLater()
        window.showNormal()
        window.raise_()
        window.activateWindow()
        window.search.setFocus()

    server.newConnection.connect(show_window)
    window.show()
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
