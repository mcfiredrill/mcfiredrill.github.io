---
layout: post
title: soapy metadata
---

# soapy metadata

My internet radio station datafruits.fm needed metadata in its audio stream.
I wanted to make a cool hack to set metadata using liquidsoap. This would solve 2 problems:

* dj's are unable to set metadata with their clients, so I'll do it for them when they authenticate.
* the <audio> tag is unable to read the metadata from the stream. I'll have to get it some other way.

I'll have liquidsoap call a ruby script when the metadata in the stream changes, using `on_meta`.

## pub_metadata.rb

{% highlight ruby %}
# adopted from https://github.com/gorsuch/sinatra-streaming-example/blob/master/worker.rb
 
require 'redis'
 
redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
uri = URI.parse(redis_url)
r = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
 
meta = ARGV[0]
 
puts "setting metadata..."
r.publish "metadata", meta
{% endhighlight %}

## radio.liq

{% highlight ruby %}
source = on_metadata(pub_metadata, source)
 
def on_metadata(m) =
log("metadata changed: #{m}")
result = get_process_lines("./pub_metadata #{m}")
log("pub_metadata: #{result}")
end
{% endhighlight %}

I wanted to use streaming in Sinatra to update the metadata quickly, instead of polling. 

## sinatra_app.rb
{% highlight ruby %}
# https://github.com/gorsuch/sinatra-streaming-example/blob/master/web.rb

require 'redis'
require 'sinatra'

configure do
redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
uri = URI.parse(redis_url)
set :redis, Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

get '/metadata' do
  puts "connection made"

  stream do |out|
    settings.redis.subscribe 'metadata' do |on|
      on.message do |channel, message|
        out << "#{message}\n"
      end
    end
  end
end
{% endhighlight %}

This was a little bit more difficult to manage than I expected. It was working
sporadically, and it turns out you need to manage all the connections by hand,
you can't just code one connection and expect it to work.

So I decidedly to go with the certainly not as cool solution of using polling.
However I think its a perfectly fine solution for this situation. Polling is
simple, fairly cheap, and as far as this situation goes, truly 'live' updating
of the metadata is not really necessary.
