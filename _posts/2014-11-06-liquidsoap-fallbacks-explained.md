---
layout: post
title: "liquidsoap fallbacks explained"
tags: [liquidsoap]
---

## Preventing Radio Castatrophy

[!not what liquidsoap looks like](/assets/images/old_radio.gif)

In liquidsoap, the *last* thing you want is your users to hear silence. There
are many reasons this could happen, the DJ fell asleep/got drunk, there's a bad
file in the playlist that cannot be played, etc.

## The fallback function

In liquidsoap you can prevent disasters with fallbacks. If one source cannot be
played, liquidsoap will gracefully fall back to another source. Here's a typical
setup:

{% highlight ruby %}
backup_playlist = playlist("./playlist.txt",conservative=true,mode="normal",reload_mode="watch")
output.dummy(fallible=true,backup_playlist)

live_dj = input.harbor("live",port=9000)

on_fail = single("./technical_difficulties.wav")

source = fallback(track_sensitive=false,
                  [live_dj,backup_playlist,on_fail])
{% endhilight %}

While some sources may be fallible, that's ok if that are arranged in a
cascading fallback, with the last source being unfallible. This way we can
guarantee something should always be playing.

{% include mailchimp.html %}
