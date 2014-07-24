---
layout: post
title: "growing rails applications review"
description: ""
category:
tags: [rails]
---

I just finished reading 'Growing Rails Applications'. At 88 pages its a fairly quick read. Its yet another discourse on the problem of keeping your app under control as it evitably grows to an enormous size. It goes over a few things that I've read about plenty of times before such as extracting service objects, using testing effectively, but I thought the most unique part of this book was its 'anti silverbullet' philosophy. I often used to think that if I could just employ the right architectural pattern or testing approach to my apps, all my problems with my giant unmaintainable apps would be solved. As I work with more and more projects and companies, I've yet to come across any app that resembles anything like the ivory tower perfectly factored app that I hear about from blogs and presentations. There really is no silver bullet, every approach has tradeoffs. A complex app will always be complex.

That said it has some great advice on refactoring models. One problem with extracting service objects is that your code tends to get a bit scattered all over the place, through service objects in app/services or perhaps concerns in app/concerns or maybe even shoving some stuff in /lib. I like their approach of making a directory with the model name in app/models and sticking related classes in that directory. This separates the code cleanly while still making it easy to find related classes. There is also a chapter on organizing your CSS, a subject I haven’t given much thought to. It is true, most of the CSS code I’ve seen on rails projects is anything but organized, and the problem compounds itself quickly.

I hope more people will come to realize that approaches to organizing a big rails pile of mud are all about tradeoffs. Once we do, we can start to discuss which tradeoffs are the best of the bunch of which situations.
