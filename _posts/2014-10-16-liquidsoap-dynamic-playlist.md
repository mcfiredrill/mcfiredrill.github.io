---
layout: post
title: "liquidsoap dynamic playlist"
tags: [liquidsoap]
---
In my [liquidsoap getting started guide]({% post_url 2014-09-21-liquidsoap-getting-started %}) I show you how to use a simple text
based playlist. In this guide I wanted show you how to use `request.dynamic` to
build a playlist that is based on any function at all, not just reading a simple
text file. You could determine the next song by user votes, hitting some
arbitrary HTTP api, randomly, the results are limitless.

On datafruits I mostly use this to add the most recent podcasts to the playlist,
as well as mix in jingles every couple of tracks. Its actually a function that
calls a ruby script that connects to redis to determing the next track to play.

{% highlight ruby %}
def my_request_function () =
  result = get_process_lines("bundle exec ./next_song.rb")
  log("next song: #{result}")
  request.create(list.hd(result))
end
{% endhighlight %}

I have to mark this source as fallible, since its calling an external script.

{% highlight ruby %}
backup_playlist = request.dynamic(my_request_function)
output.dummy(fallible=true,backup_playlist)
{% endhighlight %}

Then I hook this up to my normal fallback mechanism.
{% highlight ruby %}
source = fallback(track_sensitive=false,
                  [live_dj,backup_playlist,on_fail])
{% endhighlight %}

You can pass any function to request.dynamic. You typically enqueue a new song
with `request.create`.

You'll see something like this in the logs.

{% highlight ruby %}
2014/09/30 14:58:32 [request.dynamic_5130:3] Prepared "/tmp/playlist/Mondaystudio_Nov23_2013.mp3" (RID 3).
{% endhighlight %}

Then this when the track finishes.

{% highlight ruby %}
2014/09/30 15:20:09 [request.dynamic_5130:3] Finished with "/tmp/playlist/Mondaystudio_Nov23_2013.mp3".
{% endhighlight %}

Since the script for enqueuing the next request can be *any program*, the
possibilities are really limitless here. The next track could be the result of a
tweet, a user request on a webpage, a telnet command, or anything else you can
think of. I will go into more possibilities in an upcoming post.

Here is the [documentation on request sources from savonet's site](http://savonet.sourceforge.net/doc-svn/request_sources.html).

{% include mailchimp.html %}
