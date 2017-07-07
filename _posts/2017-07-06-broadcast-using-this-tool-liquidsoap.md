---
layout: post
title: "debugging broadcast using this tool without compiling it"
tags: [liquidsoap, icecast]
---

For some reason an icecast client known as BUTT (Broadcast Using This Tool)
simply refused to work with [Streampusher](https://streampusher.com).

BUTT works normally with Liquidsoap's harbor, so I thought it must have be something
wrong with my code.

I use a small ruby script to authenticate the harbor, like this:
{% highlight ruby %}
def dj_auth(user,password) =
  u = get_user(user,password)
  p = get_password(user,password)
  ret = get_process_lines("bundle exec ruby dj_auth.rb '#{u}' '#{p}' '#{radio_name}'")
  ret = list.hd(default="",ret)
  #return true to let the client transmit data, or false to tell harbor to decline
  if ret == "true" then
    title_prefix := "LIVE -- #{u}"
    true
  else
    false
  end
end

live_dj = audio_to_stereo(input.harbor("#{radio_name}",id="live_dj",port=9000,auth=dj_auth,on_disconnect=on_disconnect,logfile="/tmp/liquidsoap_harbor.log",bu
ffer=15.0,max=30.0))
{% endhighlight %}

When I tried to connect using BUTT, it would simply hang. I decided to try to
compile BUTT to try to debug, but I was unable to get it to compile.

I started reading
[icecast.cpp](https://github.com/melchor629/butt/blob/master/src/icecast.cpp),
trying to find anything related to some sort of timeout.

This code looked a bit suspicious.
{% highlight c %}
  if(sock_recv(&stream_socket, recv_buf, sizeof(recv_buf)-1, RECV_TIMEOUT) == 0)
  {

      if (try_cnt == 0)
      {
	  ic_disconnect();
	  continue; //try SOURCE method if PUT method did not work
      }
      else
      {
	  usleep(100000);
	  ic_disconnect();
	  return 1;
      }
  }
{% endhighlight %}

What I took from this is that `sock_recv` seems to be timing out.

The [RECV_TIMEOUT](https://github.com/melchor629/butt/blob/master/src/sockfuncs.h#L38) constant is set to 1000ms.
{% highlight c %}
enum {
    CONN_TIMEOUT = 1000,
    SEND_TIMEOUT = 3000,
    RECV_TIMEOUT = 1000
};
{% endhighlight %}

After some experimenting with timing the ruby script, I found that it always
took longer than 1000ms to finish running. If I changed the script to run
against a local test server, it completed under 1000ms and BUTT connected just fine!

But connecting against the real server always took 1000ms. How can I make it run
faster? I tried some things like using the script without bundler, using built
in libraries instead of Gems, but this didn't really help. Was my auth server
too slow?

Looking at my rails logs, the auth action itself only takes 140ms. Does it
really take another 800ms or so for the http request to go across the internet?

All the ruby script does is make an http request and parse the json response. I
decided to test the request using curl. With curl it was much faster than ruby.

Perhaps I could rewrite the auth script in bash. But how could I parse json in
bash? Turns out jq is a great tool for this job.

With the bash script the request completes under 1000ms and now BUTT works with
[Streampusher](https://streampusher.com) just fine.

{% highlight bash %}
$ time ./dj_auth.sh mcfiredrill xxxxxx
true

real    0m0.901s
user    0m0.020s
sys     0m0.011s
{% endhighlight %}
