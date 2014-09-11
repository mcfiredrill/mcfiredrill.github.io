---
layout: post
title: icecast source client hack
tags: [liquidsoap, icecast, ruby, streaming]
---

I've thought of a great hack to overcome the limitations that most icecast clients don't let you specify the 'source' field. At first I thought of maybe finding a user by password rather than username. Then I thought, why not just use the password field for the username and password? The username and password can be separated by something like a semicolon. Here's how I implemented this in liquidsoap:

{% highlight ruby %}
def get_user(user,password) =
  if user == "source" then
    x = string.split(separator=';',password)
    list.nth(x,0)
  else
    user
  end
end

def get_password(user,password) =
  if user == "source" then
    x = string.split(separator=';',password)
    list.nth(x,1)
  else
    password
  end
end

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
    true
  else
    false
  end
end

# use the auth function with input.harbor
live_dj = input.harbor("datafruits",port=9000,auth=dj_auth,on_disconnect=on_disconnect)
{% endhighlight %}

You simply check if the username sent was 'source' and then split the password string at ';'.

{% include mailchimp.html %}
