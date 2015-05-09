---
layout: post
title: "icecast proxy for listeners and source clients"
tags: [icecast, proxy, node]
---

You might make to make an icecast proxy if you want to serve icecast on a different port. You can’t change the port setting of icecast directly, for whatever reason, but you can create a proxy to route requests from a different port, say 80, to icecast’s default port 8000.

At first I tried using nginx as an HTTP proxy for icecast. Proxying the listener traffic seemed to work just fine. The source clients could connect to the proxy, but I couldn’t get anything coming out the other end. I thought of something, what kind of request do source clients send? Probably PUT, POST or patch, I thought?

## is icecast really HTTP or not?

Of course it is.
Well, it depends on who you’re talking to, or at least which side of ice cast. The listeners who connect is pure HTTP. The source clients are a different story.

Source clients use a completely *non-standard* HTTP method called SOURCE. I haven't the slightest idea why the development team made this decision. Icecast is a pretty old project by now, who knows maybe REST ideas just hadn't taken enough hold back then. However this has been deprecated since icecast 2.4 and PUT is now preferred. However call me when the icecast source clients (aside from the ones the icecast dev team maintains) actually update and change to support this. As of this writing, Traktor still sends SOURCE.

SO what does this mean if you are trying to run icecast through a reverse proxy using an http server such as nginx as apache? If you've ever written anything dealing with HTTP, you have probably checked the HTTP method and rejected anything that didn't smell like a normal HTTP method (GET, POST, PUT, PATCH or DELETE). So using a non-standard method like SOURCE, its not going to work out quite well with most projects that are written to work with HTTP, such as nginx or node’s http library.

## a solution in….node?

I know I know. But I did recently do this kind of thing for a client project and it seemed to work out pretty well. Node’s streaming make it simple to create a proxy with `pipe()`.

You can use http for the listeners.
Here is how I made the http proxy, to proxy port 8000 to port 80.

{% highlight coffeescript %}
http         = require('http')

class HttpProxyServer
  constructor: (@port) ->

  start: =>
    http.createServer(@proxyRequest).listen(@port)

  proxyRequest: (request, response) =>
    request_host = url.parse("http://#{request.headers.host}").hostname
    proxy_host = "http://myproxyhost.com"
    method = request.method
    headers = request.headers
    options = {hostname: proxy_host, path: path, port: @port, method: method, headers: headers}

    logger.info "proxying #{method} #{request_host}:8000/#{path} to #{proxy_host}:#{port}/#{path}"
    proxy_request = http.request(options)
    proxy_request.on 'response', (proxy_response) ->
      response.writeHead(proxy_response.statusCode, proxy_response.headers)
      proxy_response.pipe(response)
      proxy_response.on 'close', ->
        response.end()

      proxy_response.on 'end', ->
        response.end()

    request.pipe(proxy_request)

    request.on 'close', ->
      proxy_request.end()

    request.on 'end', ->
      proxy_request.end()

new HttpProxyServer(8000).start()
{% endhighlight %}

You can do almost the same thing for the source clients, but since icecast
source clients aren’t HTTP compliant, it is better to just use a raw TCP proxy.

I tried it with an HTTP proxy and it doesn't seem to work. I'm pretty sure its
because the HTTP libary sees the `SOURCE` http method and blows up because it
doesn't recognize it.

You will have to parse the HTTP headers yourself when writing this proxy but its not too difficult.

I actually use liquidsoap in front of icecast, so I use port 9000. Liquidsoap’s input.harbor is completely compatible with icecast source clients, as far as I can tell.

{% highlight coffeescript %}
net          = require('net')

class TcpProxyServer
  constructor: (@port) ->

  start: =>
    net.createServer(@proxyRequest).listen(@port)

  proxyRequest: (socket) =>
    connected = false
    proxySocket = null

    socket.on 'error', () ->
      logger.info "socket encountered an error"

    socket.on 'end', () ->
      logger.info 'disconnecting proxy socket'
      connected = false
      if proxySocket != null
        proxySocket.destroy()

    socket.on 'data', (data) =>
      if connected == false
        proxy_host = "http://myproxyhost.com"
        options = {host: proxy_host, port: @port}

        proxySocket = net.connect(obj)

        proxySocket.on 'connect', () ->
          connected = true
          logger.info 'connected'
          proxySocket.write(data)

        proxySocket.on 'data', (proxyData) ->
          socket.write(proxyData, 'binary')

        proxySocket.on 'end', () ->
          logger.info 'disconnecting socket'
          connected = false
          socket.end()
      else
        proxySocket.write(data)
{% endhighlight %}

If you were using this with regular icecast, you could use the tcp proxy for both listeners and source clients, since you can’t have two servers listening on the same port on the same machine.

Lessons learned:

  * proxy icecast if you want to use it on a different port
  * don't invent your own HTTP methods
  * go lower level and use TCP if you encounter something that does

Note this is a pretty simplified version of the code, and doesn't properly
handle all cases like errors, etc. I would love to hear any suggestions if you
have them. :)
