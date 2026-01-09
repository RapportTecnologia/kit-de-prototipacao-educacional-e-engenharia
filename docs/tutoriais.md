---
layout: page
title: "Tutoriais"
subtitle: "Guias rápidos e materiais de apoio"
permalink: /Tutoriais/
is_category: true
---

{%- assign tutorials = site.posts | where_exp: "p", "p.categories contains 'Tutoriais'" -%}

{%- if tutorials and tutorials.size > 0 -%}

<div class="grid">
  {%- for p in tutorials -%}
    <div class="card">
      <h3><a href="{{ p.url | relative_url }}">{{ p.title }}</a></h3>
      <p class="muted">{{ p.date | date: "%d/%m/%Y" }}</p>
      {%- if p.excerpt -%}
        <p>{{ p.excerpt | strip_html | truncate: 160 }}</p>
      {%- endif -%}
      <a href="{{ p.url | relative_url }}">Abrir</a>
    </div>
  {%- endfor -%}
</div>

{%- else -%}

Ainda não há tutoriais publicados.

{%- endif -%}
