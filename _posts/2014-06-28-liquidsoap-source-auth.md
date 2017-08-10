---
layout: post
title: liquidsoap source authentication
tags: [liquidsoap, authenitication, ruby]
---

Setting up source authentication in liquidsoap is pretty easy (although you may find an aforementioned hack useful, depending on what source client you may be using).

If you are using input.harbor, you can supply a function that returns true or false to be used as an authentication mechanism. Since you can call any external script in said function, its possible to connect to an external database of users to authenticate.

Just as an example, here is what I use, its a ruby script that uses the json api on my rails app running on heroku to log in. It simply returns true or false based on the result of the login.

dj_auth.rb

{% highlight ruby %}
#!/usr/bin/env ruby

Bundler.require

require 'httparty'

username = ARGV[0]
password = ARGV[1]

opts = { body: { :user => {"login" => username, "password" => password} } }

resp = HTTParty.post("http://www.datafruits.fm/login.json", opts)
if resp["success"] == true
  puts true
else
  puts false
end
{% endhighlight %}

Define a function in liquid soap that calls this external script, and you can pass that function as the auth parameter to input.harbor

{% highlight ruby %}
#auth function
def dj_auth(user,password) =
  u = get_user(user,password)
  p = get_password(user,password)
  #get the output of the script
  ret = get_process_lines("bundle exec ./dj_auth.rb #{u} #{p}")
  ret = list.hd(ret)
  #return true to let the client transmit data, or false to tell harbor to decline
  if ret == "true" then
    true
  else
    false
  end
end
{% endhighlight %}

{% highlight ruby %}
live_dj = input.harbor("datafruits",port=9000,auth=dj_auth,on_disconnect=on_disconnect)
{% endhighlight %}

Keep in mind, in some clients there is stupidly no option to set the source
password. If your djs are using said clients, you have a couple of options. You
could use a silly hack I mentioned in a [previous post]{% post_url 2013-09-01-icecast-source-client-hack %}, where you simply enter the password in the same field separated by some character and parse that. I use this method, I instruct DJs to enter their username and password separated by a semicolon if their source client has no option to set the username.

I’m currently [writing a book about liquidsoap!](https://gumroad.com/products/JVXcv)

{% include mailchimp.html %}
