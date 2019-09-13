---
layout: post
title: "solving ember fastboot 'flashing' issues"
tags: [emberjs]
---

So you setup fastboot on your ember app. Now you are rendering your application
on the server, making search engines happy. Things are great. But now you have a
new problem. The app on the server will fetch your data from your API to render, then
on the client side the data is fetched again, even though we already rendered the data
with fastboot. How can our apps be smarter about this and not render the same
data twice, being inefficient and making for bad UX.

## flashing screen

If you work with fastboot you may have seen this issue.
Your app renders, then your loading template flashes, and your app renders one
more time.

![fastboot double render](/assets/images/fastboot_loading_flash.gif)

What is happening is:

1. fastboot serves your rendered HTML
2. ember data makes another, likely redundant request, for the same data,
   flashing the loading template if you have one
3. this request finishes and your app renders a final time

Fastboot provides a solution for this called the ["shoebox"](https://github.com/ember-fastboot/fastboot#the-shoebox). It is basically some
json rendered in the HTML response from fastboot in a script tag.
You can code your app to account for this and use the cache instead of making
a duplicate request on the client.

However managing this all yourself can become complicated. Luckily some addons
have come about to encapsulate common patterns.

### ember-cached-shoe

The [ember-cached-shoe addon](https://github.com/Appchance/ember-cached-shoe) is recommended on the fastboot page, and the first one I tried. It was
certainly easier than working with the shoebox directly, and provides a nice
API. There are still some other issues even if you use this, which the library
below addresses quite well.

### ember-data-storefront

The [ember-data-storefront addon](https://github.com/embermap/ember-data-storefront) is not just a solution for the shoebox, but also claims to solve many other common ember data issues.

Learn more by watching [this talk](https://www.youtube.com/watch?v=X-LjrRx2wMI).

This really blow my mind. I encountered the isuses described in the talk often,
but never thought they could be solved in this way. I hope these patterns get
merged into ember itself eventually, since they seem to be so common.

All you have to do to use it with fastboot is [add the mixin to your application
adapter](https://embermap.github.io/ember-data-storefront/docs/guides/fastboot<Paste>):
```javascript
// app/adpaters/application.js

import JSONAPIAdapter from 'ember-data/adapters/json-api';
import FastbootAdapter from 'ember-data-storefront/mixins/fastboot-adapter';

export default JSONAPIAdapter.extend(
  FastbootAdapter, {

  // ...

});
```

### Rehydration

[Rehydration](https://github.com/ember-fastboot/ember-cli-fastboot#rehydration) is an experimental feature that may render the above methods for dealing with the shoebox obselete. I haven't tried to yet, but follow the above link if you are interested in trying it out.
