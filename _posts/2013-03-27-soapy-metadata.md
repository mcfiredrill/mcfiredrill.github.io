---
layout: post
title: soapy metadata
tags: [liquidsoap, icecast, redis, ruby, streaming]
---

My internet radio station datafruits.fm needed metadata in its audio stream.
I wanted to make a cool hack to set metadata using liquidsoap. This would solve 2 problems:

* dj's are unable to set metadata with their clients, so I'll do it for them when they authenticate.
* the `<audio>` tag is unable to read the metadata from the stream. I'll have to get it some other way.

I'll have liquidsoap call a ruby script when the metadata in the stream changes, using `on_meta`. We'll store
the metadata in redis, using pub-sub. Then I'll set up a controller to relay this metadata.

As a bonus I now effectively have an api for getting the current song that I can
use in my mobile apps for this radio.

### pub_metadata.rb

```ruby
# adopted from https://github.com/gorsuch/sinatra-streaming-example/blob/master/worker.rb

require 'redis'

redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
uri = URI.parse(redis_url)
r = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

meta = ARGV[0]

puts "setting metadata..."
r.publish "metadata", meta
```

### radio.liq

{% highlight ruby %}
source = on_metadata(pub_metadata, source)

def pub_metadata(m) =
  log("metadata changed: #{m}")
  title = m["title"]
  result = get_process_lines("./pub_metadata.rb #{m}")
  log("pub_metadata: #{result}")
end
{% endhighlight %}

I wanted to use streaming in Sinatra to update the metadata quickly, instead of polling.

### sinatra_app.rb
```ruby
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

Then we can do something like this in the javascript:

```javascript
var source = new EventSource('/metadata');
source.addEventListener('refresh', function(e){
  console.log("got sse");
  console.log(e.data);
  $('#nowplaying').html(e.data);
});
```

This was a little bit more difficult to manage than I expected. It was working
sporadically, and it turns out you need to manage all the connections by hand,
you can't just code one connection and expect it to work.

So I decidedly to go with the certainly not as cool solution of using polling.
However I think its a perfectly fine solution for this situation. Polling is
simple, fairly cheap, and as far as this situation goes, truly 'live' updating
of the metadata is not really necessary.

So I ended up just using a regular redis key.

### pub_metadata.rb

```ruby
# adopted from https://github.com/gorsuch/sinatra-streaming-example/blob/master/worker.rb

require 'redis'

redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
uri = URI.parse(redis_url)
r = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

meta = ARGV[0]

puts "setting metadata..."
puts r.set "currentsong", meta
```

We can just set up a normal get route to get the key.

### sinatra_app.rb

```ruby
  redis_url = ENV["REDISTOGO_URL"] || "redis://localhost:6379"
  uri = URI.parse(redis_url)
  set :redis, Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  get '/metadata' do
    settings.redis.get("current-song").to_s
  end
```

A simple set setInterval will work for polling and updating the html.

```javascript
  setInterval(function(){
    $.get("/metadata",function(data){
      console.log("got data: "+data);
      $('#nowplaying').html(data);
    });
  },5000);
```

While not as cool, this is a lot easier to work with at the moment. Perhaps I
can think of other radio data I could store in redis and attach an API to from my app.
