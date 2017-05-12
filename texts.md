---
layout: page
title: texts
description: Here are some essays and other papers on politics that I wrote during my studies in <a target="_blank" href="http://skytte.ut.ee/en">University of Tartu</a> and <a target="_blank" href="https://www.polver.uni-konstanz.de/en/">University of Konstanz</a>.
---

<ul class="post-list">
{% for poem in site.texts reversed %}
    <li>
        <h2><a class="poem-title" href="{{ poem.url | prepend: site.baseurl }}">{{ poem.title }}</a></h2>
        <p class="post-meta">{{ poem.date | date: '%B %-d, %Y' }}</p>
      </li>
{% endfor %}
</ul>
