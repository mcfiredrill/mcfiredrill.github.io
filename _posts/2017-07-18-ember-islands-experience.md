---
layout: post
title: "my experience using ember islands"
tags: [emberjs, rails]
---

I’ve always found the prospect of adding ember to an existing rails app daunting. The only way seemed to be all ember or nothing for a long time. Recently I found a project called ember-islands that seems to provide a path for integrating ember a little bit at a time, via components. Combine this with ember-cli-rails and I find that the story for adding ember to your rails app is much happier than when I first tried ember several years ago. There is a path besides 'all or nothing' that exists and I'm going to share my experience with it here.

## Use ember islands

There are basically two different ways you can use ember islands.

1. Components with server rendered json, passed to component’s data-attrs.
   Configure ember's router to ignore the URL, and use the {{ember-island}}
   component to render on any server rendered page. Ember effectively ignores
   the URL with this approach.
2. Specify which element on the page you want the ember app to render inside of,
   and tell ember-islands which URLs to render on.

This lets you mix rails server side rendering and inject ember rendered
components inside of those templates quite effectively.

## Render on any page

With this approach ember will render components inside any element that has the
`data-component` attribute, on any server rendered page.
{% highlight html %}
<div
  data-component='user-profile'
  data-attrs='{"name": "Sally User", "id": "4"}'>

  <p>Sally likes hiking in the wilderness</p>

</div>
{% endhighlight %}

`data-component` specifies which ember component will render in this element.
`data-attrs` will become the attrs passed to the ember component, so you may
want to render it with a serializer on the server side like this.
{% highlight html %}
<div
  data-component='user-profile'
  data-attrs='<%= @user.to_json %>'>

  <p>Sally likes hiking in the wilderness</p>

</div>
{% endhighlight %}

You set ember's locationType to `none`.
{% highlight javascript %}
// in /config/environment.js

module.exports = function(environment) {
  var ENV = {
    // ... other config

    locationType: 'none',

    // ... more config
  }
}
{% endhighlight %}

Then this template will render on any server rendered page.
{% highlight html %}
{% raw %}
{{! inside of app/templates/application.hbs}}

{{ember-islands}}
{% endraw %}
{% endhighlight %}

## Render on specific URLs

If we set ember's locationType to 'auto', ember will render whenever there is a
matching template.

It's also useful to control where the ember app will render. You can specify
`rootElement` in config/environment.js to control this.

## Move on from ember-islands

Once you understand the locationType and rootElement options you should be able
to mix and match them to suit your needs.

You may find you can do everything you need inside the ember template, you
effectively no longer need to use the {{ember-islands}} component at all.

{% highlight html %}
{% raw %}
{{! inside of app/templates/invoices.hbs}}
<h1>All The Invoices</h1>
{{invoice-list invoices=model}}
{% endhighlight %}

You'll have to specify the path in ember's router.js.
{% highlight javascript %}
Router.map(function() {
  this.route('dashboard');
  this.route('invoices');
});
{% endraw %}
{% endhighlight %}

## Which dongle is the right one

The first thing you will run into is the flux going on with the different ember data adapters/serializers. Ember is moving towards using JSONAPI.

Active Model Serializers is also changing and moving towards adopting JSONAPI.

For now I’m going with active model adapter. This may change in Rails 5 and the new release of active model serializers.
https://github.com/ember-data/active-model-adapter

Then I just created an application adapter and I seem to be good to go
{% highlight javascript %}
import ActiveModelSerializer from 'active-model-adapter';

export default ActiveModelSerializer.extend();
{% endhighlight %}

The ember community slack was really helpful in helping me figure things out.

Now you can start rendering components, passing your server rendered JSON to the components.

Add ember to this page with these tags:

{% highlight erb %}
<%= include_ember_script_tags :frontend %>
<%= include_ember_stylesheet_tags :frontend %>
{% endhighlight %}

Note: this approach seems to be discouraged at the moment.
I'm not exactly sure why. I thought the ember team was in favor of these
approaches.

Finally having ember in my app feels amazing. Look at all that jQuery I didn’t have to write?
Its like a weight is lifted off my shoulders, and I feel even more excited to work on my app than before.

Turns out there are also benefits to a hybrid server rendered/SPA. If you need some SEO, you can render content in `<noscript>` tags server side for google and friends, is one approach. I'm currrently using [fastboot](https://ember-fastboot.com/) for the datafruits frontend app, and will write about this in a future article.

## Deployment

[Paul McMahon](tokyodev.com) left a really nice detailed issue about how he is currently deploying his ember/rails project using ember-cli-rails. I'm using a similar approach right now.
https://github.com/thoughtbot/ember-cli-rails/issues/427

This is a decent hack for now, but the community seems to be moving towards ember-cli-deploy based deployments. Perhaps some kind of integration for capistrano will emerge.

I'm writing a book about how to add ember to your rails app. I cover the
different approaches and save you tons of time scouring blog posts and forums
for info. Check it out [here](/emberyourrails).

{% include ember_mailchimp.html %}
