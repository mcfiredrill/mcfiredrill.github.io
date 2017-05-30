---
layout: post
title: "liquidsoap 1.3.0 released"
tags: [liquidsoap]
---

Liquidsoap version 1.3.0 was recently released!
Here are some of the new features and possible gotchas.

You can check out [the full changelog here](https://github.com/savonet/liquidsoap/releases/tag/1.3.0).

## default="" argument

A couple of the list functions now take an argument for the default type. You will have to
update your code. For example:

### before
{% highlight ruby %}
  list.append(l,[(list.nth(v,0),list.nth(v,1))])
{% endhighlight %}

### after
{% highlight ruby %}
  list.append(l,[(list.nth(v,0,default=""),list.nth(v,1,default=""))])
{% endhighlight %}


This affects `list.nth`, `list.assoc`, and `list.hd`.

## issues with env in get_process_lines

An optional argument was added to `get_process_lines` and similar functions to
allow passing in an environment, which is a list of pairs mapping to environment
variable names and values.

If you rely on environment variables like me, this may be an issue. The
environment that liquidsoap runs in was not passed to any of the `get_process_*`
functions.
[@toots](https://github.com/toots) has [said this will be fixed in the next release]().

If you had any other issues with 1.3.0 let me know in the comments! You should
also file an issue on [liquidsoap's github](https://github.com/savonet/liquidsoap/issues/new).

{% include mailchimp.html %}
