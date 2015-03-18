---
layout: post
title: "the icecast/liquidsoap metadata guide"
tags: [liquidsoap, icecast, metadata, jplayer]
---

You will likely want to customize the metadata of your stream to change in various ways, be it
the currently playing DJ or song or something else.

## Files/Playlists

For files in backup playlists, the metadata is read directly from the files. The best thing to do is to have your files tagged properly. If you want to change the metadata in some other way it is possible.

### Annotate protocol in playlist file
If you are using a playlist file, a simple way to change the metadata of the files is to add some annotations to the playlist file using the annotate protocol.

{% highlight ruby %}
annotate:title="Title 1",artist="Artist 1":music1.mp3
annotate:title="Title 2",artist="Artist 2":music2.mp3
{% endhighlight %}

### Rewrite metadata

The `rewrite_metadata` is a way to replace certain metadata keys with others.

{% highlight ruby %}
rewrite_metadata(["metadata",pattern],source)
{% endhighlight %}

I think the idea behind using this is maybe you would want to replace the metadata with custom metadata you have entered with the annotate protocol.

Pattern is two strings `"a, b"` which will replace the occurence of `b` with `a`.
For example `pattern` could be:

{% highlight ruby %}
'"$(artist)", "$(title)"'
{% endhighlight %}

Then you would use the function like this:

{% highlight ruby %}
pattern = '$(if $(title),"$(artist)"," $(title)")'
source = rewrite_metadata([("title",pattern)],source)
{% endhighlight %}

This will replace the `title` metadata with the `artist` metadata.

There is also an if statement operator, in case the metadata you want to rewrite is blank, the function won't be called.

{% highlight ruby %}
pattern = '$(if $(title)), "$(title)", "$(title) - my radio station"'
source = rewrite_metadata(["title", pattern], source)
{% endhighlight %}

### Map metadata

Honestly I think `map_metadata` is a lot easier to use, and if you have simple needs it may be better for you.

{% highlight ruby %}
def append_title(m) =
  # Grab the current title
  title = m["title"]

  # Return a new title metadata
  [("title","#{title} - www.station.com")]
end

# Apply map_metadata to s using append_title
s = map_metadata(append_title, s)
{% endhighlight %}

Using this syntax you can replace any element of the metadata, title, artist, etc.

## Live streams

To rewrite the metadata in my live stream, I keep track of a `ref` called `title_prefix` that I set when my dj authenticates to the stream.

{% highlight ruby %}
#auth function
def dj_auth(user,password) =
  u = get_user(user,password)
  p = get_password(user,password)
  #get the output of the php script
  ret = get_process_lines("bundle exec ./dj_auth.rb #{u} #{p}")
  #ret has now the value of the live client (dj1,dj2, or djx), or "ERROR"/"unknown"
  ret = list.hd(ret)
  #return true to let the client transmit data, or false to tell harbor to decline
  if ret == "true" then
    title_prefix := "LIVE NOW ♫✩ -- #{u} ✩♪"
    current_dj := "#{u}"
    true
  else
    false
  end
end
{% endhighlight %}

Then I set the metadata with this ref, using `map_metadata`:

{% highlight ruby %}
def new_meta(m) =
  if "#{title_prefix}" == "" then
    title = m["title"]
    [("title","#{title}")]
  else
    [("title","#{!title_prefix}")]
  end
end

live_dj = map_metadata(new_meta, live_dj, update=false)
{% endhighlight %}

I will discuss dj authentication more in the next chapter.

### Strip metadata from Traktor

If your DJs stream with Traktor, you may notice that Traktor automatically inserts the track's metadata into the stream. If you wish to remove this, its possible. By default, `map_metadata` updates the metadata with the value returns, and keeps the other metadata you did not specify to update. If you wish to remove the other metadata you did not explicitly specify, just pass the `update=false` option to `map_metadata`:

{% highlight ruby %}
live_dj = map_metadata(new_meta, live_dj, update=false)
{% endhighlight %}

## Is the metadata there?

In case you don't know, you can check the metadata by going to the icecast
status page on `localhost:8000`.

![icecast screenshot](/assets/images/icecast_screenshot.png)

## icy_metadata=true

You want to make sure this parameter is set when calling `output.icecast`.

{% highlight ruby %}
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

## Metadata from icecast json/xml

If you are embedding an HTML5 or flash player on your site, you may find it difficult to get the metadata displaying in the player properly. Most HTML5 players don't seem to read the metadata directly from the stream very well. Icecast provides a JSON endpoint with current metadata and statistics.

{% highlight ruby %}
http://myserver.com:8000/status-json.xsl
{% endhighlight %}

Don't ask why the extension is .xsl when its actually json data, I have no clue. The json support was introduced only recently, and before only XML format was available.

You can use this file to set your player's metadata if you know a little bit of Javascript. This example inserts the title into a div with a class named `jp-title`, using jQuery to fetch the JSON from the icecast server and parse it.


{% highlight javascript %}
var radioTitle = function(){
  var url = 'http://myserver.com:8000/status-json.xsl';

  $.get(url, function(data){
    var title = data.icestats.source[0].title;
    $('.jp-title').html(title);
  });
}
{% endhighlight %}

Now just call this function periodically, say every 10 seconds, with `setInterval`.
{% highlight javascript %}
  setInterval(radioTitle, 10000);
{% endhighlight %}

{% include mailchimp.html %}
