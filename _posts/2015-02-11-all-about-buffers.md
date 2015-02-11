---
layout: post
title: 'all about buffers'
tags: [liquidsoap, buffers, icecast]
---

Listener interruption sucks. Understanding buffers will help you reduce and eliminate listening interruptions due to buffers falling behind.

Its not difficult to understand the basic concept of buffering. Your DJ sends you some data from their machine. The server “buffers” a certain amount before sending it to a listener client.

If the DJ’s connection cannot send data fast enough, the buffer runs out, and the listener gets silence, or your liquidsoap stream fallsback to AUTO dj, or whatever. Simple as that. This isn’t what we want. No one wants to listen to a stream like this.

There are several approaches to take to reduce these problems. The one you
probably have the most control over if adjusting buffer sizes. However the trade
off is that the stream will take longer to initially load, as the buffer needs
to be filled.

## icecast buffer settings

You can configure the buffer size on the icecast side of things.

{% highlight xml %}
    <limits>
        <clients>100</clients>
        <sources>2</sources>
        <queue-size>524288</queue-size>
        <client-timeout>30</client-timeout>
        <header-timeout>15</header-timeout>
        <source-timeout>10</source-timeout>
        <!-- If enabled, this will provide a burst of data when a client
             first connects, thereby significantly reducing the startup
             time for listeners that do substantial buffering. However,
             it also significantly increases latency between the source
             client and listening client.  For low-latency setups, you
             might want to disable this. -->
        <burst-on-connect>1</burst-on-connect>
        <!-- same as burst-on-connect, but this allows for being more
             specific on how much to burst. Most people won't need to
             change from the default 64k. Applies to all mountpoints  -->
        <burst-size>65535</burst-size>
    </limits>
{% endhighlight %}

This comment really sums up the tradeoff if you increase your buffer size.

"However, it also significantly increases latency between the source client and
listening client."

In addition to the stream taking a longer intial time to load, the latency will
increase, meaning the users won't be hearing the stream in exact realtime.

If latency isn't really a problem I think you should crank up your burst size. I
personally doubled the value to 131070. You might want to try increase the value
and see what effect it has, if your listeners are experiencing many buffering
issues.

## liquidsoap buffer overruns

Unfortunately a common problem people have with liquidsoap is live dj's not
having enough bandwidth to keep the stream going without interruptions. This can
result in listener interruptions and inconsistent live recordings.

You may see something like this in your logs, over and over again.
{% highlight bash %}
2014/12/17 08:01:39 [clock.wallclock_main:2] We must catchup 1.09 seconds!
2014/12/17 08:01:39 [clock.wallclock_main:2] We must catchup 1.09 seconds!
{% endhighlight %}

This means the soundcard could not provide data fast enough to keep up, and the
listener's stream may be interrupted, causing to fallback to your backup stream.

This happened for me a lot when people were streaming live to `input.harbor`. An
interruption would occur quite often, causing to switchback to the fallback
playlist. At best this would be a confusing sudden jump to another song for a
second, at worst it could be a horrible sounding jump in volume depending on
which was louder, the current dj or the fallback playlist track.

## graphing the buffer data

I learned that `input.harbor` has a parameter called `logfile`, which simply
logs the size of the buffer over time. This can help you measure your buffer
performance. The resulting file looks something like
this:

{% highlight bash %}
0.007761 0
0.007834 0
0.009157 0
0.012572 0
0.012607 0
0.012639 0
0.016265 10688
0.016395 10688
0.016493 10688
0.019577 22976
0.019872 22976
0.019916 22976
0.023584 34240
0.023603 34240
0.023829 34240
0.030431 45824
0.030681 45824
0.030914 45824
0.032800 58688
0.032811 58688
0.032820 58688
{% endhighlight %}

The number on the left is time, while the number on the right is the buffer
size. I'm not really sure what units are being used here, but I mostly just
wanted to see when the buffer hit 0. When the buffer is 0, that is when your
listener is going to be interrupted in some way. If you are using fallbacks in
liquidsoap, the stream will fallback to the next source, which is a playlist in
my case.

I told my friend [@ovenrake](http://twitter.com/ovenrake) to connect and watched the log file spit out numbers.
Surely enough, when the buffer size hit 0 I heard a blip in the stream.

Here's a graph I made of the data.

{% include dakota_harbor_graph.html %}

As you can see it drops to 0 periodcally, builds the buffer back up, then rapidly falls to 0 again.

## Well, can't I just make the buffer bigger?

Yes, you can. If you are ok with the initial delay as the larger buffer fills
up. Use the `buffer` and `max` options of the `input.harbor` function. The
defaults for these are 2 and 10, respectively. I'm currently trying out 15
seconds of buffer time.

{% highlight ruby %}
live_dj = input.harbor("datafruits",port=9000,auth=dj_auth,on_disconnect=on_disconnect,logfile="/tmp/liquidsoap_harbor.log",buffer=15.0,max=30.0)
{% endhighlight %}

I collected new data for this setup from the harbor log file, and generated a
new graph.

{% include big_buffer_graph.html %}

As you can see the buffer does not drop to 0 anymore. The price you pay is a
longer startup time (at least 15 seconds), as the buffer has to pre-fill. Also
obviously there is much more delay between what the DJ plays and the listener
hears. If this is important to you, a large buffer may not be a great solution.

I think you should tune these values and check the performance, and find the
best buffer-stability/latency trade off for your own needs.

## buffer.adaptative

The liquidsoap team has come up with an interesting hack for solving this
problem, with a new function called `buffer.adaptative`.

Here is the description from the liquidsoap documentation.

{% highlight bash %}
WARNING: This is only EXPERIMENTAL!

Create a buffer between two different clocks. The speed of the output is adapted
so that no buffer underrun or overrun occurs. This wonderful behavior has a
cost: the pitch of the sound might be changed a little.
{% endhighlight %}

What this does is dynamically resize the buffer based on the whether the buffer
is currently growing or shrinking. The tradeoff apparentally is there could be a slight change
in pitch if the buffer is changing size.

I honestly haven't had much luck with this. I use it like this in my script to
test, as demonstrated in the [original pull request for this
feature.](https://github.com/savonet/liquidsoap/pull/131)

{% highlight ruby %}
live_dj = input.harbor("live", port=9000)
live_dj = sleeper(delay=1.5, live_dj)
live_dj = buffer.adaptative(live_dj, fallible=true)
{% endhighlight %}

For me, I hear the live stream skipping and stuttering quite a lot, not the
'cassettetape-like pitch changing effect' I expected to hear.

Have you tried `buffer.adaptative`? Has it worked out? I'd like to know. Please
leave me a comment if so.

So as you can see, aside from getting a better internet connection, there are
several options you could try to solve buffer issues. Have you tried any other
methods?

{% include mailchimp.html %}
