---
layout: post
title: 'soundcloud web UI bugs'
tags: [soundcloud, bugs]
---

# endless scrolling with no pagination

Its nearly 2015 and i still think endless scroll is an awful horrible idea that breaks the web.

If you are on your soundcloud stream scrolled down about 50 tracks, click on one, then click back, the web client reloads ALL those 50 tracks!!

Then you are mysteriously shot halfway down the page to where you were before. Here is a gif of this in action.

![endless scrolling annoyance](/assets/images/soundcloud_endless_scrolling_annoyance.gif)

I don't think endless scrolling enhances the user experience compared to how clunky and slow it makes your browser. Why can't we just use pagination? Its possible to use endless scrolling and pagination in tandem as well with the html5 pushstate API.

# download links appear on tracks that the user didn’t authorize to be downloadable

Sometimes a download link appears on a track even though the track is not supposed to be downloadable. Now, if you click 'download' you get an error. I remember at one point a few years ago I actually DID download the tracks! I downloaded the [uzzi](https://soundcloud.com/ball-trap-music) album before it was even supposed to be out. I thought, why is this a free download? A few days later i noticed the download link wasn’t there anymore...

![download bug](/assets/images/soundcloud_download_bug.gif)

Notice I just get a file called ‘download.html’, which is just an HTML file containing an error message.

Did you ever find any soundcloud bugs? :) leave me a comment
