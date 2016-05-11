---
layout: post
title: "liquidsoap cue and crossfade metadata"
tags: [liquidsoap, icecast, shoutcast]
---

You can easily control cue and crossfade points per song in liquidsoap using metadata via the annotate protocol. Namely there are 4 variables you can pass as metadata, `liq_fade_in`, `liq_fade_out`, `liq_cue_in`, and `liq_cue_out`. These do what you would expect.

However, you can also use the annotate protocol even if you aren’t using a textfile playlist. If you are using `request.dynamic` you can pass a string containing the annotate metadata to `request.create`.

{% highlight ruby %}
request.create("annotate:liq_fade_in=\"0.5",liq_fade_out=\"0.5\",liq_cue_in=\"30\",liq_cue_out=\"50\":/home/tracks/bacon.mp3")
{% endhighlight %}

You have to use some operators on your source to actually get the crossfades and fades to apply however. You’ll need cue_cut and one of the crossfade operators (crossfade or smart_crossfade).

Assuming you have assigned a playlist or request.dynamic source to `backup_playlist`:

{% highlight ruby %}
source = cue_cut(backup_playlist)
source = crossfade(backup_playlist)
{% endhighlight %}

This opens up quite a few possibilities in my mind. For example you could assign per-track fades or cue points in a database, fetch them via an API or similar in liquidsoap and use the annotate protocol with request.dynamic to have per track fades/cuepoints.

I'm using something like this in my own project right now, where I get all the
information for the next track, including fade and cue points, via an external
ruby script:
{% highlight ruby %}
result = list.hd(get_process_lines("rbenv exec bundle exec ruby ./next_song.rb"))
json = of_json(default=[("error","fail")], result)
track = json["track"]
cue_in = int_of_string(json["cue_in"])
cue_out = int_of_string(json["cue_out"])
fade_in = int_of_string(json["fade_in"])
fade_out = int_of_string(json["fade_out"])
annotate_line = "annotate:liq_fade_in=#{fade_in},liq_fade_out=#{fade_out},liq_cue_in=#{cue_in},liq_cue_out=#{cue_out}:/home/liquidsoap/tracks/#{track}"
request.create("annotate:liq_fade_in=\"0.5",liq_fade_out=\"0.5\",liq_cue_in=\"30\",liq_cue_out=\"50\":/home/tracks/bacon.mp3")
{% endhighlight %}

http://savonet.sourceforge.net/doc-svn/metadata.html

{% include mailchimp.html %}
