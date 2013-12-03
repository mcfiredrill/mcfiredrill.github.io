---
layout: post
title: mozGetMetaData() possible solution for icecast stream metadata?
tags: [icecast, metadata, firefox]
---

I recently saw someone point out that mozGetMetaData() exists on the jPlayer google group. Its a commonly asked question in this group if its possible to pull icecast stream metadata directly from the <audio> element, instead of going through and polling the server every once in awhile instead, like the trick I outline in this post.

Here is the description for this method on this page:
The mozGetMetadata method returns a javascript object whose properties represent metadata from the playing media resource as {key: value} pairs. A separate copy of the data is returned each time the method is called.
This method must be called after the loadedmetadata event fires.

<https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement>

I tried this out with the ogg version of my stream and got this object back:

{% highlight javascript %}
Server: "Icecast 2.3.3"
Title: "Unknown"
{% endhighlight %}       

When I tried the mp3 version it didn't return this data however.

Seems like it could be useful, although its a shame its Firefox only. This type of functionality really needs to be standardized.
