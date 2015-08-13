---
layout: post
title: "liquidsoap scheduling"
tags: [liquidsoap]
---

![weird al has plans :3](/assets/images/uhf_schedule.png)

As a radio station owner I'm sure you have plans for some elaborate station programming. Liquidsoap comes with some great built in tools for scheduling when certain sources should play

For example, here is how you would schedule a different playlist for different times during the week, using the [switch](http://liquidsoap.fm/doc-svn/reference.html#switch) command

{% highlight ruby %}

weeknights = playlist(“./weeknights”, mode="random")

source = fallback(track_sensitive=false, [live,
        switch([
            ({ (2w or 3w or 4w or 5w) and 0h-6h}, weeknights),
            ({ (5w) and 6h-13h}, fridaymorning),
            ({ (5w) and 13h-20h}, fridayafternoon),
            ({ (5w) and 20h-23h59}, fridaynight),
            ({ (6w) and 0h-6h}, fridaynight),
            ({ (6w) and 6h-13h}, saturdaymorning),
            ({ (6w) and 13h-20h}, saturdayafternoon),
            ({ (6w) and 20h-23h59}, saturdaynight),
            ({ (7w) and 0h-6h}, saturdaynight),
            ({ (7w) and 6h-13h}, sundaymorning),
            ({ (7w) and 13h-20h}, sundayafternoon),
            ({ (7w) and 20h-23h59}, sundaynight),
            ({ (1w) and 0h-6h}, sundaynight),
            ])
])

{% endhighlight %}

The syntax for times should be simple enough to understand. The days of the week are numbered `1w` - `7w`, starting with Sunday. You can use XhXX for hours and minutes. Then just use any source as the second argument. Here I’m using playlist sources.

As usual personally I'm using a combination of ruby and redis to implement a
more custom solution. I will perhaps share the details of this in a further
post.

{% include mailchimp.html %}
