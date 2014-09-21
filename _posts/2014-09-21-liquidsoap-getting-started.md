---
layout: post
title: "getting started with liquidsoap"
tags: [liquidsoap]
---

I thought I would write an article aimed more at beginners to
[liquidsoap](savonet.sourceforge.net). This
tutorial will give you a solid starting point into creating your own streaming
radio with liquidsoap.

![not liquidsoap](/assets/images/bottle_invert.png)

# What this tutorial covers

* setting up a stream with a backup playlist, live dj input via harbor, and emergency
  backup single file
* mp3 and ogg output to icecast
* dumping output to a file

# What it doesn't cover yet, but I will cover in the future

* DJ authentication (I have written about it [here]({% post_url 2014-06-28-liquidsoap-source-auth %}))
* transitions
* dynamic playlists

# Requirements

![actual picture of me](/assets/images/dj.gif)

## liquidsoap

If you don't have liquidsoap, you'll need to install it. I have an article about
compiling it from source [here](%{ post_url 2014-08-20-compiling-liquidsoap %}),
but it may be easier to install from your package manager if possible. On OSX
with homebrew you can just `brew install liquidsoap`.

## icecast
You will also need icecast. I'd recommend getting this from your package manager
as well. Its available in most operating system repositories, read more at
[icecast.org](http://icecast.org/download/).

## my quickstart repository
I have a [git repository](https://github.com/mcfiredrill/liquidsoap-quickstart)
for this getting started tutorial. Please clone the repository and follow along!
  If you don't have git you should be able to grab the [zip file](https://github.com/mcfiredrill/liquidsoap-quickstart/archive/master.zip).

# The example script
I tried to make the simplest possible example that was still pretty useful.

{% highlight ruby %}
#!/usr/local/bin/liquidsoap

set("log.file",true)
set("log.file.path","./log/liquidsoap.log")
set("log.stdout",true)
set("log.level",3)

set("harbor.bind_addr","0.0.0.0")

backup_playlist = playlist("./playlist.txt",conservative=true,mode="normal",reload_mode="watch")
output.dummy(fallible=true,backup_playlist)

live_dj = input.harbor("live",port=9000)

on_fail = single("./technical_difficulties.wav")

source = fallback(track_sensitive=false,
                  [live_dj,backup_playlist,on_fail])

# We output the stream to an icecast
# server, in ogg/vorbis and mp3 format.
output.icecast(%vorbis,id="icecast",
               mount="myradio.ogg",
               host="localhost", password="hackme",
               icy_metadata="true",description="cool radio",
               url="http://myradio.fm",
               source)
output.icecast(%mp3,id="icecast",
               mount="myradio.mp3",
               host="localhost", password="hackme",
               icy_metadata="true",description="cool radio",
               url="http://myradio.fm",
               source)

# dump live_dj recordings to a file
time_stamp = '%m-%d-%Y, %H:%M:%S'
output.file(%mp3, "./live_dj_#{time_stamp}.mp3", live_dj,fallible=true)
{% endhighlight %}

Let's go over the script step-by-step.

## Loggging and other settings

{% highlight ruby %}
set("log.file",true)
set("log.file.path","./log/liquidsoap.log")
set("log.stdout",true)
set("log.level",3)

set("harbor.bind_addr","0.0.0.0")

{% endhighlight %}

This sets up liquidsoap to log to a file *and* stdout for convenience. We also
set the harbor.bind_addr to localhost.

# Three sources to gradually fallback

{% highlight ruby %}
backup_playlist = playlist("./playlist.txt",conservative=true,mode="normal",reload_mode="watch")
output.dummy(fallible=true,backup_playlist)

live_dj = input.harbor("live",port=9000)

on_fail = single("./technical_difficulties.wav")

source = fallback(track_sensitive=false,
                  [live_dj,backup_playlist,on_fail])
{% endhighlight %}

## Static playlists

We can use the playlist function to create a playlist. Here we create one from a
static txt file. The playlist file simply looks like this:

{% highlight bash %}
mp3s/I_Cactus_-_01_-_yellow_cactus.mp3
mp3s/I_Cactus_-_02_-_chartreuse_cactus.mp3
mp3s/I_Cactus_-_03_-_green_cactus.mp3
mp3s/I_Cactus_-_04_-_bamboo_cactus.mp3
{% endhighlight %}

I'm using some mp3s that are released under a Creative Commons(CC) license in
this tutorial. You can change this playlist to whatever you want, using relative
or absolute paths to your music files in the playlist file.

## Live dj input

The second source is a live input from the harbor. It is given a name "live" and
it will listen on port 9000. You can connect to this just like you connect to
icecast/shoutcast from a source client normally.

Here's an example of connecting
in [Traktor](http://www.native-instruments.com/en/products/traktor/).

![traktor screenshot](/assets/images/traktor_harbor_connect.png)

And using [Broadcast Using This Tool](http://butt.sourceforge.net/)

![butt screenshot](/assets/images/butt_harbor_connect.png)

*You can use the password `hackme` for this example*

## Preparing for failure

The final source `on_failure` is what will be used when every other source
fails. Its a simple wav file that says 'technical difficulties' that I made
using the osx `say` command.

Liquidsoap tries to not let you create sources that it calls 'fallible'. For
example, just using the live dj input and text playlist only would not be
allowed. If you try, liquidsoap will raise an error.

```
that source is fallible
```

## Cascading fallbacks

![inside your computer](/assets/images/dominoes.gif)

We have set up the fallback system in order of priority.

live dj -> playlist -> single emergency file

The live dj input always takes priority, but if its not available, we have the
playlist of static files. If for some reason the playlist fails, we fall back
to the single file.

### Output to icecast

{% highlight ruby %}
# We output the stream to an icecast
# server, in ogg/vorbis and mp3 format.
output.icecast(%vorbis,id="icecast",
               mount="myradio.ogg",
               host="localhost", password="hackme",
               icy_metadata="true",description="cool radio",
               url="http://myradio.fm",
               source)
output.icecast(%mp3,id="icecast",
               mount="myradio.mp3",
               host="localhost", password="hackme",
               icy_metadata="true",description="cool radio",
               url="http://myradio.fm",
               source)
{% endhighlight %}

## Saving recordings to files

![not a computer](/assets/images/cassette_recorder.gif)

{% highlight ruby %}
# dump live_dj recordings to a file
time_stamp = '%m-%d-%Y, %H:%M:%S'
output.file(%mp3, "./live_dj_#{time_stamp}.mp3", live_dj,fallible=true)
{% endhighlight %}

The output function can also output to a file. It would be nice to save the live
input recordings to disk. We can use time format modifiers to help us sort
through the recordings later.

# just the begining of a world of soap

I hope this simple example got you started in creating your own radio with
liquidsoap. There are many more features that I didn't cover such as blank
detection, more complex playlists, fallbacks, audio effects, metadata and more. I hope to
cover these in future articles.

If you have any feedback or questions, please don't hesitate to leave me a comment or [shoot me an
email!](mailto:mcfiredrill@gmail.com) I love talking about this stuff.

{% include mailchimp.html %}
