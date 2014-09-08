---
layout: post
title: "webcaster"
description: ""
category:
tags: [liquidsoap]
---
![My helpful screenshot](/assets/images/webcaster_screenshot.png)
Toots has been working on a very exciting tool that allows you to stream directly to liquid soap from a web browser. Imagine if your DJs could start broadcasting on your radio without needing to download any software!

The main technologies that make this possible are websockets and emscripten. There is a websocket endpoint on liquidsoap that receives the mp3 data. Emscripten is used to compile the libshine fixed point encoding library to Javascript.

Toots has released the Javascript library
[here](https://github.com/webcast/webcast.js) and has an example client
application [here](https://github.com/webcast/webcaster).

I’ll show you how to set up liquidsoap to use the example application.

The webcast.js repository contains [the simplest possible example.](https://github.com/webcast/webcast.js)

Just run this liquid soap line:
`liquidsoap "output.ao(fallible=true,audio_to_stereo(input.harbor('mount',port=8080)))"`

Toots also has an example client for testing:
[https://github.com/webcast/webcaster](https://github.com/webcast/webcaster)

There are a few git submodule dependencies in this repository you’ll need to checkout. Run `git submodule init` and `git submodule update` to fetch them.

Check it out and run `make`, then run `make test` to start the server. Access the client in your web browser on localhost:8000.

The easiest way to get some sound going is to upload some mp3s to this cute little web based mixer.  You can try the microphone as well.

Click ‘Start Streaming’ to connect. You are able to set bitrate, samplerate, and
stereo or mono output. You can change the stream destination URI if your
liquidsoap harbor is on a different IP or port.

The [webworker option](http://www.html5rocks.com/en/tutorials/workers/basics/)
is for performance reasons. MP3 encoding is CPU intensive to begin with, let
alone in Javascript, so this option is recommended.

Check the output of liquidsoap and you should see that a client connected to the harbor. Since you’re using the libao output you should hear sound immediately!

![gif action](/assets/images/webcaster.gif)

You can use this setup with your usual icecast/shoutcast based liquidsoap configurations as well.

Now, the microphone input works well. For me, I'd like to stream directly from Traktor to this. If you're looking to stream from audio software already running on your system, you might be out of luck as it looks like only microphone/line-in can be captured. You could use something like soundflower to route your computer's output to input, but that's another article.

Luckily Traktor and similar software already supports broadcasting to icecast _anyway_, so I guess its not really an issue.

I’m currently [writing a book about liquidsoap!](https://leanpub.com/modernonlineradiowithliquidsoap)
