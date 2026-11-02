---
layout: post
title: 'Hello, Firebase!'
tags:
- firebase
- github
- travis-ci
---

![Hello, Firebase!](/assets/2018-04-20-firebase_hosting.png){: width='650'
height='300' itemprop='image' }

Hey, folks! Almost 3 years ago, I blogged about
[moving my blog from Blogger to GitHub](/2015/07/hello-github.html). It's high
time I moved back to Google, right?

Here's [the commit](https://github.com/kevmoo/work.j832.com/commit/141d0d9c61)
that updated my config.

The only other wiring was setting the `FIREBASE_TOKEN` in Travic-CI to the value
returned by running `firebase login:ci`. That's about it.

"push to deploy" still works like a champ. The turn-around is super fast. Oh,
and it's all on HTTPS.

Cool.

I promise I'll post something before 2020!
