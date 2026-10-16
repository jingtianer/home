#!/usr/bin/env python3
"""
Bundle an HTML page and its local CSS, JavaScript, images, and audio into one file.

Examples:
  python3 merge_assets_to_single_html.py 奶娃科学院.html
  python3 merge_assets_to_single_html.py 奶娃科学院.html -o base64-src/奶娃科学院-base64.html
"""

from __future__ import annotations

import argparse
import base64
import mimetypes
import re
from pathlib import Path
from typing import Callable
from urllib.parse import unquote, urlsplit


TEXT_EXTENSIONS = {".css", ".js", ".html", ".htm", ".svg"}
ASSET_EXTENSIONS = {
    ".apng",
    ".avif",
    ".bmp",
    ".gif",
    ".ico",
    ".jpeg",
    ".jpg",
    ".m4a",
    ".mp3",
    ".ogg",
    ".opus",
    ".png",
    ".svg",
    ".wav",
    ".webp",
}


def is_external_url(value: str) -> bool:
    value = value.strip()
    if not value:
        return True
    lowered = value.lower()
    if lowered.startswith(("data:", "http://", "https://", "//", "mailto:", "tel:", "javascript:", "blob:", "cid:")):
        return True
    return lowered.startswith("#")


def split_url_suffix(value: str) -> tuple[str, str]:
    match = re.match(r"^([^?#]*)([?#].*)?$", value, flags=re.S)
    if not match:
        return value, ""
    return match.group(1), match.group(2) or ""


def resolve_local_path(raw_url: str, base_dir: Path) -> Path | None:
    raw_url = raw_url.strip()
    if is_external_url(raw_url):
        return None

    parsed = urlsplit(raw_url)
    if parsed.scheme or parsed.netloc:
        return None

    path_part, _ = split_url_suffix(parsed.path)
    if not path_part:
        return None

    path = (base_dir / unquote(path_part)).resolve()
    if path.is_file():
        return path
    return None


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def guess_mime(path: Path) -> str:
    mime, _ = mimetypes.guess_type(path.name)
    if mime:
        return mime
    if path.suffix.lower() == ".svg":
        return "image/svg+xml"
    return "application/octet-stream"


def file_to_data_url(path: Path) -> str:
    encoded = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:{guess_mime(path)};base64,{encoded}"


def escape_script_end(text: str) -> str:
    return re.sub(r"</script", r"<\/script", text, flags=re.I)


def replace_css_urls(css: str, css_dir: Path, embedder: Callable[[str, Path], str]) -> str:
    url_pattern = re.compile(r"url\(\s*(['\"]?)(.*?)\1\s*\)", flags=re.I | re.S)
    import_pattern = re.compile(
        r"@import\s+(?:url\(\s*)?(['\"])(.*?)\1\s*\)?\s*([^;]*);",
        flags=re.I | re.S,
    )

    def replace_import(match: re.Match[str]) -> str:
        url = match.group(2).strip()
        path = resolve_local_path(url, css_dir)
        if not path or path.suffix.lower() != ".css":
            return match.group(0)
        imported = read_text(path)
        return replace_css_urls(imported, path.parent, embedder)

    def replace_url(match: re.Match[str]) -> str:
        quote = match.group(1) or '"'
        url = match.group(2).strip()
        if is_external_url(url):
            return match.group(0)
        embedded = embedder(url, css_dir)
        return f"url({quote}{embedded}{quote})"

    css = import_pattern.sub(replace_import, css)
    return url_pattern.sub(replace_url, css)


def replace_asset_strings(text: str, base_dir: Path, embedder: Callable[[str, Path], str]) -> str:
    quoted_path_pattern = re.compile(
        r"(?P<quote>['\"])(?P<url>(?:\.{1,2}/|/)?[^'\"\n\r]+?\.(?:"
        + "|".join(ext.lstrip(".") for ext in sorted(ASSET_EXTENSIONS))
        + r")(?:[?#][^'\"\n\r]*)?)(?P=quote)",
        flags=re.I,
    )

    def replace(match: re.Match[str]) -> str:
        quote = match.group("quote")
        url = match.group("url")
        if is_external_url(url):
            return match.group(0)
        return f"{quote}{embedder(url, base_dir)}{quote}"

    return quoted_path_pattern.sub(replace, text)


def make_embedder(root_dir: Path) -> Callable[[str, Path], str]:
    cache: dict[Path, str] = {}

    def embed(url: str, base_dir: Path) -> str:
        path = resolve_local_path(url, base_dir)
        if not path:
            return url
        suffix = path.suffix.lower()
        if suffix not in ASSET_EXTENSIONS:
            return url
        if path not in cache:
            cache[path] = file_to_data_url(path)
        return cache[path]

    return embed


def inline_stylesheets(html: str, html_dir: Path, embedder: Callable[[str, Path], str]) -> str:
    link_pattern = re.compile(r"<link\b(?P<attrs>[^>]*?)>", flags=re.I | re.S)

    def replace(match: re.Match[str]) -> str:
        tag = match.group(0)
        attrs = match.group("attrs")
        href_match = re.search(r"\bhref\s*=\s*(['\"])(.*?)\1", attrs, flags=re.I | re.S)
        if not href_match:
            return tag
        href = href_match.group(2).strip()
        rel_match = re.search(r"\brel\s*=\s*(['\"])(.*?)\1", attrs, flags=re.I | re.S)
        type_match = re.search(r"\btype\s*=\s*(['\"])(.*?)\1", attrs, flags=re.I | re.S)
        rel = rel_match.group(2).lower() if rel_match else ""
        type_value = type_match.group(2).lower() if type_match else ""
        is_stylesheet = "stylesheet" in rel or type_value == "text/css" or href.lower().endswith(".css")
        if not is_stylesheet:
            return tag
        path = resolve_local_path(href, html_dir)
        if not path:
            return tag
        css = replace_css_urls(read_text(path), path.parent, embedder)
        return f"<style>\n{css}\n</style>"

    return link_pattern.sub(replace, html)


def inline_scripts(html: str, html_dir: Path, embedder: Callable[[str, Path], str]) -> str:
    script_pattern = re.compile(
        r"<script\b(?P<attrs>[^>]*)\bsrc\s*=\s*(['\"])(?P<src>.*?)\2(?P<tail>[^>]*)>\s*</script>",
        flags=re.I | re.S,
    )

    def replace(match: re.Match[str]) -> str:
        src = match.group("src").strip()
        path = resolve_local_path(src, html_dir)
        if not path or path.suffix.lower() != ".js":
            return match.group(0)
        js = read_text(path)
        js = replace_asset_strings(js, html_dir, embedder)
        js = escape_script_end(js)
        attrs = (match.group("attrs") + match.group("tail")).strip()
        attrs = re.sub(r"\s*\bsrc\s*=\s*(['\"]).*?\1", "", attrs, flags=re.I | re.S).strip()
        return f"<script{(' ' + attrs) if attrs else ''}>\n{js}\n</script>"

    return script_pattern.sub(replace, html)


def replace_html_asset_attributes(html: str, html_dir: Path, embedder: Callable[[str, Path], str]) -> str:
    attr_pattern = re.compile(
        r"(?P<name>\b(?:src|poster|href)\s*=\s*)(?P<quote>['\"])(?P<url>.*?)(?P=quote)",
        flags=re.I | re.S,
    )
    style_pattern = re.compile(r"(?P<prefix>\bstyle\s*=\s*)(?P<quote>['\"])(?P<css>.*?)(?P=quote)", flags=re.I | re.S)
    srcset_pattern = re.compile(r"(?P<prefix>\bsrcset\s*=\s*)(?P<quote>['\"])(?P<value>.*?)(?P=quote)", flags=re.I | re.S)

    def replace_attr(match: re.Match[str]) -> str:
        url = match.group("url").strip()
        path = resolve_local_path(url, html_dir)
        if not path or path.suffix.lower() not in ASSET_EXTENSIONS:
            return match.group(0)
        return f"{match.group('name')}{match.group('quote')}{embedder(url, html_dir)}{match.group('quote')}"

    def replace_style(match: re.Match[str]) -> str:
        css = replace_css_urls(match.group("css"), html_dir, embedder)
        return f"{match.group('prefix')}{match.group('quote')}{css}{match.group('quote')}"

    def replace_srcset(match: re.Match[str]) -> str:
        parts = []
        for item in match.group("value").split(","):
            item = item.strip()
            if not item:
                continue
            pieces = item.split()
            pieces[0] = embedder(pieces[0], html_dir)
            parts.append(" ".join(pieces))
        return f"{match.group('prefix')}{match.group('quote')}{', '.join(parts)}{match.group('quote')}"

    html = attr_pattern.sub(replace_attr, html)
    html = srcset_pattern.sub(replace_srcset, html)
    return style_pattern.sub(replace_style, html)


def bundle_html(input_path: Path, output_path: Path) -> None:
    input_path = input_path.resolve()
    output_path = output_path.resolve()
    html_dir = input_path.parent
    embedder = make_embedder(html_dir)

    html = read_text(input_path)
    html = inline_stylesheets(html, html_dir, embedder)
    html = inline_scripts(html, html_dir, embedder)
    html = replace_html_asset_attributes(html, html_dir, embedder)
    html = replace_asset_strings(html, html_dir, embedder)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(html, encoding="utf-8")


def default_output_path(input_path: Path) -> Path:
    return input_path.parent / "output" / (f"{input_path.stem}-base64{input_path.suffix}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Merge a local HTML page with local CSS, JS, image, and audio assets into a single HTML file.",
    )
    parser.add_argument("input", type=Path, help="source HTML file")
    parser.add_argument("-o", "--output", type=Path, help="output HTML file")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    input_path = args.input
    if not input_path.is_file():
        raise SystemExit(f"Input file not found: {input_path}")
    output_path = args.output or default_output_path(input_path)
    bundle_html(input_path, output_path)
    print(f"Wrote {output_path}")


if __name__ == "__main__":
    main()
