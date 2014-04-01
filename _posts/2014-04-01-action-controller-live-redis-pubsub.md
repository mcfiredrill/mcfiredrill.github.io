---
layout: post
title: streaming datafruits radio metadata with action controller::live and redis pub/sub
tags: [rails, redis, pubsub, metadata]
---

Right now the metadata for the currently streaming song/live dj on datafruits is
updated via simple polling and ajax requests. The metadata is stored in a
simple redis key, and a sinatra app with an endpoint `/currentsong` will return
this key in JSON format. The ajax request simply polls this app every few
seconds.

I'd like to use EventSource instead of polling via setInterval. I thought this
would be a good opportunity to try out the new ActionController::Live feature in
Rails. Luckily Aaron Patterson has a good [write-up on his
blog](http://tenderlovemaking.com/2012/07/30/is-it-live.html).

I ran into a few caveats along the way. First off is some good news, an
implementation of Aaron's SSE emitter class has been merged into Rails, so you
no longer need to write your own.

```
sse = SSE.new(response.stream)
```

Also one thing is that it seems if there is most any kind of error in your
controller, *nothing happens*. The Rails developers seem to have decided this is
correct behaviour for the most part. https://github.com/rails/rails/pull/9604
There is an `on_error` callback, although I couldn't find any documentation on
how to use it.

The final caveat is that you are probably going to new a different server than
you are used to. I tried out Puma, mostly since that's what Aaron used in his
guide.

I thought of the implications of every datafruits visitor keeping a connection
open to my site. Am I going to require a thread for each connection? Is each
connection going to additionally require a database connection in the
activerecord pool?

I think I can come up with a simpler solution. I could extract this
functionality to a smaller service, perhaps running on faye or sinatra. All I
really require is the redis connection, this doesn't actually have anything to
do with the rest of my rails application anyway.
