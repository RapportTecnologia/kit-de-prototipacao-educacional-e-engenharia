#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"

project_dir="${repo_root}/kicad/KEPR"

bom_dir="${repo_root}/docs/assets/bom"
mkdir -p "${bom_dir}"

rm -f "${bom_dir}"/*.csv

mapfile -t pcbs < <(find "${project_dir}" -maxdepth 1 -type f -name '*.kicad_pcb' ! -name '*.kicad_pcb.lck' -printf '%f\n' | sort)

if [ "${#pcbs[@]}" -eq 0 ]; then
  echo "No .kicad_pcb found under ${project_dir}" >&2
  exit 1
fi

declare -a bom_csvs=()

for pcb_file in "${pcbs[@]}"; do
  base="${pcb_file%.kicad_pcb}"
  sch="${project_dir}/${base}.kicad_sch"
  if [ ! -f "${sch}" ]; then
    continue
  fi

  out_csv="${bom_dir}/${base}-bom.csv"
  kicad-cli sch export bom \
    --output "${out_csv}" \
    "${sch}"
  bom_csvs+=("${out_csv}")
done

if [ "${#bom_csvs[@]}" -eq 0 ]; then
  echo "No schematic BOMs could be generated (no matching .kicad_sch for .kicad_pcb) under ${project_dir}" >&2
  exit 1
fi

agg_csv="${bom_dir}/ALL-bom.csv"

if command -v python3 >/dev/null 2>&1; then
  export BOM_CSVS="$(printf '%s\n' "${bom_csvs[@]}")"
  export BOM_AGG_CSV="${agg_csv}"
  bom_table_html="$(python3 - <<'PY'
import csv
import html
import os

csv_paths = [p for p in os.environ['BOM_CSVS'].splitlines() if p.strip()]
agg_path = os.environ['BOM_AGG_CSV']


def read_csv(path: str):
    with open(path, newline='', encoding='utf-8', errors='replace') as f:
        reader = csv.reader(f)
        rows = list(reader)
    if not rows:
        return [], []
    header = rows[0]
    body = rows[1:]
    return header, body


expected_header = ['Refs', 'Value', 'Footprint', 'Qty', 'DNP']
agg = {}

for p in csv_paths:
    header, body = read_csv(p)
    if header != expected_header:
        raise SystemExit(f'Unexpected BOM header in {p}: {header} (expected {expected_header})')
    board = os.path.basename(p).replace('-bom.csv', '')

    for r in body:
        refs = r[0] if len(r) > 0 else ''
        value = r[1] if len(r) > 1 else ''
        footprint = r[2] if len(r) > 2 else ''
        qty_s = r[3] if len(r) > 3 else '0'
        dnp = r[4] if len(r) > 4 else ''

        try:
            qty = int(qty_s)
        except Exception:
            qty = 0

        key = (value, footprint, dnp)
        entry = agg.get(key)
        if entry is None:
            entry = {
                'qty': 0,
                'refs': [],
            }
            agg[key] = entry

        entry['qty'] += qty
        if refs:
            entry['refs'].append(f'{board}:{refs}')


out_rows = [expected_header]
for (value, footprint, dnp), entry in sorted(agg.items(), key=lambda x: (x[0][0], x[0][1], x[0][2])):
    refs_joined = ';'.join(entry['refs'])
    out_rows.append([refs_joined, value, footprint, str(entry['qty']), dnp])


with open(agg_path, 'w', newline='', encoding='utf-8') as f:
    w = csv.writer(f, quoting=csv.QUOTE_ALL)
    for r in out_rows:
        w.writerow(r)

with open(agg_path, newline='', encoding='utf-8', errors='replace') as f:
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
