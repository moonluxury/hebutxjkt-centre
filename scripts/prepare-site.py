"""Validate local HTML links and copy only public website files for deployment."""

import argparse
from html.parser import HTMLParser
from pathlib import Path
import shutil
from urllib.parse import unquote, urlsplit


class LocalLinks(HTMLParser):
    def __init__(self):
        super().__init__()
        self.paths = set()

    def handle_starttag(self, tag, attrs):
        for name, value in attrs:
            if name not in {"src", "href"} or not value:
                continue
            url = urlsplit(value)
            if not url.scheme and not url.netloc and url.path:
                self.paths.add(unquote(url.path))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", default="_site", help="A new output directory")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = (root / args.output).resolve()
    if output.exists():
        raise SystemExit(f"Output already exists; choose a new directory: {output}")
    if any(output.is_relative_to(root / name) for name in ["assets", "js", "styles"]):
        raise SystemExit("Output must be outside the website's source directories")

    entries = ["index.html", "assets", "js", "styles"]
    for name in entries:
        path = root / name
        valid = path.is_file() if name == "index.html" else path.is_dir()
        if not valid:
            raise SystemExit(f"Missing website file or directory: {name}")

    links = LocalLinks()
    links.feed((root / "index.html").read_text(encoding="utf-8-sig"))
    missing = []
    for name in sorted(links.paths):
        path = (root / name).resolve()
        if not path.is_relative_to(root) or not path.is_file():
            missing.append(name)
    if missing:
        raise SystemExit("Broken local links:\n" + "\n".join(missing))

    output.mkdir(parents=True)
    for name in entries:
        source = root / name
        if source.is_dir():
            shutil.copytree(source, output / name)
        else:
            shutil.copy2(source, output / name)
    (output / ".nojekyll").touch()
    print(f"Checked {len(links.paths)} local links. Website prepared in {output}")


if __name__ == "__main__":
    main()
