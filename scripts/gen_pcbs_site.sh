#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
project_dir="${repo_root}/kicad/KEPR"

out_root="${repo_root}/docs/assets/img/pcbs"
mkdir -p "${out_root}"

rm -rf "${out_root:?}"/*

slugify() {
  local s
  s="${1,,}"
  s="$(printf '%s' "${s}" | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"
  if [ -z "${s}" ]; then
    s="pcb"
  fi
  printf '%s' "${s}"
}

mapfile -t pcbs < <(find "${project_dir}" -maxdepth 1 -type f -name '*.kicad_pcb' ! -name '*.kicad_pcb.lck' -printf '%f\n' | sort)

if [ "${#pcbs[@]}" -eq 0 ]; then
  echo "No .kicad_pcb found under ${project_dir}" >&2
  exit 1
fi

for pcb_file in "${pcbs[@]}"; do
  base="${pcb_file%.kicad_pcb}"
  slug="$(slugify "${base}")"

  in_pcb="${project_dir}/${pcb_file}"
  out_dir="${out_root}/${slug}"
  mkdir -p "${out_dir}"

  kicad-cli pcb export svg \
    --mode-single \
    --layers "F.Cu,F.SilkS,Edge.Cuts" \
    --output "${out_dir}/pcb.svg" \
    "${in_pcb}"

  kicad-cli pcb render \
    --output "${out_dir}/top-3d.png" \
    --width 1600 \
    --height 900 \
    --side top \
    --perspective \
    --background transparent \
    --quality high \
    --floor \
    "${in_pcb}" || true

  kicad-cli pcb render \
    --output "${out_dir}/bottom-3d.png" \
    --width 1600 \
    --height 900 \
    --side bottom \
    --perspective \
    --background transparent \
    --quality high \
    --floor \
    "${in_pcb}" || true

  if [ "${base}" = "KEPR" ]; then
    mkdir -p "${repo_root}/docs/assets/img"
    cp -f "${out_dir}/pcb.svg" "${repo_root}/docs/assets/img/kepr-pcb.svg"
    if [ -f "${out_dir}/top-3d.png" ]; then
      cp -f "${out_dir}/top-3d.png" "${repo_root}/docs/assets/img/kepr-pcb-top-3d.png"
    fi
    if [ -f "${out_dir}/bottom-3d.png" ]; then
      cp -f "${out_dir}/bottom-3d.png" "${repo_root}/docs/assets/img/kepr-pcb-bottom-3d.png"
    fi
  fi

done

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; cannot generate docs/pcb.md" >&2
  exit 1
fi

export PROJECT_DIR="${project_dir}"
export OUT_MD="${repo_root}/docs/pcb.md"

python3 - <<'PY'
import os
import re
from pathlib import Path

PROJECT_DIR = Path(os.environ['PROJECT_DIR'])
OUT_MD = Path(os.environ['OUT_MD'])


def slugify(name: str) -> str:
    s = name.strip().lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    s = re.sub(r'-+', '-', s).strip('-')
    return s or 'pcb'


pcbs = sorted([p for p in PROJECT_DIR.glob('*.kicad_pcb') if not str(p).endswith('.kicad_pcb.lck')])

items = []
for pcb in pcbs:
    base = pcb.stem
    slug = slugify(base)
    items.append((base, slug))

md = []
md.append('---')
md.append('layout: page')
md.append('title: "PCB"')
md.append('subtitle: "Imagens geradas automaticamente a partir do KiCad"')
md.append('permalink: /pcb/')
md.append('is_category: true')
md.append('---')
md.append('')
md.append('## Lista de PCBs')
md.append('')
for base, slug in items:
    md.append(f'- <a href="#pcb-{slug}">{base}</a>')
md.append('')

for base, slug in items:
    md.append(f'## {base}')
    md.append('')
    md.append(f'<a id="pcb-{slug}"></a>')
    md.append('')
    md.append('### Visão 2D (SVG)')
    md.append('')
    md.append('<div style="max-width: 1100px; margin: 0 auto;">')
    md.append(f'  <img src="{{{{ "/assets/img/pcbs/{slug}/pcb.svg" | relative_url }}}}" alt="{base} (SVG)" style="width: 100%; height: auto; display: block;" />')
    md.append('</div>')
    md.append('')
    md.append('### Render 3D (PNG)')
    md.append('')
    md.append('<div style="max-width: 1100px; margin: 0 auto;">')
    md.append(f'  <img src="{{{{ "/assets/img/pcbs/{slug}/top-3d.png" | relative_url }}}}" alt="{base} Top (3D)" style="width: 100%; height: auto; display: block;" />')
    md.append('</div>')
    md.append('')
    md.append('<div style="max-width: 1100px; margin: 0 auto;">')
    md.append(f'  <img src="{{{{ "/assets/img/pcbs/{slug}/bottom-3d.png" | relative_url }}}}" alt="{base} Bottom (3D)" style="width: 100%; height: auto; display: block;" />')
    md.append('</div>')
    md.append('')

OUT_MD.write_text('\n'.join(md) + '\n', encoding='utf-8')
PY
