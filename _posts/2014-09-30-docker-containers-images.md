---
layout: post
title: "docker containers vs docker images"
tags: [docker]
---

Docker is often portrayed as a beautiful blue whale shipping containers full of rails apps.

![totally the official docker logo(>_>)](/assets/images/docker_whale.png)

The 'container' metaphor is pretty easy to grasp I think. What you might not
realize is there is the concept of ‘images’ as well. Think of images as a
blueprint or plan for creating a new container. They are what you can store on
the [docker index](hub.docker.com).

When you first start using docker you might get a bit confused on the concepts of images and containers.

Here is a little cheatsheet:

## For IMAGES:
{% highlight bash %}
docker run
docker rmi
docker build
docker pull
{% endhighlight %}

## For CONTAINERS:
{% highlight bash %}
docker stop
docker restart
docker start
docker rm
docker kill
{% endhighlight %}


Its by no means a complete list, but its what I am using the most in my day to
day work.

If you run an image with a name, then stop it, you can’t run it again with the same name.
You’d have to remove it then run it again. This is a mistake I often made
starting out. If you use the `-a` option with `docker ps`, you can see a list of
all containers, including stopped ones.

If you want to start the same container, you can just use `docker start` (or
`docker restart`).

`docker start`

If you want to create a new container with the same name (perhaps you forgot to pass some options
to `docker run`) you can rm the container and create a new one.

`docker rm`

You can remove an image if you no longer need it as well.

`docker rmi`
