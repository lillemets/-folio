---
layout: page
title: texts
description: Here are some essays and other papers on various political issues. These were written during my studies in <a target="_blank" href="http://skytte.ut.ee/en">Tartu</a> and <a target="_blank" href="https://www.polver.uni-konstanz.de/en/">Konstanz</a>. Most are in Estonian.
---

<ul class="post-list">
{% for text in site.texts reversed %}
    <li>
        <h2><a class="text-title" href="{{ text.url | prepend: site.baseurl }}">{{ text.title }}</a></h2>
        <p class="post-meta">{{ text.date | date: '%B %-d, %Y' }}</p>
      </li>
{% endfor %}
</ul>
