---
layout: post
title: "introduction to liquidsoap's programming language"
tags: [liquidsoap]
---

I'd like to write a post to try to understand liquidsoap's own scripting
language. Liquidsoap is a *functional* language, which you may find confusing if
you have not programmed much before. In functional languages you can't do things you
might be used to doing in other languages like mutating values, changing state, etc.

## types

The basic types in liquidsoap are integers, floats, strings and booleans.

* integers `42`
* floats `3.33`
* strings `"foo"`
* booleans `true` or `false`

You probably are quite familar with these if you have programmed before. There are other types specific to liquidosoap,
these are

* source (produces a stream)
* request (something that a stream will play, like a file)
* format (for different audio/video encodings)

and a few others.

## no changing variables

Since liquidsoap is a functional language, there are no variables, only
definitions. So in this example, I'm not really changing the value of the
`source` variable,  I'm simply creating new ones and using the same name.

{% highlight ruby %}
source = fallback(track_sensitive=false,
                  [live_dj,backup_playlist,on_fail])
source = on_metadata(pub_metadata, source)

source = server.rms(source)
{% endhighlight %}

## no unused variables

You aren't allowed to declare a variable and then not use it, liquidsoap will
complain:

{% highlight ruby %}
At line 6, character 15: The variable some_variable defined here is not used
  anywhere in its scope. Use ignore(...) instead of some_variable = ... if
  you meant to not use it. Otherwise, this may be a typo or a sign that
  your script does not do what you intend.
{% endhighlight %}

## static typing

Liquidsoap is statically typed, but the types are inferred. This means you won't
have to write types like in C or Java.

## function notation in the API docs

The function notation used in the liquidsoap [api
documentation](http://savonet.sourceforge.net/doc-svn/reference.html) may be a
bit daunting at first. For example here is the documentation for `input.harbor`:

{% highlight ruby %}
(?id:string,?auth:((string,string)->bool),?buffer:float,
 ?debug:bool,?dumpfile:string,?icy:bool,
 ?icy_metadata_charset:string,?logfile:string,?max:float,
 ?metadata_charset:string,
 ?on_connect:(([(string*string)])->unit),
 ?on_disconnect:(()->unit),?password:string,?port:int,
 ?timeout:float,?user:string,string)->source('a)
{% endhighlight %}

All the question marks are simply optional named arguments and usually described
in the function's documentation. Required arguments are marked with a `~`
instead of a question mark.

`?id:string`

This is a optional parameter called `id` that is a type `string`.

`?on_disconnect:(()->unit)`

This is an optional parameter called on_disconnect that takes a function that is
of type `()->unit`, which is a function that takes no arguments and returns
`unit`. What's a `unit`, you ask? From the [wikipedia page](http://en.wikipedia.org/wiki/Unit_type)

{% highlight ruby %}
In the area of mathematical logic and computer science known as type theory, a
unit type is a type that allows only one value (and thus can hold no
information).
{% endhighlight %}

In simple terms, a unit is returned when you don't care about the return value.
In other languages, you could simply not return anything. However, in functional
languages, all functions *must* return a value, so we denote the return value as
`unit` when we don't care about the return value.

`[t]` are lists and `(t*t)` are 'pairs' (or 'tuples' if you come from another
language like Python).

`([(string*string)])->unit`

This is a function that takes a list of `(string*string)` (such as `("a","b")`) tuples and returns a
unit.

Finally you can see what this function returns by looking at the arrow(`->`) at
the end.

`->source('a)`

This means the function returns a source type.

## defining functions

We can define a function with `def` and `end` to mark the end of a function.

{% highlight ruby %}
  def function_name(arguments) =
    function_body
  end
{% endhighlight %}

like so:

{% highlight ruby %}
def get_user(user,password) =
  if user == "source" then
    x = string.split(separator=';',password)
    list.nth(x,0)
  else
    user
  end
end
{% endhighlight %}

The return type of the function is simply the last line of the body of the
function. So in the case of the function above, it would be string.

## refs

Liquidsoap is a functional language, however it is not a *pure* functional language. You can use mutatable variables if
you want to. Liquidsoap borrows a concept from ocaml known as `ref`:

{% highlight ruby%}
title = ref ""
current_dj_name = ref ""
{% endhighlight %}


Check out the [official liquidsoap
language reference](http://savonet.sourceforge.net/doc-svn/language.html) for more.

{% include mailchimp.html %}
