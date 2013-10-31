---
layout: post
title: coffeescript tdd setup
tags: [coffeescript, mocha, tdd, grunt]
---

I decided to try to make a small game in Coffeescript. I wanted to carry over my tdd practices from my ruby work. However I was a bit unfamiliar with the coffeescript/node ecosystem. After a bunch of research this is what I've decided to use for now. 

Grunt seems to be a great equivalent to rake. You install different tasks via npm packages. You need to create a package.json.

{% highlight javascript %}
{
  "name": "dumbgame",
  "version": "0.0.0",
  "description": "dumb game i made"
}
{% endhighlight %}

Then just install grunt via npm like so.

{% highlight bash %}
$ npm install grunt --save-dev
{% endhighlight %}

This will save the dependency to your package.json.

Grunt tasks are distributed as npm packages as well. I am using the
grunt-contrib-coffee and grunt-contrib-watch tasks.

{% highlight bash %}
$ npm install grunt-contrib-coffee --save-dev
$ npm install grunt-contrib-watch --save-dev
{% endhighlight %}

Then you can create this Gruntfile.coffee to use these tasks.

{% highlight coffeescript %}
module.exports = (grunt) ->

  grunt.initConfig
    coffee:
      app:
        options:
          sourceMap: true
        files:
          './lib/dumbgame.js': './src/*.coffee'
    watch:
      app:
        files: './src/*.coffee'
        tasks: ['coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['coffee']
{% endhighlight %}

I use the watch task for compiling coffeescript whenever a .coffee file changes. I wasn't sure I would like this workflow at first, but its not so bad. I just run the watch task in another tmux pane and inspect it whenever there is a compile error.

You can use mocha for testing. It can run scripts through a headless browser and has 'should' and 'expect' syntax.
There is a grunt task for running mocha tests. It doesn't work with coffeescript by default unless you pass this `require: coffeescript` option.

The coffee task that is called by the watch task concatenates all my coffeescript files into a single file, and provides a sourcemap for chrome to use. I was surprised the sourcemap worked right away, I didn't need to change any settings in chrome.

Finally the grunt connect task starts an http server to test out my compiled js in the browser.

My setup will hopefully get a little more sophisticated as the need arises, but this should do fine for now. 
