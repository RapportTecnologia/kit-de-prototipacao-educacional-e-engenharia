---
layout: page
title: "Publicações"
subtitle: "Tudo sobre o projeto KEPR"
permalink: /publicacoes/
---

Abaixo estão as publicações relacionadas ao projeto **KEPR**.

{%- assign posts = site.posts | where_exp: "p", "p.tags contains 'KEPR'" -%}

{%- if posts and posts.size > 0 -%}

<div class="grid">
  {%- for post in posts -%}
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

Ainda não há publicações marcadas com a tag `KEPR`.

{%- endif -%}
