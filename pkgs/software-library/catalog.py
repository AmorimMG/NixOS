import os
import re
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Entry:
    name: str
    description: str
    kind: str
    category: str
    icon: str
    commands: list[str] = field(default_factory=list)
    homepage: str = ""
    desktop_file: str = ""
    keywords: str = ""

    def matches(self, query):
        text = " ".join(
            [self.name, self.description, self.category, self.keywords, *self.commands]
        ).casefold()
        return all(word in text for word in query.casefold().split())


CATEGORIES = {
    "Development": "Development",
    "Network": "Internet & network",
    "AudioVideo": "Audio & video",
    "Audio": "Audio & video",
    "Video": "Audio & video",
    "Graphics": "Graphics",
    "Office": "Office",
    "Game": "Games",
    "Education": "Education & science",
    "Science": "Education & science",
    "Settings": "System",
    "System": "System",
    "Utility": "Utilities",
}


def tool_category(name, description):
    text = f"{name} {description}".casefold()
    groups = [
        (
            "Development",
            r"\b(git|compiler|debugger|development|code|programming|sdk|nix|nixos|json|python|container|kubernetes)\b",
        ),
        (
            "Internet & network",
            r"\b(network|dns|http|ssh|internet|download|vpn|packet)\b",
        ),
        ("Audio & video", r"\b(audio|video|music|media|ffmpeg)\b"),
        ("Graphics", r"\b(image|images|graphics|svg|photo)\b"),
        ("Office", r"\b(pdf|document|documents|typesetting|markdown)\b"),
        (
            "System",
            r"\b(system|disk|filesystem|process|monitor|backup|encryption|password|security)\b",
        ),
    ]
    return next(
        (category for category, pattern in groups if re.search(pattern, text)),
        "Utilities",
    )


def executable_paths(path):
    result = {}
    for directory in path.split(os.pathsep):
        if not directory or not os.path.isabs(directory):
            continue
        try:
            for candidate in Path(directory).iterdir():
                name = candidate.name
                if name.startswith(".") or name.endswith("-wrapped") or name in result:
                    continue
                if candidate.is_file() and os.access(candidate, os.X_OK):
                    result[name] = candidate.resolve()
        except OSError:
            continue
    return result


def collect_tools(packages, app_commands=(), path=None):
    available = executable_paths(os.environ.get("PATH", "") if path is None else path)
    claimed = set(app_commands)
    entries = []
    seen_packages = set()
    for package in packages:
        package_path = package["path"]
        if package_path in seen_packages:
            continue
        seen_packages.add(package_path)
        commands = []
        try:
            for candidate in (Path(package_path) / "bin").iterdir():
                name = candidate.name
                if name not in claimed and available.get(name) == candidate.resolve():
                    commands.append(name)
        except OSError:
            continue
        if not commands:
            continue
        commands.sort(
            key=lambda name: (name != package.get("mainProgram"), name.casefold())
        )
        claimed.update(commands)
        homepage = package.get("homepage", "")
        if isinstance(homepage, list):
            homepage = next(iter(homepage), "")
        description = package.get("description", "") or "Installed terminal tools"
        entries.append(
            Entry(
                package["name"],
                description,
                "CLI tools",
                tool_category(package["name"], description),
                "utilities-terminal",
                commands=commands,
                homepage=homepage,
            )
        )
    for name in sorted(available.keys() - claimed):
        entries.append(
            Entry(
                name,
                "Command available in your session",
                "CLI tools",
                "Utilities",
                "utilities-terminal",
                commands=[name],
            )
        )
    return entries
