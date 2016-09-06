---
layout: post
title: "liquidsoap one line if statement"
tags: [liquidsoap]
---

I often run into this problem of trying to conditionally assign something in
liquidsoap.

{% highlight ruby %}
source = fallback(id="fallback",track_sensitive=false,
                  [clock(live_dj),mksafe(backup_playlist)])

if tunein_metadata_updates_enabled == "true" then
  source = on_track(tunein.submit(partnerid="ppppid",partnerkey="ppppkey",stationid="s123456"),
s)
end
{% endhighlight %}


Of course this doesn't work. Liquidsoap complains that I didn't use the result
of the variable.

Since liquidsoap does not actually allow mutation of variables, what you are
really doing in this case is creating two source variables. You are not using
the second one. Somewhat like this:

{% highlight ruby %}
source1 = fallback(id="fallback",track_sensitive=false,
                  [clock(live_dj),mksafe(backup_playlist)])

if tunein_metadata_updates_enabled == "true" then
  source2 = on_track(tunein.submit(partnerid="ppppid",partnerkey="ppppkey",stationid="s123456"),
s)
end
{% endhighlight %}

Maybe thinking of it this way, the error makes more sense.
Of course you didn't use the result of source2.

{% highlight ruby %}
At line 18, character 8: The variable source defined here is not used anywhere
in its scope. Use ignore(...) instead of source = ... if you meant  to not use
it. Otherwise, this may be a typo or a sign that your script  does not do what
you intend.
{% endhighlight %}

The solution is to write an if else statement on one line.

{% highlight ruby %}
source = if tunein_metadata_updates_enabled == "true" then
 on_track(tunein.submit(partnerid=tunein_partner_id,partnerkey=tunein_
 partner_key,stationid=tunein_station_id), source) else source end
{% endhighlight %}

This assigns the result to source if the condition passes, if not assign the
source to itself.

{% include mailchimp.html %}
