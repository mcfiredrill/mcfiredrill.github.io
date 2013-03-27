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
``` Ruby
# adopted from https://github.com/gorsuch/sinatra-streaming-example/blob/master/worker.rb
 
require 'redis'
 
redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
uri = URI.parse(redis_url)
r = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
 
meta = ARGV[0]
 
puts "setting metadata..."
r.publish "metadata", meta
```

## radio.liq
```
source = on_metadata(pub_metadata, source)
 
def on_metadata(m) =
log("metadata changed: #{m}")
result = get_process_lines("./pub_metadata #{m}")
log("pub_metadata: #{result}")
end
```

I wanted to use streaming in Sinatra to update the metadata quickly, instead of polling. 

## sinatra_app.rb
``` Ruby
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
```

And this is what the javascript looked like to update that metadata:
