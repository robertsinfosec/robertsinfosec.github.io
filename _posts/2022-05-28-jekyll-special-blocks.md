---
title: Jekyll Special Blocks
date: "2022-05-28 23:11:00"
categories: [Blogging, Documentation]
tags: [jekyll, chirpy, documentation, techno-tim]
---

## Overview

If you are using a [Jekyll](https://jekyllrb.com/) website to create your own [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site) website where your site is hosted on `USERNAME.github.io` for free, here's an interesting tip for creating blocks of interest that catch your readers eye.

Specifically, this website for example uses [chirpy-starter](https://github.com/cotes2020/chirpy-starter) which I learned about from [TechnoTim](https://www.youtube.com/watch?v=F8iOU1ci19Q):

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/F8iOU1ci19Q" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## The Blocks

Using these technologies, you can create blocks like this:

> This is an example of a Tip.
{: .prompt-tip }

> This is an example of an Info block.
{: .prompt-info }

> This is an example of a Warning block.
{: .prompt-warning }

> This is an example of a Danger block.
{: .prompt-danger }

With that said, here's how to add each of these in the Markdown of your post page:

```markdown
> This is an example of a Tip.
{: .prompt-tip }

> This is an example of an Info block.
{: .prompt-info }

> This is an example of a Warning block.
{: .prompt-warning }

> This is an example of a Danger block.
{: .prompt-danger }
```