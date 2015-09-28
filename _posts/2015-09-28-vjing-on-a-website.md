---
layout: post
title: "VJing on a website?"
tags: [vjing, youtube, twitch]
---

I have always wanted an easy way to have a visual (VJ) stream on datafruits.

 Writing my own video streaming service sounds fun but I am already busy writing a bunch of other features for datafruits/streampusher. So for now I thought I'd pursue some third party options. I looked at Twitch and YouTube streaming.

Twitch has a nice API that allows you to detect whether a channel is currently broadcasting or not. This turned out to be very convenient for my use case, as I don't want to display the stream at all if there is no live stream.

YouTube seemed to have better performance and video quality. In addition you can stream at a lower quality in OBS while Twitch seems to have a higher minimum requirement. YouTube also doesn't require flash. It seems to be easier to resize the player window as well.

Unfortunately the YouTube streaming/broadcasting API doesn't seem to have any functionality to detect whether a channel is currently live. This is unfortunately kind of a deal breaker at the moment. I would have to work around their API a bit to get around this.

Also there is a pretty decent ember cli addon for YouTube that I found. I even contributed a couple of pull requests.

So due to youtube streaming’s limited API I have switched back to Twitch for now. Perhaps I can create some sort of looping playlist of content to play while there is no live stream, or I can work around the API somehow.

In the future I’d like to incorporate this into [Streampusher](http://streampusher.com) somehow, but I haven’t quite worked out how yet.

Do you have any interesting methods for including a live video stream on your radio station? Please let me know in the comments.
