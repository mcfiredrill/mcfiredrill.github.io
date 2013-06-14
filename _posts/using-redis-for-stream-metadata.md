---
layout: post
title: using redis for stream metadata
tags: [redis, liquidsoap, icecast, ruby, rails, metadata, cucumber]
---
Since I figured out my little redis metadata hack, I've switched my sinatra app
to rails. Here's how I tdd'ed the feature with cucumber.

I started out by writing this metadata feature.

### metadata.feature
```
Feature: get metadata

  @redis
  Scenario: get metadata json
    Given metadata is set in redis
    When I request the metadata
    Then I should get the metadata in a json response
```

And the first step definition.

```
Given /^metadata is set in redis$/ do
  $redis.set("currentsong", "a cool song")
end
```

I'm using the redis gem. For now I just set up a single global redis connection
in config/initializers/redis.rb.

### config/initializers/redis.rb
```ruby
file = File.join(File.expand_path(::Rails.root),"/config/redis.yml")
REDIS_CONFIG = YAML.load(ERB.new(File.read(file)).result).symbolize_keys
$redis = Redis.new(REDIS_CONFIG)
```

This satisfies the first step, now for the second.

```
When /^I request the metadata$/ do
  get '/metadata.json'
end
```

I'll make a route in application controller for this.

```
  def metadata
    song = $redis.get "currentsong"
    respond_to do |format|
      format.json {
        render :json => {:currentsong => song}
      }
    end
  end
```

And now for the last step.

```
Then /^I should get the metadata in a json response$/ do
  JSON.load(last_response.body).should ==  {"currentsong" => "a cool song"}
end
```

If we run this we can see it passes.
