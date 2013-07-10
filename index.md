---
layout: page
title: ":3"
tagline:
---
<img src='/assets/themes/twitter/images/me.jpg'>
<p>
Hi I'm Tony.
<p>

<ul class="social-icons">
  <li><a class="lsf-icon" title="twitter" href="http://twitter.com/freedrull/"></a></li>
  <li><a class="lsf-icon" title="github" href="http://github.com/mcfiredrill"></a></li>
  <li><a class="lsf-icon" title="soundcloud" href="http://soundcloud.com/firedrill"></a></li>
  <li><a class="lsf-icon" title="mail" href="mailto:mcfiredrill@gmail.com"></a></li>
  <li><a class="lsf-icon" title="star" href="http://coderwall.com/mcfiredrill"></a></li>
  <li><a class="lsf-icon" title="instagram" href="http://instagram.com/freedrull"></a></li>
</ul>
<ul class="contact-icons">
  <li class="lsf-icon" title="line">@freedrull</li>
  <li class="lsf-icon" title="skype">freedrull</li>
</ul>

{% include JB/setup %}

{% for post in site.posts %}
{% include JB/post_content %}
{% endfor %}
