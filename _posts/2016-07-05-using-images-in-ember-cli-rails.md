---
layout: post
title: "using image assets in ember-cli-rails"
tags: [ember, rails, assets]
---

How do you use images from ember’s pipeline in rails?
How do you use images from the asset pipeline in ember templates?

Even after reading this [giant issue
thread](https://github.com/thoughtbot/ember-cli-rails/issues/30), I was still a bit unsure of how exactly to use an asset image in my ember template.

In my case I just wanted to use a single image in a .hbs template, so I had no access to rails asset helpers.

If you are using another solution such as
[ember-islands](https://github.com/mitchlloyd/ember-islands) you may be able to simply use rails asset helpers.

I found a solution to use the prepend option in ember-cli-build. I prepended what I knew the output destination of the ember-cli-build to be.

ember-cli-build.js:
{% highlight javascript %}
module.exports = function(defaults) {
  var app = new EmberApp(defaults, {
    fingerprint: {
      prepend: '/assets/ember-cli/apps/frontend/'
    }
  });
  return app.toTree();
};
{% endhighlight %}

Since I was using the ember_asset_tags helpers with a prepend option already, this was breaking there.

So I changed it to use the prepend option only if we are not in production (fingerprinting in ember cli only happens in rails production environment).

{% highlight erb %}
<!-- Your Ember app will be rendered here. -->
<div id="ember-application"></div>
<% if Rails.env.production? %>
  <%= include_ember_script_tags :frontend %>
  <%= include_ember_stylesheet_tags :frontend %>
<% else %>
  <% prepend = asset_url("/assets/ember-cli/apps/frontend/") %>
  <%= include_ember_script_tags :frontend, prepend: prepend %>
  <%= include_ember_stylesheet_tags :frontend, prepend: prepend %>
<% end %>
{% endhighlight %}

The ember-cli-rails team claims that they don't plan to support this method of
serving your ember app forever though. I wonder if I can accomplish the same
using the supported `mount_ember_app` and `render_ember_app` helpers.

I'm writing a book about how to add ember to your rails app. I cover the
different approaches and save you tons of time scouring blog posts and forums
for info. Check it out [here](/emberyourrails).

{% include ember_mailchimp.html %}
