#!/usr/bin/env python3

from __future__ import annotations

import datetime as _dt
import pathlib
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from urllib.parse import quote


REPO_BLOB_BASE = "https://github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia/blob/main/"
GUIAS_DIR_NAME = "Guias e Livros"


@dataclass(frozen=True)
class Livro:
    title: str
    creators: list[str]
    language: str | None
    date: str | None
    subject: str | None
    opf_relpath: str
    pdf_relpath: str | None
    cover_relpath: str | None


def _first_text(parent: ET.Element, xpath: str, ns: dict[str, str]) -> str | None:
    el = parent.find(xpath, ns)
    if el is None:
        return None
    if el.text is None:
        return None
    t = el.text.strip()
    return t or None


def _all_text(parent: ET.Element, xpath: str, ns: dict[str, str]) -> list[str]:
    out: list[str] = []
    for el in parent.findall(xpath, ns):
        if el.text:
            t = el.text.strip()
            if t:
                out.append(t)
    return out


def _parse_opf(opf_path: pathlib.Path, repo_root: pathlib.Path) -> Livro:
    ns = {
        "opf": "http://www.idpf.org/2007/opf",
        "dc": "http://purl.org/dc/elements/1.1/",
    }

    root = ET.fromstring(opf_path.read_text(encoding="utf-8"))
    metadata = root.find("opf:metadata", ns)
    if metadata is None:
        raise ValueError(f"OPF sem metadata: {opf_path}")

    title = _first_text(metadata, "dc:title", ns) or opf_path.stem
    creators = _all_text(metadata, "dc:creator", ns)
    language = _first_text(metadata, "dc:language", ns)
    date = _first_text(metadata, "dc:date", ns)
    subject = _first_text(metadata, "dc:subject", ns)

    cover_relpath: str | None = None
    guide = root.find("opf:guide", ns)
    if guide is not None:
        for ref in guide.findall("opf:reference", ns):
            if ref.attrib.get("type") == "cover":
                href = ref.attrib.get("href")
                if href:
                    cover_relpath = str((opf_path.parent / href).relative_to(repo_root))
                break

    pdf_candidate = opf_path.with_suffix(".pdf")
    pdf_relpath = str(pdf_candidate.relative_to(repo_root)) if pdf_candidate.exists() else None

    return Livro(
        title=title,
        creators=creators,
        language=language,
        date=date,
        subject=subject,
        opf_relpath=str(opf_path.relative_to(repo_root)),
        pdf_relpath=pdf_relpath,
        cover_relpath=cover_relpath,
    )


def _blob_url(relpath: str) -> str:
    return REPO_BLOB_BASE + quote(relpath)


def _fmt_date(date_raw: str | None) -> str | None:
    if not date_raw:
        return None

    s = date_raw.strip()
    if not s:
        return None

    try:
        if s.endswith("Z"):
            s2 = s[:-1] + "+00:00"
        else:
            s2 = s
        dt = _dt.datetime.fromisoformat(s2)
        if dt.year < 1900:
            return ""
        return dt.date().isoformat()
    except Exception:
        return s


def _group_key(relpath: str) -> str:
    p = pathlib.Path(relpath)
    try:
        rel = p.relative_to(GUIAS_DIR_NAME)
    except Exception:
        rel = p

    if rel.parent == pathlib.Path('.'):
        return "Geral"
    return rel.parent.parts[0]


def main() -> None:
    repo_root = pathlib.Path(__file__).resolve().parents[1]
    base_dir = repo_root / GUIAS_DIR_NAME
    out_md = repo_root / "docs" / "guias-e-livros.md"

    opfs = sorted(base_dir.rglob("*.opf"))
    livros = [_parse_opf(p, repo_root) for p in opfs]

    livros.sort(key=lambda l: (_group_key(l.opf_relpath).lower(), l.title.lower()))

    lines: list[str] = []
    lines.extend(
        [
            "---",
            'layout: page',
            'title: "Guias e Livros"',
            'subtitle: "Materiais de referência usados no projeto"',
            'permalink: /guias-e-livros/',
            'is_category: true',
            "---",
            "",
            "Os materiais de referência ficam na pasta `Guias e Livros/` no repositório.",
            "",
        ]
    )

    current_group: str | None = None
    for livro in livros:
        group = _group_key(livro.opf_relpath)
        if group != current_group:
            current_group = group
            lines.append(f"## {group}")
            lines.append("")
            lines.append("| Capa | Título | Autor | Idioma | Data | Assunto | Arquivo |")
            lines.append("| --- | --- | --- | --- | --- | --- | --- |")

        cover_cell = ""
        if livro.cover_relpath:
            cover_url = _blob_url(livro.cover_relpath)
            cover_cell = f"<img src=\"{cover_url}\" alt=\"capa\" width=\"120\" />"

        creators = ", ".join(livro.creators) if livro.creators else ""
        language = livro.language or ""
        date = _fmt_date(livro.date) or ""
        subject = livro.subject or ""

        file_cell = ""
        if livro.pdf_relpath:
            file_cell = f"[PDF]({_blob_url(livro.pdf_relpath)})"
        else:
            file_cell = f"[OPF]({_blob_url(livro.opf_relpath)})"

        title_cell = livro.title
        if livro.pdf_relpath:
            title_cell = f"[{livro.title}]({_blob_url(livro.pdf_relpath)})"

        lines.append(
            "| "
            + " | ".join(
                [
                    cover_cell,
                    title_cell,
                    creators,
                    language,
                    date,
                    subject,
                    file_cell,
                ]
            )
            + " |"
        )

    lines.append("")

    out_md.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    main()
