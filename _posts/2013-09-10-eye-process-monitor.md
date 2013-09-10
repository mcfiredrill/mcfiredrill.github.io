---
layout: post
title: eye process monitoring tool
tags: [monitoring, ruby, resque]
---
When you start working with background jobs, you're going to want a reliable way to monitor those processes. I first started out with monit. I found its configuration file a bit ugly. Here is an example config file:

{% highlight bash %}
check process resque_worker
  with pidfile /var/www/vhosts/myapp/shared/tmp/pids/resque_worker.pid
  start program = "/usr/bin/env HOME=/home/deploy RACK_ENV=production
  PATH=/usr/local/bin:/usr/local/ruby/bin:/usr/bin:/bin:$PATH /bin/sh -l -c 'cd /var/www/vhosts/myapp/current; nohup bundle exec rake environment resque:work  RAILS_ENV=production QUEUE=my_queue VERBOSE=1 PIDFILE=tmp/pids/resque_worker.pid COUNT=2 >> log/resque_worker.log 2>&1'" as uid deploy and gid deploy with timeout 60 seconds
  stop program = "/bin/sh -c 'cd /var/www/vhosts/myapp/current && kill -9 `cat tmp/pids/resque_worker.pid` && rm -f tmp/pids/resque_worker.pid; exit 0;'"
  if totalmem is greater than 800 MB for 10 cycles then restart  # eating up memory?
  group resque_workers
{% endhighlight %}

And that's just one process!

Also ran into lots of problems where the pid file wasn't being found, etc. What happens when the pid file doesn't exist? Should it be created? What if there is already a pid file that didn't get deleted properly last time? These are all problems a process manager should solve.

I tried bluepill next. The configuration syntax is nice, its written in ruby.

However it seemed painfully slow. Also I'm afraid I have to agree with this rather brief and undetailed bug report from Jeff Atwood:
https://github.com/arya/bluepill/issues/193

So I found a more recent project called eye. Its inspiration comes from bluepill but its incredibly fast and has worked very reliably for me. 

https://github.com/kostya/eye

The configuration is quite nice:

{% highlight ruby %}
Eye.application "resque" do
    env 'PATH' => '/usr/local/bin:/usr/local/ruby/bin:/usr/bin:/bin:$PATH',
        'VERBOSE' => '1',
        'COUNT' => '2'
  process :resque_worker do
    start_command "/usr/bin/env /bin/sh -l -c 'bundle exec rake environment resque:work'"
    pid_file "/var/www/vhosts/myapp/shared/tmp/pids/resque_worker.pid"
    daemonize true
    env 'RAILS_ENV' => 'production',
        'RACK_ENV' => 'production',
        'QUEUE' => 'my_queue'
    working_dir "/var/www/vhosts/myapp/current"
    stdall "/var/www/vhosts/myapp/shared/log/resque_worker.log"
  end
end
{% endhighlight %}


You can add more `process` blocks for more resque workers.

I've been using eye now to manage lots of different processes now including
hubots, sinatra apps, liquidsoap, etc. Its great to use with capistrano to
restart the processes on deploy. All you have to do is send your process or
group of processes the stop,start, restart commands. Be sure to reload your
config file to pick up any changes you may have made.

{% highlight ruby %}
namespace :resque do
  desc "Start resque process"
  task :start, :roles => :app do
    run "cd #{latest_release} && #{sudo} eye l config/resque.eye"
    run "#{sudo} eye start resque_worker"
  end

  desc "Stop resque process"
  task :stop, :roles => :app do
    #{sudo} eye stop resque_worker;
  end

  desc "Restart resque process"
  task :restart, :roles => :app do
    #{sudo} eye restart resque_worker;
  end
end

after "deploy:start", "resque:start"
after "deploy:stop", "resque:stop"
after "deploy:restart", "resque:restart"
{% endhighlight %}

Now I am working on integrating eye with hubot to restart processes via chat!
