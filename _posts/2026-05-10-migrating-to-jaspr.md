---
title: "Migrating to Jaspr"
date: 2026-05-10 18:42:32 -07:00
permalink: /2026/05/migrating-to-jaspr.html
tags:
  - general
---

Hey folks! It’s high time I modernize this blog. Almost 8 years ago, I [moved
this blog to Firebase Hosting](https://work.j832.com/2018/04/hello_firebase.html)
using a Jekyll static pipeline.

Today, I took the ultimate leap: **I migrated the entire blog to Dart and
Jaspr!**

Here is the complete migration commit:
[c79f474367](https://github.com/kevmoo/work.j832.com/commit/c79f4743677ba7cb86b6b7f77efa59aa203d0f96).

---

### 🛠️ The New Shiny Tech Stack

By moving away from Ruby and Jekyll, I’ve unified the blog entirely under the
Dart ecosystem. Here are the core packages driving the new static blog under the
hood:

*   **[Jaspr](https://pub.dev/packages/jaspr) &
    [Jaspr Router](https://pub.dev/packages/jaspr_router):** Serves as the core
    component and declarative routing engine, generating lightweight, static
    HTML page crawls at compile-time.
*   **[package:markdown](https://pub.dev/packages/markdown):** Reading from the
    old `_posts/` into HTML at build time.
    I need to figure out if there is a new, better way to do this.
    At the moment I had to make zero changes to the posts, so that's a win.
*   **[package:yaml](https://pub.dev/packages/yaml):** Parses the legacy Jekyll
    Frontmatter headers (titles, dates, tags, permalinks) to populate our static
    `content.dart` database.
*   **[package:xml](https://pub.dev/packages/xml):** Generate the sitemap and
    the Atom. Wow. So weird to touch XML again.
*   **Tailwind CSS v4:** Provides all utility-first CSS stylings compiled
    natively via the npm CLI.


I don't like having to work around
[jaspr_tailwind issue #11](https://github.com/ShubhamVG/jaspr_tailwind/issues/11).
I'll need to investigate if there is a way to wire all of this up without a
custom build script calling out to `npx`.

In the mean time, at least I have a place to put my "think pieces".

"thought pieces"?

🤷‍♂️

Happy hacking!
