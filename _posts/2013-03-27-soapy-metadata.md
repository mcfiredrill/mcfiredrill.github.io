---
layout: post
title: "soapy metadata"
description: ""
category: 
tags: []
---
{% include JB/setup %}

## soapy metadata

### wut?

My internet radio station datafruits.fm needed metadata in its audio stream.
I wanted to make a cool hack to set metadata using liquidsoap. This would solve 2 problems:

* dj's are unable to set metadata with their clients, so I'll do it for them when they authenticate.
* the `<audio>` tag is unable to read the metadata from the stream. I'll have to get it some other way.

I'll have liquidsoap call a ruby script when the metadata in the stream changes, using `on_meta`.

#### pub_metadata.rb
{% highlight ruby %}
  #adopted from https://github.com/gorsuch/sinatra-streaming-example/blob/master/worker.rb
   
  require 'redis'
   
  redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
  uri = URI.parse(redis_url)
  r = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
   
  meta = ARGV[0]
   
  puts "setting metadata..."
  r.publish "metadata", meta
{% endhighlight %}

