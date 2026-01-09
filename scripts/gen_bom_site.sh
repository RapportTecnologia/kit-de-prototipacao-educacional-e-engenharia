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

bom_dir="${repo_root}/docs/assets/bom"
mkdir -p "${bom_dir}"

bom_csv="${bom_dir}/${project_name}-bom.csv"

kicad-cli sch export bom \
  --output "${bom_csv}" \
  "${root_sch}"

if command -v python3 >/dev/null 2>&1; then
  export BOM_CSV="${bom_csv}"
  bom_table_html="$(python3 - <<'PY'
import csv
import html
import os

csv_path = os.environ['BOM_CSV']

with open(csv_path, newline='', encoding='utf-8', errors='replace') as f:
    reader = csv.reader(f)
    rows = list(reader)

if not rows:
    print('<p>(BOM vazia)</p>')
    raise SystemExit(0)

header = rows[0]
body = rows[1:]

print('<div class="table-wrap">')
print('<table>')
print('<thead><tr>')
for h in header:
    print(f'<th>{html.escape(h)}</th>')
print('</tr></thead>')
print('<tbody>')
for r in body:
    print('<tr>')
    for i in range(len(header)):
        v = r[i] if i < len(r) else ''
        print(f'<td>{html.escape(v)}</td>')
    print('</tr>')
print('</tbody>')
print('</table>')
print('</div>')
PY
)"
else
  echo "python3 not found; cannot render BOM CSV into /bom page" >&2
  exit 1
fi

cat > "${repo_root}/docs/bom.md" <<EOF
---
title: "BOM"
permalink: /bom/
---

<div class="callout">
  <h1>Bill of Materials (BOM)</h1>
  <p>Esta lista BOM é gerada automaticamente pelo CI a partir do projeto KiCad.</p>
</div>

${bom_table_html}
EOF
