#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"

erc_rpt="${repo_root}/kicad/KEPR/reports/erc.rpt"
drc_rpt="${repo_root}/kicad/KEPR/reports/drc.rpt"
out_md="${repo_root}/docs/relatorios-erc-drc.md"

if [ ! -f "${erc_rpt}" ]; then
  echo "ERC report not found: ${erc_rpt}" >&2
  exit 1
fi

if [ ! -f "${drc_rpt}" ]; then
  echo "DRC report not found: ${drc_rpt}" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; cannot generate ${out_md}" >&2
  exit 1
fi

export ERC_RPT="${erc_rpt}"
export DRC_RPT="${drc_rpt}"
export OUT_MD="${out_md}"

python3 - <<'PY'
import os
import re
from pathlib import Path

ERC_RPT = Path(os.environ['ERC_RPT'])
DRC_RPT = Path(os.environ['DRC_RPT'])
OUT_MD = Path(os.environ['OUT_MD'])


def read_text(p: Path) -> str:
    return p.read_text(encoding='utf-8', errors='replace')


def parse_erc(text: str):
    created = None
    m = re.search(r'^ERC report \(([^,]+),', text, flags=re.M)
    if m:
        created = m.group(1).strip()

    errors = 0
    warnings = 0
    examples = []

    cur_issue = None
    for line in text.splitlines():
        if line.startswith('['):
            cur_issue = line.strip()
            continue
        if '; error' in line:
            errors += 1
            if cur_issue and len(examples) < 10:
                examples.append(cur_issue)
            cur_issue = None
            continue
        if '; warning' in line:
            warnings += 1
            if cur_issue and len(examples) < 10:
                examples.append(cur_issue)
            cur_issue = None
            continue

    return {
        'created': created,
        'errors': errors,
        'warnings': warnings,
        'examples': examples,
    }


def parse_drc(text: str):
    created = None
    m = re.search(r'^\*\* Created on ([^*]+) \*\*$', text, flags=re.M)
    if m:
        created = m.group(1).strip()

    drc_violations = None
    m = re.search(r'^\*\* Found (\d+) DRC violations \*\*$', text, flags=re.M)
    if m:
        drc_violations = int(m.group(1))

    unconnected_pads = None
    m = re.search(r'^\*\* Found (\d+) unconnected pads \*\*$', text, flags=re.M)
    if m:
        unconnected_pads = int(m.group(1))

    errors = 0
    warnings = 0
    examples = []

    cur_issue = None
    for line in text.splitlines():
        if line.startswith('['):
            cur_issue = line.strip()
            continue
        if '; error' in line:
            errors += 1
            if cur_issue and len(examples) < 10:
                examples.append(cur_issue)
            cur_issue = None
            continue
        if '; warning' in line:
            warnings += 1
            if cur_issue and len(examples) < 10:
                examples.append(cur_issue)
            cur_issue = None
            continue

    return {
        'created': created,
        'drc_violations': drc_violations,
        'unconnected_pads': unconnected_pads,
        'errors': errors,
        'warnings': warnings,
        'examples': examples,
    }


erc = parse_erc(read_text(ERC_RPT))
drc = parse_drc(read_text(DRC_RPT))

md = []
md.append('---')
md.append('layout: page')
md.append('title: "Relatórios ERC e DRC"')
md.append('subtitle: "Saídas do KiCad (ERC/DRC)"')
md.append('permalink: /relatorios-erc-drc/')
md.append('---')
md.append('')
md.append('Esta página é gerada automaticamente pelo CI a partir dos relatórios do KiCad.')
md.append('')

md.append('## Resumo')
md.append('')
md.append('### ERC (Electrical Rules Check)')
md.append('')
if erc['created']:
    md.append(f'- Gerado em: `{erc["created"]}`')
md.append(f'- Erros: **{erc["errors"]}**')
md.append(f'- Avisos: **{erc["warnings"]}**')
md.append('')

md.append('### DRC (Design Rules Check)')
md.append('')
if drc['created']:
    md.append(f'- Gerado em: `{drc["created"]}`')
if drc['drc_violations'] is not None:
    md.append(f'- Violações DRC: **{drc["drc_violations"]}**')
if drc['unconnected_pads'] is not None:
    md.append(f'- Pads desconectados: **{drc["unconnected_pads"]}**')
md.append(f'- Erros: **{drc["errors"]}**')
md.append(f'- Avisos: **{drc["warnings"]}**')
md.append('')

md.append('## Relatórios completos')
md.append('')
md.append('- [Abrir `erc.rpt`](https://github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia/blob/main/kicad/KEPR/reports/erc.rpt)')
md.append('- [Abrir `drc.rpt`](https://github.com/RapportTecnologia/kit-de-prototipacao-educacional-e-engenharia/blob/main/kicad/KEPR/reports/drc.rpt)')
md.append('')

md.append('## Principais ocorrências (amostra)')
md.append('')
md.append('### ERC')
md.append('')
if erc['examples']:
    for e in erc['examples']:
        md.append(f'- `{e}`')
else:
    md.append('- (nenhuma)')
md.append('')

md.append('### DRC')
md.append('')
if drc['examples']:
    for e in drc['examples']:
        md.append(f'- `{e}`')
else:
    md.append('- (nenhuma)')
md.append('')

OUT_MD.write_text('\n'.join(md) + '\n', encoding='utf-8')
PY
