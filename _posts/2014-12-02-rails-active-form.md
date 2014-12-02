---
layout: post
title: "rails activeform - put accepts_nested_attributes_for in its place"
tags: [rails]
---

I don't know about you, but the amount of successes I had with
`accepts_nested_attributes_for` were few and far between. It always felt like a
clunky API. If you've ever worked on a large rails project you also know the
benefits of giving a form its own proper class, instead of interspersing logic
between the view, controller, and model.

I started rolling my own form objects using ActiveModel. While that is pretty
nice, you have to remember how to make one each time, and there are lots of
ActiveModel conventions you need to follow.

I recently discovered [active_form](https://github.com/rails/activeform), which appears to be a gsoc project to tackle
this problem. Its the nicest abstraction around forms that *I* have found to
date.

You can create a new file under `app/forms` for your form. Say we want to create
a 'user' model and a 'subscription' model on sign up, for stripe for example.

{% highlight ruby %}
class SignupForm < ActiveForm::Base
  self.main_model = :user
  attributes :email, :password
  validates :email, :password, presence: true

  association :subscription do
    attributes :plan_id, :stripe_card_token, required: true
  end
end
{% endhighlight %}

Then in the controller you initialize a new instance of the form class passing
an instance of the main model for it to work on, and then call
the `#submit` and `#save` methods on it.

{% highlight ruby %}
user = User.new
@signup_form = SignupForm.new(User.new)
@signup_form.submit user_params
@signup_form.save
{% endhighlight %}

The associations will be saved automatically. If there are any validation errors
on the main model of the associations they will be added to the form class.

Not only is this easier than rolling your own form class or using
`accepts_nested_attributes_for`, I think this library can also encourage better
modular design. You can create specific form classes for specific screens,
instead of spreading logic all over your model just because you have one
instance where you need to save two or more models with one form.

I'm not sure if this is slated for rails 5 at this point? The github repo is
currently under the rails organization on
[github](https://github.com/rails/activeform).
