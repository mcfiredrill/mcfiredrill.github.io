---
layout: post
title: "deploy your ember app to s3 with ember-cli-deploy"
tags: [ember, s3, deployment]
---

I recently converted the [datafruits](datafruits.fm) front end app to ember.js. Before I was using yeoman and gulp.
I’m really liking ember-cli, I like how it feels like rails. Also [ember-cli-deploy](https://github.com/ember-cli/ember-cli-deploy) has popped up as a deployment solution.

## Configure your ember app for deployment

First you will need to install the appropriate addons.
{% highlight bash %}
$ ember install ember-cli-deploy
$ ember install ember-cli-deploy-build
$ ember install ember-cli-deploy-s3
{% endhighlight %}

Open up your config/deploy.js and add this, after the declaration of the `ENV`
variable:
{% highlight javascript %}
ENV.s3 = {
  accessKeyId: process.env.S3_KEY,
  secretAccessKey: process.env.S3_SECRET,
  bucket: "zomgif",
  region: "us-east-1",
  filePattern: *
}
{% endhighlight %}

Obviously replace the bucket and region with your own.
The s3 credentials should not be kept in the source code, so store them in
environment variables.

## Prepare the S3 Bucket

You are going to have to create the bucket before you can deploy.

Go to the S3 console and create a bucket like normal.

Enable static website hosting for the bucket.
Set the index document to index.html.

Set permissions with this policy. This will make all the items in the bucket
public. Replace `zomgif` with the name of your bucket.

{% highlight javascript %}
{
  "Version": "2012-10-17",
  "Id": "Policy1465719768388",
  "Statement": [
    {
      "Sid": "Stmt1465719765890",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::zomgif/*"
    }
  ]
}
{% endhighlight %}


Enable Static Website Hosting on the bucket. Set the Index Document to
index.html. Set the Error Document to index.html as well.

## Then deploy!

{% highlight bash %}
$ ember deploy production
{% endhighlight %}

{% include general_mailchimp.html %}
