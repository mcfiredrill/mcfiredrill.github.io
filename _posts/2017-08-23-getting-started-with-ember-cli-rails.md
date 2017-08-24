---
layout: post
title: "Getting started with ember-cli-rails tutorial"
tags: [ember, rails, ruby]
---

![ember and ruby can be friends](/assets/images/ember_ruby.png)

Here is how to get started with adding ember-cli-rails to your rails app.

We are going to assuming you have a rails app like this one.
It's just a base rails app with one model, Post, that has title and body fields.

## install ember-cli-rails and ams

Add these lines to your Gemfile and run bundle install.

{% highlight ruby %}
gem 'ember-cli-rails'
gem 'active_model_serializers'
{% endhighlight %}

First generate new ember app inside of the directory your rails application
lives in. We're going to call ours "frontend"

{% highlight bash %}
$ ember new frontend --skip-git
{% endhighlight %}

Next we need to run this command:

{% highlight bash %}
$ rails generate ember:init
{% endhighlight %}

This will create the initializer file for ember-cli-rails

{% highlight ruby %}
# config/initializers/ember.rb

EmberCli.configure do |c|
  c.app :frontend
  end
{%  endhighlight %}

{% highlight ruby %}
# config/routes.rb

Rails.application.routes.draw do
  mount_ember_app :frontend, to: "/"
  end

{%  endhighlight %}

Visit  "/" and now ember is rendering!

## Setting up the ember routes

Create the `posts` route in the ember app.

{% highlight bash %}
 ~/src/ember_rails_test/frontend(master)$ ember g route posts
installing route
  create app/routes/posts.js
  create app/templates/posts.hbs
updating router
  add route posts
installing route-test
  create tests/unit/routes/posts-test.js
{% endhighlight %}

I made the path for the posts route "/", just for convience.

{% highlight javascript %}
import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('posts', {path: '/'});
});
export default Router;

{% endhighlight %}

Add the model hook to the post route to hit the rails app for the json data.

{% highlight javascript %}
import Ember from 'ember';

export default Ember.Route.extend({
  model(){
    return this.get('store').findAll('post');
  }
});
{% endhighlight %}

# JSONAPI

By default ember uses and expects the server to return json formatted according
to the JSONAPI spec.

## kabab case
JSONAPI uses kabab-case instead of snake_case. Rails doesn't expect json to be
formatted this way, so we can use the (active-model-adapter)[https://github.com/ember-data/active-model-adapter] ember addon to transform our json payloads.

Install the addon.
{% highlight bash %}
$ ember install active-model-adapter
{% endhighlight %}

Create this adapter.
{% highlight javascript %}
// app/adapters/application.js
import ActiveModelAdapter from 'active-model-adapter';

export default ActiveModelAdapter.extend();
{% endhighlight %}

# load posts

Make the index action for the PostsController in rails look like this:
{% highlight ruby %}
  def index
    @posts = Post.all
    render json: @posts
  end
{% endhighlight %}

Visit localhost:3000, you won't see anything on the page but if you use the
Ember Inspector you can see that the data has loaded.

![ember inspector data
screenshot](/assets/images/ember_inspector_data_screenshot.png)

You can fill out the posts.hbs template to view the data.
{% highlight html %}
{{#each model as |post|}}
  <h1>{{post.title}}</h1>
  <p>
    {{post.body}}
  </p>
{{/each}}
{% endhighlight %}

# create form

Lets create a form to save the posts now.

We can create a component to keep the form actions in.

{% highlight bash  %}
☯tony@okirakugokiraku☯ ~/src/ember_rails_test/frontend(master)$ ember g component post-form
installing component
  create app/components/post-form.js
  create app/templates/components/post-form.hbs
installing component-test
{% endhighlight %}

Add `{{post-form}}` to the posts.hbs template to render it.

app/templates/post.hbs
{% highlight html %}
{{post-form}}

here are the posts
{{#each model as |post|}}
  <h1>{{post.title}}</h1>
  <p>
    {{post.body}}
  </p>
{{/each}}
{% endhighlight %}

We haven't added anything to the post-form template let, so let's add that.

app/templates/components/post-form.hbs
{% highlight html %}
{{input value=title}}
<br/>
{{textarea value=body}}
<br/>
<button {{action 'save'}}>Save</button>
{% endhighlight %}

Write the save action in the post-form component and that method will be  called
whenever the user clicks the Save button. We inject the store as a service to
access ember data's store.

{% highlight javascript %}
import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  actions: {
    save(){
      let post = this.get('store').createRecord('post', {
        title: this.get('title'),
        body: this.get('body')
      });
      post.save();
    }
  }
});
{% endhighlight %}

Calling `post.save()` is when our rails app will be hit with a POST with the payload.

Right now the payload looks like this.

{% highlight json %}
{"data":{"attributes":{"title":"asdf","body":"adsf","penis":"asdf"},"type":"posts"}}
{% endhighlight %}

If you've worked with rails before you know that rails controllers expect
something that looks more like this:

{% highlight json %}
{"post":{"body":"asdf", "title":"asdf"}}
{% endhighlight %}

First of all, rails does not understand the `application/vnd.api+json` mime type
out of the box. If you try to debug the controller and inspect the parameters
you'll just see an empty hash. Wo we should add this code to
`config/initializers/mime_types.rb`:
{% highlight ruby %}
api_mime_type = %W(
  application/vnd.api+json
  text/x-json
  application/json
)

Mime::Type.unregister :json
Mime::Type.register 'application/json', :json, api_mime_type
{% endhighlight %}

We can change our `post_params` method in our posts controller to parse the
JSONAPI formatted parameters correctly.

{% highlight ruby %}
    def post_params
      ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:title, :body])
    end
{% endhighlight %}

The `only` option for `jsonapi_parse` works similar to the whitelist in rails'
strong parameters.

Now the form should be working correctly.

## Troubleshooting

### Build failing with warnings

Ember cli rails seems to treats warnings as errors sometimes, halting the
process and your app won't be served. You can try to fix the warnings to make
the build finish properly.

### Build completes successfully, but rails server is hanging

Check if the file frontend/tmp/build.lock exists. It might be leftover from a
previous build and was not deleted for whatever reason, so you might try
deleting it to see if that brings the app back to life.

{% include ember_mailchimp.html %}
