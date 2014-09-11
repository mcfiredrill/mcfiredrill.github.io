---
layout: post
title: "compiling liquidsoap"
description: ""
category:
tags: [liquidsoap]
---

I was scanning the liquidsoap mailing list, and I noticed there were some people still having trouble compiling liquidsoap. I thought I'd write up these instructions.

These instructions are tested on ubuntu 14.04 trusty. The easiest way to compile liquid soap is with the liquidsoap-full repo, as liquidsoap depends on many ocaml modules developed by the liquidsoap team. They are all included in this repository as git submodules.

Clone the repository:
`git clone https://github.com/liquidsoap-full`

Not all of the modules are required to run liquidsoap. There are many different modules for different audio/video formats, plugins etc. They are all defined via th PACKAGES file in the top level directory of the repo. You can copy PACKAGES.default to PACKAGES and then edit the file to suit your needs.

`cp PACKAGES.default PACKAGES`

If you are unsure what you might need, I recommend this for a minimal setup. I posted the file on gist.

<script src="https://gist.github.com/mcfiredrill/eac8cd3e2c9326722ccd.js"></script>

You will need a few dependencies for liquidsoap and its modules first. The depencies you need depend on what is in your PACKAGES file. Here is the minimal set of dependencies you need,  Install these via apt-get:

If you used  my example PACKAGES file, you will need these as well:

```
apt-get install -y --force-yes build-essential autoconf curl git ocaml \
  libmad0-dev libtag1-dev libmp3lame-dev libogg-dev libvorbis-dev libpcre-ocaml-dev \
  libcamomile-ocaml-dev pkg-config
```

When you first clone the repo, the git submodules won't be checked out yet. The ./bootstrap script can check them out for you. Run this script, it will also set up all packages for compilation:

Next run configure, this will ensure all the dependencies are installed on your system. If you get an error, check what the error says and install that dependency with apt-get.

If you don't get any errors, you are ready to run make. This will take awhile.

Next run make install and you are ready to go! Try out one of the examples included with liquidsoap:

`$ liquidsoap -c liquidsoap/examples/radio.liq`

I’m currently [writing a book about liquidsoap!](https://leanpub.com/modernonlineradiowithliquidsoap)

{% include mailchimp.html %}
