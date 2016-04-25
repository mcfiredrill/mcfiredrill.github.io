---
layout: post
title: "big big list of icecast/shoutcast shoutcast source clients"
tags: [liquidsoap, icecast, shoutcast]
---

I want to compile the definitive list of icecast and shoutcast clients.

Clients you want to add to the list? Info missing or incorrect? Contact me or leave a comment!

# [butt](http://butt.sourceforge.net/)

|url                                       |icecast |shoutcast |windows |mac |linux |
|------------------------------------------|--------|----------|--------|----|------|
|http://butt.sourceforge.net/              | yes    | yes      |yes     |yes |yes   |

![butt screenshot](/assets/images/butt_harbor_connect.png)

Personally I've had the least luck with BUTT and liquidsoap. The connection seems to timeout and generally be unstable. It seems to work better with shoutcast or plain icecast.

# [traktor dj studio](http://www.native-instruments.com/en/products/traktor/)

|url                                                    |icecast |shoutcast |windows |mac |linux |
|-------------------------------------------------------|--------|----------|--------|----|------|
|http://www.native-instruments.com/en/products/traktor/ | yes    | yes      | yes    |yes |no    |

![traktor screenshot](/assets/images/traktor_harbor_connect.png)

Works great if you are doing all your mixing in Traktor itself.

# [shoutVST](https://github.com/Gargaj/ShoutVST)

|url                                                    |icecast |shoutcast |windows |mac |linux |
|-------------------------------------------------------|--------|----------|--------|----|------|
|https://github.com/Gargaj/ShoutVST                     | yes    | yes      |yes     |yes |yes   |

![shoutvst screenshot](/assets/images/shoutvst.png)

Quite convenient for broadcasting straight from a Ableton or any other DAW.
Note this VST plugin is 32 bit, so it won't work in Ableton 9 or any other 64bit host without using something like [jBridge](https://jstuff.wordpress.com/jbridge/). Also as far as I can tell the project is basically abandoned.

# [ladiocast](https://itunes.apple.com/us/app/ladiocast/id411213048?mt=12)

|url                                                            |icecast |shoutcast |windows |mac |linux |
|---------------------------------------------------------------|--------|----------|--------|----|------|
|https://itunes.apple.com/us/app/ladiocast/id411213048?mt=12    | yes    | yes      |no      |yes |no    |

![ladiocast screenshot](/assets/images/ladiocast.png)

Works well and seems to still be maintained. Definitely recommended if you're on
OSX, as its OSX only.

# [altacast](http://www.altacast.com/)

|url                                                            |icecast |shoutcast |windows |mac |linux |
|---------------------------------------------------------------|--------|----------|--------|----|------|
|http://www.altacast.com/                                       | yes    | yes      |yes     |no  |no    |


![altacast screenshot](/assets/images/Altacast_Main_Window.png)

I've recomended this to some people on windows who couldn't get BUTT working.
Seems to be a viable alternative for some folks. Windows only.

# [mixxx](http://www.mixxx.org/)

|url                                                            |icecast |shoutcast |windows |mac |linux |
|---------------------------------------------------------------|--------|----------|--------|----|------|
|http://www.mixxx.org/                                          |yes     |yes       |yes     |yes |yes   |

![mixxx screenshot](/assets/images/mixxx.png)

This is another DJing software like Traktor that has the ability to stream to an
icecast or shoutcast server. Its free, open source and runs on Windows, Mac and
Linux.

{% include mailchimp.html %}
