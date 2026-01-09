---
layout: page
title: "Categorias"
subtitle: "Atalhos para os principais recursos do repositório"
permalink: /categorias/
---

{%- assign categories = site.pages | where: "is_category", true | sort: "title" -%}

{%- if categories and categories.size > 0 -%}

<div class="grid">
  {%- for p in categories -%}
    <div class="card">
      <h3><a href="{{ p.url | relative_url }}">{{ p.title }}</a></h3>
      {%- if p.subtitle -%}
        <p>{{ p.subtitle }}</p>
      {%- endif -%}
      <a href="{{ p.url | relative_url }}">Abrir</a>
    </div>
  {%- endfor -%}
</div>

{%- else -%}

Ainda não há categorias cadastradas.

{%- endif -%}
