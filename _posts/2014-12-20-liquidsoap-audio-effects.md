---
layout: post
title: 'audio effects in liquidsoap'
tags: [liquidsoap, ladspa]
---

Do you ever wish you could apply audio effects like compression, echo, or delay
to your liquidsoap stream? Liquidsoap provides several built-in effects as well
as an endless range of effects via linux's plugin audio system [LADSPA](http://www.ladspa.org/).

You need to install some packages on your system first. The liquidsoap plugin
package is required:

{% highlight bash %}
sudo apt-get install liquidsoap-plugin-ladspa
{% endhighlight %}

If you are compiling liquidsoap from
[source](https://github.com/savonet/liquidsoap-full), you need to uncomment the
line `ocaml-ladspa` in your PACKAGES file.

Once you have that installed, you can use this command to see what ladspa
plugins are available.

{% highlight bash %}
$ liquidsoap --list-plugins | grep -i ladspa
{% endhighlight %}

At first, you may not have any. Liqudsoap uses all the ladspa plugins it finds
on your system. You can install more through additional packages. I recommend
these ones to get started.

{% highlight bash %}
$ sudo apt-get install ladspa-sdk multimedia-audio-plugins
{% endhighlight %}

Run `liquidsoap --list-plugins | grep -i ladspa` again and you should see many
plugins listed.

You can get individual documentation for one plugin by using `liquidsoap -h
name-of-plugin`.

{% highlight bash %}
$ liquidsoap -h ladspa.compress
no more csLADSPA plugins

C* Compress - Compressor and saturating limiter by Tim Goetze
<tim(at)quitte.de>.

Type: (?id:string,?attack:'a,?gain:'b,?measure:int,?mode:int,
 ?release:'c,?strength:'d,?threshold:'e,
 source(audio='#f,video='#g,midi='#h))->
source(audio='#f,video='#g,midi='#h)
where 'a, 'b, 'c, 'd, 'e is either float or ()->float

Category: Source / Sound Processing

Parameters:

 * id : string (default: "")
     Force the value of the source ID.

 * attack : anything that is either float or ()->float (default: 0.)
     attack (0 <= <code>attack</code> <= 1).

 * gain : anything that is either float or ()->float (default: 0.)
     gain (dB) (-12 <= <code>gain</code> <= 24).

 * measure : int (default: 0)
     measure (0 <= <code>measure</code> <= 1).

 * mode : int (default: 1)
     mode (0 <= <code>mode</code> <= 3).

 * release : anything that is either float or ()->float (default: 0.25)
     release (0 <= <code>release</code> <= 1).

 * strength : anything that is either float or ()->float (default: 0.25)
     strength (0 <= <code>strength</code> <= 1).

 * threshold : anything that is either float or ()->float (default: 0.)
     threshold (0 <= <code>threshold</code> <= 1).

 * (unlabeled) : source(audio='#f,video='#g,midi='#h) (default: None)
{% endhighlight %}

You are probably pretty overwhelmed right now, like most liquidsoap
documentation this looks pretty confusing. But its really just telling you what
parameters this plugin accepts. Using it is quite simple, you just set the
parameters to what you want and it just returns a new source.

{% highlight ruby %}
source = ladspa.compress(source, attack = 5.0, gain = 8.0, measure = 1, mode =
1, release = 1.0, strength = 1.0, threshold = 1.0)
{% endhighlight %}

The above will give you some pretty loud compression.

I admit this is not the niceest way to tweak effects. It would be really nice if
it could just be controlled by knobs or something. Perhaps the parameters could
be controlled by telnet commands, but I'm not sure how well that would work.

Plus, there is little documentation about how the plugins actually work. I had
to google find the [original author of the ladspa.compress plugin's
site](http://quitte.de/dsp/caps.html#Compress) where he
explains what all the parameters do.

They are not documented well, but liquidsoap comes with quite a few built in
effects as well. At least the parameters of these effects are documented.

Right now I am using `sky`(a multiband compressor), `compress`(a normal
compressor), `normalize`(a volume normalizer),
and `limit`(a limiter) together. This provides a nice loudness boost to my
station.

{% highlight ruby %}
source = sky(source)
source = compress(source, attack = 5.0, gain = 8.0, knee = 10.0, ratio = 5.0,
release = 100.0, threshold = -18.0, rms_window = 0.7)
# 1, release = 1.0, strength = 1.0, threshold = 1.0)
source = normalize(source, target = -1.0, threshold = -65.0)
source = limit(source, threshold = -0.2, attack = 2.0, release = 25.0,
rms_window = 0.02)
{% endhighlight %}

I'd like to thank [JamesHarrison](https://github.com/JamesHarrison) for sharing
his [conduit](https://github.com/JamesHarrison/conduit) repository, where he has
a few good examples of using liquidsoap effects.

Are there any other liquidsoap effects you are interested in using? I honestly
can't imagine using much more than just compression,limiting, etc, for a normal
radio station. But maybe there are some more interesting liquidsoap setups out there?
Let me know.

{% include mailchimp.html %}
