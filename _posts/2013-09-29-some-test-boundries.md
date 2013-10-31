---
layout: post
title: yet another blog post about dependency injection
tags: [refactoring, testing, ruby]
---

I recently tried to apply ideas about testing at the correct boundaries to
testing a decorator.

{% highlight ruby %}
class Foo < ActiveRecord::Base
  def get_row(headers)
    row = []
    headers.each do |header|
      cell_decorator = CellDecorator.decorate self
      row << cell_decorator.to_cell(header) 
    end
    row
  end
end
{% endhighlight %}

{% highlight ruby %}
describe Foo do
  it "generates the row correctly" do
    headers = [:first_header, :second_header]
    row = foo.get_row(headers)
    expect(row).to == ["data","more_data"]
  end
end
{% endhighlight %}

If you test the return value of get_row, you are effectively doing an
integration test. Testing outgoing messages for state is no good, you are 
effectively testing the behaviour of another class if you are doing so. 
CellDecorator should be the one responsible for testing this. You are also 
increasing your test maintenance costs, you will have to change both tests 
(Foo and CellDecorator) if the interfaces change.

A good way to handle this is inject the decorator as a dependency. This makes it
easy to just use a double and assert that the decorator recieved the message in the test. Then you can
worry about testing that the decorator generated the string properly in the
decorator test, where it belongs.

Although it seems like this is adding production code to make the tests easier to write, I
think decoupling like this is always good. Its not that much code to add either.
The default argument makes it even less of a big deal.

{% highlight ruby %}
class Foo < ActiveRecord::Base
  def get_row(headers,decorator=CellDecorator.new(self))
    row = []
    headers.each do |header|
      row << decorator.to_cell(header)
    end
    row
  end
end
{% endhighlight %}

{% highlight ruby %}
describe Foo do
  let(:decorator){ double }
  let(:foo){ create :foo }
  it "generates the row correctly" do
    headers = [:first_header, :second_header]
    headers.each do |h|
      expect(decorator).to receive(:to_cell).with(h)
    end
    row = foo.get_row(headers,decorator)
  end
end
{% endhighlight %}

{% highlight ruby %}
describe CellDecorator do
  it "decorates the cell" do
    foo = double
    foo.stub(:first_header){ "data" }
    foo.stub(:second_header){ "more_data" }
    headers = [:first_header, :second_header]
    expect(CellDecorator.new(headers)).to == ["data", "more_data"]
  end
end
{% endhighlight %}
