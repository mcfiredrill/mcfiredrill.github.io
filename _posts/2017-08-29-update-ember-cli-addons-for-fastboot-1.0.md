---
layout: post
title: "updating ember cli addons for fastboot 1.0"
tags: [emberjs, ember-cli]
---

There are some incompatible changes in Fastboot's 1.0 release.

Pre 1.0 you may have checked the environment variable to check if your app was
running in fastboot, and disable importing some libraries if so. This will no
longer work in Fastboot 1.0. [@kratiahuja](https://github.com/kratiahuja) has written up a great [upgrade guide](https://gist.github.com/kratiahuja/d22de0fb1660cf0ef58f07a6bcbf1a1c)
for addons that used the old API.
[https://gist.github.com/kratiahuja/d22de0fb1660cf0ef58f07a6bcbf1a1c](https://gist.github.com/kratiahuja/d22de0fb1660cf0ef58f07a6bcbf1a1c)

Basically you can use this check instead of checking the environment variable.

{% highlight javascript %}
if typeof Fastboot === 'undefined'
{% endhighlight %}

Personally I found the [fastboot-transform
library](https://github.com/kratiahuja/fastboot-transform) (also created by [@kratiahuja](https://github.com/kratiahuja/fastboot-transform))
to be more convenient. You simply pipe files to the `fastbootTransform` function
and if fastboot is running they will be replaced with an empty string instead of
the javascript.

For example here is the index.js file from the ember-fullcalendar addon, to
exclude the vendored js files from being included in the fastboot build.

{% highlight javascript %}
/* eslint-env node */
'use strict';
const fastbootTransform = require('fastboot-transform');

module.exports = {
  name: 'ember-fullcalendar',

  // isDevelopingAddon: function() {
  //   return true;
  // },

  options: {
    nodeAssets: {
      'fullcalendar': {
        import: {
          include: ['dist/fullcalendar.js', 'dist/fullcalendar.css'],
          processTree(input) {
            return fastbootTransform(input);
          }
        }
      }
{% endhighlight %}

If you are having trouble figuring out exactly how to upgrade your addon, there
is an issue that has compiled all the addons that need to be upgraded to work
with fastboot 1.0, and there are links to the PRs with the changes needed to
upgrade. These can be great for example code.

[https://github.com/ember-fastboot/ember-cli-fastboot/issues/387](https://github.com/ember-fastboot/ember-cli-fastboot/issues/387)

I have issued a few pull requests myself to some of the addons I am using.

## what about ember-cli-build.js ?

The `Fastboot` variable is not available in ember-cli-build.js.

I don't really want to create ember-cli addons for everything I need to protect
fastboot from trying to run, so for now the best solution is to create an
in-repo addon.

@kratiahuja has another great example we can use for this.
[https://github.com/kratiahuja/sample-in-repo-fastboot/commit/8874fe35575ddfa8d3f63dd9b3b7e65aa2b7dc68](https://github.com/kratiahuja/sample-in-repo-fastboot/commit/8874fe35575ddfa8d3f63dd9b3b7e65aa2b7dc68)

Feel free to check out my own ember app [datafruits](https://github.com/datafruits/datafruits/pull/84) to
see how I personally handled the upgrade.

## ember-network deprecated in favor of ember-fetch

Another issue I ran into, you are supposed to use ember-fetch instead of
ember-network now. This wasn't too hard to fix.

Instead of
{% highlight javascript %}
import fetch from 'ember-network/fetch';
{% endhighlight %}

you can use:
{% highlight javascript %}
import fetch from 'fetch';
{% endhighlight %}

And you can remove `ember-network` from your package.json.

By the way shoutout to [@kratiahuja](https://github.com/kratiahuja) for all her hard work on this!

{% include ember_mailchimp.html %}
