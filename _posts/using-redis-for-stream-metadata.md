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

```
  Scenario: get metadata json                         # features/metadata.feature:3
    Given metadata is set in redis                    # features/step_definitions/metadata_steps.rb:3
      Error connecting to Redis on 127.0.0.1:6379 (ECONNREFUSED) (Redis::CannotConnectError)
      /home/tony/.rvm/rubies/ruby-2.0.0-p195/lib/ruby/2.0.0/monitor.rb:211:in `mon_synchronize'
      features/metadata.feature:4:in `Given metadata is set in redis'
    When I request the metadata                       # features/step_definitions/metadata_steps.rb:7
    Then I should get the metadata in a json response # features/step_definitions/metadata_steps.rb:11

Failing Scenarios:
cucumber features/metadata.feature:3 # Scenario: get metadata json

1 scenario (1 failed)
3 steps (1 failed, 2 skipped)
0m0.066s
``


Looks like it couldn't connect to redis. We can make a cucumber tag @redis to
set up redis for any tests that require redis.

### metadata.feature
```
Feature: get metadata

  @redis
  Scenario: get metadata json
    Given metadata is set in redis
    When I request the metadata
    Then I should get the metadata in a json response
```

Add this to the end of features/support/env.rb.

### features/support/env.rb
```
REDIS_PID = "#{Rails.root}/tmp/pids/redis-test.pid"
REDIS_CACHE_PATH = "#{Rails.root}/tmp/cache/"

ENV['REDIS_HOST'] = "localhost"

Before('@redis') do
  redis_options = {
    "daemonize"     => 'yes',
    "pidfile"       => REDIS_PID,
    "port"          => 6379,
    "timeout"       => 300,
    "save 900"      => 1,
    "save 300"      => 1,
    "save 60"       => 10000,
    "dbfilename"    => "dump.rdb",
    "dir"           => REDIS_CACHE_PATH,
    "loglevel"      => "debug",
    "logfile"       => "stdout",
    "databases"     => 16
  }.map { |k, v| "#{k} #{v}" }.join("\n")
  `echo '#{redis_options}' | redis-server -`
end

After('@redis') do
  %x{
    cat #{REDIS_PID} | xargs kill -QUIT
    rm -f #{REDIS_CACHE_PATH}dump.rdb
  }
end
```

This will go ahead and start up redis on any features tagged `@redis`, and kill
the server after those features finish running. The feature will pass now.

```
  @redis
  Scenario: get metadata json                         # features/metadata.feature:4
    Given metadata is set in redis                    # features/step_definitions/metadata_steps.rb:3
    When I request the metadata                       # features/step_definitions/metadata_steps.rb:7
    Then I should get the metadata in a json response # features/step_definitions/metadata_steps.rb:11

1 scenario (1 passed)
3 steps (3 passed)
0m0.599s
```

Some things I need to add to this:
* make sure the controller attempts to reconnect to redis if it can't connect
* refactor global $redis variable
* think of store other things in redis?
