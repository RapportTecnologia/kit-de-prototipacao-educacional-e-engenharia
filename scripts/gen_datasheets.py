#!/usr/bin/env python3

from __future__ import annotations

import pathlib
from urllib.parse import quote


REPO_BLOB_BASE = "https://github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia/blob/main/"
DATASHEETS_DIR_NAME = "datasheets"


def _blob_url(relpath: str) -> str:
    return REPO_BLOB_BASE + quote(relpath)


def _group_key(relpath: str) -> str:
    p = pathlib.Path(relpath)
    try:
        rel = p.relative_to(DATASHEETS_DIR_NAME)
    except Exception:
        rel = p

    if rel.parent == pathlib.Path("."):
        return "Geral"
    return rel.parent.parts[0]


def _title_from_path(path: pathlib.Path) -> str:
    t = path.stem.replace("_", " ").strip()
    return t or path.name


def main() -> None:
    repo_root = pathlib.Path(__file__).resolve().parents[1]
    base_dir = repo_root / DATASHEETS_DIR_NAME
    out_md = repo_root / "docs" / "datasheets.md"

    pdfs = sorted([p for p in base_dir.rglob("*") if p.is_file() and p.suffix.lower() == ".pdf"] )

    relpaths = [str(p.relative_to(repo_root)) for p in pdfs]
    relpaths.sort(key=lambda rp: (_group_key(rp).lower(), pathlib.Path(rp).stem.lower()))

    lines: list[str] = []
    lines.extend(
        [
            "---",
            "layout: page",
            'title: "Datasheets"',
            'subtitle: "Documentos técnicos por componente/categoria"',
            "permalink: /datasheets/",
            "is_category: true",
            "---",
            "",
            "Os datasheets ficam na pasta `datasheets/` no repositório.",
            "",
        ]
    )

    current_group: str | None = None
    for relpath in relpaths:
        group = _group_key(relpath)
        if group != current_group:
            if current_group is not None:
                lines.append("")
            current_group = group
            lines.append(f"## {group}")
            lines.append("")

        p = pathlib.Path(relpath)
        title = _title_from_path(p)
        lines.append(f"- [{title}]({_blob_url(relpath)})")

    lines.append("")
    out_md.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    main()
