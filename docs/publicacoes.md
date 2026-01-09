---
layout: page
title: "Publicações"
subtitle: "Tudo sobre o projeto KEPR"
permalink: /publicacoes/
render_with_liquid: true
---

Abaixo estão as publicações relacionadas ao projeto **KEPR**.

{%- assign tutorials = site.posts | where_exp: "p", "p.categories contains 'Tutoriais'" | sort: "date" | reverse -%}
{%- assign posts_sorted = site.posts | sort: "date" | reverse -%}

{%- assign has_posts = 0 -%}

<div class="grid">
  {%- for post in posts_sorted -%}
    {%- if post.tags contains 'KEPR' -%}
      {%- unless post.categories contains 'Tutoriais' -%}
        {%- assign has_posts = 1 -%}
        <div class="card">
          <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
          <p class="muted">{{ post.date | date: "%d/%m/%Y" }}</p>
          {%- if post.excerpt -%}
            <p>{{ post.excerpt | strip_html | truncate: 160 }}</p>
          {%- endif -%}
          <a href="{{ post.url | relative_url }}">Ler</a>
        </div>
      {%- endunless -%}
    {%- endif -%}
  {%- endfor -%}
</div>

{%- if has_posts == 0 -%}

Ainda não há publicações marcadas com a tag `KEPR`.

{%- endif -%}

## Tutoriais

Abaixo estão os tutoriais publicados no site.

{%- if tutorials and tutorials.size > 0 -%}

<div class="grid">
  {%- for post in tutorials -%}
    <div class="card">
      <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
      <p class="muted">{{ post.date | date: "%d/%m/%Y" }}</p>
      {%- if post.excerpt -%}
        <p>{{ post.excerpt | strip_html | truncate: 160 }}</p>
      {%- endif -%}
      <a href="{{ post.url | relative_url }}">Ler</a>
    </div>
  {%- endfor -%}
</div>

{%- else -%}

Ainda não há tutoriais publicados.

{%- endif -%}
