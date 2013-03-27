---
layout: post
title: simple authentication in sinatra
---

I wanted authentication in my sinatra app for http://datafruits.fm/, so I 
decided to roll my own in the simplest way possible. I set up two "service"
classes to handle the authentication of users, and the creation of users. This
can help avoid nasty things like callbacks for hashing passwords when you're creating
a new user. Putting the actual authentication mechanism in its own class helps separation of concerns.

Lets see what we want this interface to look like.
