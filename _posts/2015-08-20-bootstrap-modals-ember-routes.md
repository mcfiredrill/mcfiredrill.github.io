---
layout: post
title: "Turning bootstrap modals into Ember routes (with URLs)"
tags: [ember, bootstrap]
---

I am in the process of adding ember to the [datafruits.fm](http://datafruits.fm/) frontend site. All of the links at the top are bootstrap modals, and I’d like to be able to send links to these pages to people, so using ember with routes seemed like a good solution.

I wanted the route to change when opening the modal, and the router to return to the root path when closing the modal.

At the time of this writing, Ember provides a lot of route hooks, so I found it pretty easy to implement this. I just had to add modal show and modal hide to the appropriate hooks.

There seem to be two hooks you can use before the route exits.
{% highlight javascript %}
willTransition
didTransition
{% endhighlight %}

The willTransition hook is quite handy. We can use it to hide the modal after the route has transitioned.

`didTransition` didn’t quite work, because the DOM hasn’t rendered yet. I found
that I could schedule the modal to be shown in the `setupController` function.
There are a couple other ways to accomplish this, such as the `afterModel` hook
in the route. You can read about some more solutions on this stackoverflow post:

[http://stackoverflow.com/questions/17437016/ember-transition-rendering-complete-event](http://stackoverflow.com/questions/17437016/ember-transition-rendering-complete-event)

You might notice another problem, if you exit the modal by clicking outside of
the modal box, the route won’t change, even though the modal is hidden. This will require another hook of sorts.

You can use the bootstrap modal's callback `'hidden.bs.modal'` and call the
route's `transitionTo` function to transition back to the main route.

I ended up with something like this:

{% highlight javascript %}
import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    willTransition: function(transition) {
      Ember.$("#podcastsModal").modal('hide');
    }
  },

  setupController: function(controller, model){
    this._super(controller, model);
    Ember.run.schedule('afterRender', this, function () {
      Ember.$("#podcastsModal").modal('show');
      var _this = this;
      Ember.$("#podcastsModal").on('hidden.bs.modal', function () {
        console.log("modal exited");
        _this.transitionTo('application');
      });
    });
  }
});
{% endhighlight %}


The markup for the modal itself is in the route's template.

{% highlight javascript %}
<div class="modal fade" id="podcastsModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        {{#link-to 'application'}}<button type="button" class="close" aria-label="Close"><span aria-hidden="true">&times;</span></button>{{/link-to}}
        <h4 class="modal-title" id="myModalLabel">PODCASTS</h4>
      </div>
      <div class="modal-body">
        <p>
          <div id="calendar">
          </div>
        </p>
      </div>
      <div class="modal-footer">
      </div>
    </div>
  </div>
</div>
{% endhighlight %}

I changed the exit button to go to the main route:

{% highlight javascript %}
{{#link-to 'application'}}<button type="button" class="close" aria-label="Close"><span aria-hidden="true">&times;</span></button>{{/link-to}}
{% endhighlight %}
