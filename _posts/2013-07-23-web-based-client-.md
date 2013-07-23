---
layout: post
title: web based icecast client
tags: [liquidsoap, icecast, websockets, asm.js, html5]
---

Although I added some features to B.U.T.T.(broadcast using this tool), its still not the ideal broadcasting tool for all DJs. A web based client would be ideal. Some developers at Liquidsoap are working on what I think is an interesting solution, using Websockets and lame.js. They currently have support for this in a branch, and will probably be merged soon.

Of course, most of the bottleneck is in the browser. Lame.js is simply not fast enough. As toots points out in [this](https://github.com/savonet/liquidsoap/pull/90#issuecomment-21254384) discussion, this could be sped up with [asm.js](http://asmjs.org/), which is only available in Firefox. Unfortunately, Firefox doesn't seem to implement the required audio APIs we need. `AudioContext` appears to only be supported in the nightly builds for now. So until either Chromium supports something like asm.js, or Firefox implements the audio APIs, this solution is going to be a bit janky. I wonder if a Chrome app using NACL would be another possible solution.
