Liquidsoap is a bit of a framework for managing streams. Icecast by itself is
great, but as your radio grows, you end up growing a small ecosystem of assorted
bash scripts and the like around your icecast stream. Managing dump files,
transcoding and perhaps updating external services are all part of various
things that need to get done.

Liquidsoap can help. You write a configuration file in liquidsoap's scripting
language. You can do various things such as playing a playlist when there is no
live dj source connected, transitions between sources, really anything you can
think of.

Here is a little sample script. I won't go too much into the details, but it
takes care of handling live dj sources, backup playlist sources, and transcoding
the stream to both ogg and mp3.

{% highlight %}
  #!/usr/local/bin/liquidsoap

  # some boilerplate
  set("log.file",true)
  set("log.file.path","/usr/local/var/log/liquidsoap/liquidsoap.log")
  set("log.stdout",false)
  set("log.level",3)

  set("server.telnet",true)
  set("server.socket",true)
  set("server.socket.path","/tmp/liquidsoap.sock")

  set("harbor.bind_addr","0.0.0.0")

  # The file source
  backup_playlist = playlist(reload=600,"/var/www/radio/shared/playlist.m3u",conservative=true)
  output.dummy(fallible=true,backup_playlist)
  # live input from the harbor
  live_dj = input.harbor("datafruits",port=9000)
  
  # in case of failure, play this single file
  on_fail = single("/var/www/radio/shared/failure.wav")

  source = fallback(track_sensitive=false,
                    [live_dj,backup_playlist,on_fail])

  # dump the live input to a file
  output.file(%mp3, "/mnt/wat/dump-%d-%m-%Y-%H:%M:%S.mp3", live_dj,fallible=true)
  # We output the stream to an icecast
  # server, in ogg/vorbis format.
  output.icecast(%vorbis,id="icecast",
                 mount="mystream.ogg",
                 host="localhost"
                 icy_metadata="true",description="datafruits.fm",
                 source)
  output.icecast(%mp3,id="icecast",
                 mount="mystream.mp3",
                 host="localhost"
                 icy_metadata="true",description="datafruits.fm",
                 source)
{% endhilight %}

I wanted to set the metadata of my stream when a live dj connected. There
didn't seem to be a way to do this with the source client I was using (shoutvst).
I came up with a scheme for authenticating source clients against a database of
the dj's, then I could grab their username when they authenticate in the
liquidsoap script and update the metadata accordingly.

There's a little function called `input.harbor` that is essentially like a tiny
icecast server inside of liquidsoap that accepts input from external sources.
You can connect to these with any standard icecast client. Turns out, you can
pass the habor a function that it uses to authenticate the source client.

{% highlight %}
  # refs
  title_prefix = ref ""

  live_dj = input.harbor("mystream",port=9000,auth=dj_auth,on_disconnect=on_disconnect)

  def dj_auth(user,password) =
    # get the output of the ruby script
    ret = get_process_lines("bundle exec /var/www/radio/current/dj_auth.rb #{user} #{password}")
    # ret has now the value of the live client (dj1,dj2, or djx), or "ERROR"/"unknown"
    ret = list.hd(ret)
    # return true to let the client transmit data, or false to tell harbor to decline
    if ret == "true" then
      title_prefix := "LIVE NOW ♫✩ -- #{user} ✩♪" 
      true
    else
      false
    end
  end
{% endhilight %}
