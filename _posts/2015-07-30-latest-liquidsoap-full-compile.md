---
layout: post
title: "issues compiling latest liquidsoap-full"
tags: [liquidsoap]
---

I ran into some issues compiling the latest
[liquidsoap-full](https://github.com/savonet/liquidsoap-full).

{% highlight bash %}
Checking for ocaml bytes module .. Configure: error : not found.
{% endhighlight %}

This can be solved by installing the bytes module via opam.

In Ubuntu, the opam package seems to be broken. The [official opam install
documentation](https://opam.ocaml.org/doc/Install.html#Ubuntu) recommends using this apt repository.

{% highlight bash %}
add-apt-repository ppa:avsm/ppa
apt-get update
apt-get install ocaml ocaml-native-compilers camlp4-extra opam
{% endhighlight %}

I’m not sure why but I also needed to install these opam packages as well to
continue.

{% highlight bash %}
opam install pcre
opam install camomile
{% endhighlight %}

After that I was able to install liquidsoap again. I hope this helps other
people who want to compile liquidsoap from source.

I’m not too familiar with the ocaml community and what the future plans for opam
are. Perhaps they will adopt some kind of bundler/carton/cargo type program to
specify dependencies instead of using autoconf? I guess ocamlfind seems to play
that role for now.

{% include mailchimp.html %}
