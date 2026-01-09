#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"

kicad_pro=""
if [ -f "${repo_root}/kicad/KEPR/KEPR.kicad_pro" ]; then
  kicad_pro="${repo_root}/kicad/KEPR/KEPR.kicad_pro"
else
  kicad_pro="$(find "${repo_root}/kicad" -type f -name '*.kicad_pro' -print | head -n 1 || true)"
fi

if [ -z "${kicad_pro}" ]; then
  echo "No .kicad_pro found under kicad/" >&2
  exit 1
fi

project_dir="$(dirname "${kicad_pro}")"
project_name="$(basename "${kicad_pro}" .kicad_pro)"
root_sch="${project_dir}/${project_name}.kicad_sch"

if [ ! -f "${root_sch}" ]; then
  echo "Root schematic not found: ${root_sch}" >&2
  exit 1
fi

out_dir="${repo_root}/docs/assets/img/schematics"
mkdir -p "${out_dir}"

rm -rf "${out_dir:?}"/*

mapfile -t schematics < <(find "${project_dir}" -maxdepth 1 -type f -name '*.kicad_sch' -printf '%f\n' | sort)

for sch_file in "${schematics[@]}"; do
  base="${sch_file%.kicad_sch}"
  in_path="${project_dir}/${sch_file}"
  out_svg="${out_dir}/${base}.svg"
  tmp_dir="$(mktemp -d)"

  kicad-cli sch export svg \
    --output "${tmp_dir}" \
    "${in_path}"

  if [ ! -f "${tmp_dir}/${base}.svg" ]; then
    echo "Expected main SVG not found: ${tmp_dir}/${base}.svg" >&2
    rm -rf "${tmp_dir}"
    exit 1
  fi

  mv "${tmp_dir}/${base}.svg" "${out_svg}"
  rm -rf "${tmp_dir}"
done

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; cannot generate docs/esquematicos.md" >&2
  exit 1
fi

export ROOT_SCH="${root_sch}"
export PROJECT_DIR="${project_dir}"
export OUT_MD="${repo_root}/docs/esquematicos.md"

python3 - <<'PY'
import os
import re
from pathlib import Path

ROOT_SCH = Path(os.environ['ROOT_SCH'])
PROJECT_DIR = Path(os.environ['PROJECT_DIR'])
OUT_MD = Path(os.environ['OUT_MD'])

PAPER_SIZES_MM = {
    'A0': (1189.0, 841.0),
    'A1': (841.0, 594.0),
    'A2': (594.0, 420.0),
    'A3': (420.0, 297.0),
    'A4': (297.0, 210.0),
    'A5': (210.0, 148.0),
    'Letter': (279.4, 215.9),
    'Legal': (355.6, 215.9),
}

def slugify(name: str) -> str:
    s = name.strip().lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    s = re.sub(r'-+', '-', s).strip('-')
    return s or 'sch'


def read_text(p: Path) -> str:
    return p.read_text(encoding='utf-8', errors='replace')


def detect_paper_mm(sch_text: str):
    m = re.search(r'\(paper\s+"([^"]+)"', sch_text)
    if not m:
        return None
    paper = m.group(1)
    if paper not in PAPER_SIZES_MM:
        return None
    w, h = PAPER_SIZES_MM[paper]
    if h > w:
        w, h = h, w
    return paper, w, h


def parse_root_sheets(sch_text: str):
    paper_info = detect_paper_mm(sch_text)
    if not paper_info:
        return None, []

    _, page_w, page_h = paper_info

    sheets = []
    i = 0
    while True:
        start = sch_text.find('(sheet', i)
        if start == -1:
            break
        depth = 0
        end = None
        for j in range(start, len(sch_text)):
            c = sch_text[j]
            if c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    end = j + 1
                    break
        if end is None:
            break
        block = sch_text[start:end]

        at_m = re.search(r'\(at\s+([0-9.]+)\s+([0-9.]+)\)', block)
        size_m = re.search(r'\(size\s+([0-9.]+)\s+([0-9.]+)\)', block)
        name_m = re.search(r'\(property\s+"Sheetname"\s+"([^"]+)"', block)
        file_m = re.search(r'\(property\s+"Sheetfile"\s+"([^"]+)"', block)

        if at_m and size_m and file_m:
            x = float(at_m.group(1))
            y = float(at_m.group(2))
            w = float(size_m.group(1))
            h = float(size_m.group(2))
            sheet_name = name_m.group(1) if name_m else Path(file_m.group(1)).stem
            sheet_file = file_m.group(1)

            left = (x / page_w) * 100.0
            top = (y / page_h) * 100.0
            width = (w / page_w) * 100.0
            height = (h / page_h) * 100.0

            sheets.append({
                'name': sheet_name,
                'file': sheet_file,
                'left': left,
                'top': top,
                'width': width,
                'height': height,
            })

        i = end

    return paper_info, sheets


root_text = read_text(ROOT_SCH)
paper_info, root_sheets = parse_root_sheets(root_text)

schematics = sorted([p for p in PROJECT_DIR.glob('*.kicad_sch')])

items = []
for sch in schematics:
    base = sch.stem
    anchor = f"sch-{slugify(base)}"
    items.append((base, anchor))

md = []
md.append('---')
md.append('title: "Esquemáticos"')
md.append('permalink: /esquematicos/')
md.append('is_category: true')
md.append('---')
md.append('')
md.append('<div class="callout">')
md.append('  <p>Imagens exportadas automaticamente a partir dos esquemáticos do projeto.</p>')
md.append('</div>')
md.append('')
md.append('## Mapa')
md.append('')
for base, anchor in items:
    md.append(f'- <a href="#{anchor}">{base}</a>')
md.append('')
md.append('## Esquemáticos')
md.append('')

for base, anchor in items:
    md.append(f'### {base}')
    md.append('')
    md.append(f'<a id="{anchor}"></a>')
    md.append('')

    img_src = f'{{{{ "/assets/img/schematics/{base}.svg" | relative_url }}}}'

    if base == ROOT_SCH.stem and root_sheets:
        md.append('<div style="position: relative; width: 100%;">')
        md.append(f'<img src="{img_src}" alt="{base}" loading="lazy" style="width: 100%; height: auto; display: block;" />')
        for s in root_sheets:
            target_base = Path(s['file']).stem
            target_anchor = f"sch-{slugify(target_base)}"
            style = (
                f"position: absolute; left: {s['left']:.4f}%; top: {s['top']:.4f}%; "
                f"width: {s['width']:.4f}%; height: {s['height']:.4f}%; "
                "display: block;"
            )
            md.append(
                f'<a href="#{target_anchor}" title="{s["name"]}" '
                f'style="{style}"></a>'
            )
        md.append('</div>')
    else:
        md.append(f'<img src="{img_src}" alt="{base}" loading="lazy" style="width: 100%; height: auto;" />')

    md.append('')

OUT_MD.write_text('\n'.join(md) + '\n', encoding='utf-8')
PY
