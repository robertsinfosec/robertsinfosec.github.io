---
title: "Vibe-Coding a Caffeine Tracker"
date: 2025-04-17 07:11:00 -500
categories: [App Development, AI Assistants]
tags: [caffeine, tracking, app, development, productivity]
published: true
---

I recently moved and due to some convenience factors, I found myself drinking a lot more caffeine than I had in the past. This seemed to be affecting my sleep.

I was curious how much caffeine I was actually consuming and how long it stayed in my system, so I built a simple app to track it. I wanted to share my experience and the process I went through to build it.

<img src="/assets/img/2025-04-17-vibe-coding-screenshot.png" alt="Vibe Coding screenshot" />

## Quick Tech Overview

First, this app is a [Progresive Web App (PWA)](https://www.pwabuilder.com/),  [Vite React](https://vite.dev/guide/). [Single Page App (SPA)](https://en.wikipedia.org/wiki/Single-page_application) that runs in the browser, and the "backend" is a simple read-only JSON file. That is, for the core drink database.

Then, the users data is stored as JSON in the `LocalStorage` of their browser. This means that the app is very lightweight and doesn't require any server-side code or database. The app is hosted on [GitHub Pages](https://pages.github.com/), a free hosting service for static websites.

<img src="/assets/img/2025-04-17-vibe-coding-stack.png" alt="Vibe Coding Stack" />

I used [VS Code](https://code.visualstudio.com/) and [GitHub Copilot](https://github.com/features/copilot) to [Vibe Code](https://en.wikipedia.org/wiki/Vibe_coding) pretty much all of it. I'll get into this more below, but there is the initial wave of trying to get the app built and constantly telling CoPilot to build it right, and not create Technical Debt, but in the end, I did have a phase that was all about cleaning up the mess.

Another AI element of this is for the Brand. For that, I asked [ChatGPT](https://chatgpt.com/) with it's new, [super-impressive graphics capabilities](https://openai.com/index/introducing-4o-image-generation/) to create a "brand vision board" for the app, and include a color scheme, logo, etc. Below is what it produced - I thought it was pretty good!

<img src="/assets/img/2025-04-17-vibe-coding-brand-vision.png" alt="Brand Vision Board" style="width: 100%; max-width: 400px;"/>

So, I had:

- **Coding**: VS Code + GitHub Copilot (primarily using Anthropic's Claude 3.7)
- **Brand**: ChatGPT for the brand vision board
- **Tech Stack**: Vite React for the app technology stack
- **SCM**: GitHub for version control
- **CI/CD**: GitHub Actions for CI/CD and to deploy to GitHub Pages
- **Hosting**: GitHub Pages for hosting
- **Database**: LocalStorage for user data and JSON for the drink database

With that, I was off to races!

## Setting up Your LLM for Success

In GitHub Copilot, when you ask a question, or start an Agentic Cycle (I'll call it? That is: you give it a prompt and it goes off and codes for a while), it defaults to being pretty simple. Ask it for a function and it will produce that function. However, you may have some standards you want to follow like:

- Platform or language best-practices
- The [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
- [DRY](https://en.wikipedia.org/wiki/SOLID) (Don't Repeat Yourself)
- [KISS](https://en.wikipedia.org/wiki/SOLID) (Keep It Simple, Stupid)
- [YAGNI](https://martinfowler.com/bliki/Yagni.html) (You Aren't Gonna Need It)
- [TDD](https://en.wikipedia.org/wiki/Test-driven_development) (Test Driven Development)
- [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development) (Behavior Driven Development)
- You want "[docstrings](https://en.wikipedia.org/wiki/Docstring)" or "XML Code Comments" or "JSDoc" or whatever the documentation style is for your platform
- Etc., etc.

Well, you can add that to your prompt, and generally that helps. However, due to [Context Window](https://www.geeksforgeeks.org/tokens-and-context-windows-in-llms/) limitations, as time goes on, the LLM will forget what you told it. So, you need to keep reminding it. Unless you are closely watching the code changes it makes, you may not notice or you may not catch it until later.

### Product Requirements Document (PRD)

ChatGPT (or in an [Inception](https://www.imdb.com/title/tt1375666/) sort of way, GitHub CoPilot) can be useful to develop a proper PRD. This is a document that outlines the requirements for the product you are building. Put that Markdown file in your `/docs/` folder in your repo.

### Architecture Document

Also in the `/docs/` folder, consider adding an `ARCHITECTURE.md` file that outlines the architecture of your app. This is a good place to put things like:

- The tech stack you are using
- The architecture of the app (e.g. MVC, MVVM, etc.)
- The database schema (if applicable)
- The API endpoints (if applicable)
- The data flow (if applicable)
- The user flow (if applicable)
- The CI/CD and deployment process (if applicable)

### Style Guide and Contributing Guides

In this particular case, I structured this project as an open source project, here:

- [https://github.com/halflifecaffeine/halflifecaffeine.github.io](https://github.com/halflifecaffeine/halflifecaffeine.github.io)

So, there is a [`CONTRIBUTING.md`](https://github.com/halflifecaffeine/halflifecaffeine.github.io/blob/main/CONTRIBUTING.md), [`STYLE_GUIDE.md`](https://github.com/halflifecaffeine/halflifecaffeine.github.io/blob/main/STYLE_GUIDE.md), and [`CODE_OF_CONDUCT.md`](https://github.com/halflifecaffeine/halflifecaffeine.github.io/blob/main/CODE_OF_CONDUCT.md) file that explains how contributors can contribute to the project, while being in alignment with how the project is set up.

I mention all of this because even with a private repository, you may want to add these, and include them as Context for your LLM. After all, this AI is kind of like a contributor to your repository. So, this tells them to how contribute to the project, and what the standards are.

### Adding `copilot-instructions.md`

Recently, GitHub announced that you can add a `copilot-instructions.md` file to your repository, and it will use that as context for the LLM. This is significant because it seems to include these as part of the `SYSTEM` prompt, so it won't get lost in the context window.

The default location is to add it to `/.github/copilot-instructions.md`, but you can also add it to the root of your repository. You do need to enable this in VS Code. Got into Settings and search for the word "Instructions" and you will see a few options for it.

> See the official [GitHub Copilot documentation](https://code.visualstudio.com/docs/copilot/copilot-customization) for more information.
{: .prompt-tip }

### Summarizing the LLM Helpers

So now, when you ask a question, or kick off a new Agentic Cycle, the LLM is starting from a place where:

- It knows the architecture, tech stack, and requirements of the app
- It knows the coding standards and style guide you want to follow
- It knows the contributing guidelines and how to contribute to the project
- It knows the CI/CD and deployment process
- It knows the context of the app and what it is trying to do
- It knows how to write the code in the way that you want it to be written

This is definitely not perfect, especially the longer you stay in one thread. However, it is a good start and it's better than not-using anything.

## Building the MVP

As far as writing the actual app and building a Minimum Viable Product (MVP), I saw quite a bit of difference between the available LLM models. For Agentic coding, as of this writing, we have these models available:

- Anthropic's Claude 3.5
- Anthropic's Claude 3.7
- OpenAI's GPT-4o
- *OpenAI's GPT-4.1 (Preview)*
- *o4-mini (Preview)*
- *Gemini Pro (Preview)*

Claude 3.5 has always been good, and Claude 3.7 seems to be even better. 

> **"What do you mean, better?", you ask.**
>
> I mean this in several ways:
> 1. It seems to be better at understanding the context of the app and where changes need to be made.
> 2. It seems to be better at understanding the coding standards and style guide you want to follow.
> 3. It seems to truly grasp the concept of what you are trying to do, even complex tasks that have several, complex components.
> 4. It isn't chatty or waste your time outputting a lot of unnecessary code or comments. It gets right to the point.
>
> What is so impressive is that this is like working with a very talented developer who just "gets it". That is, when it's not being a total and complete dummy.
{: .prompt-info }

Does that mean that the other models are bad or worse? No, but noticably different. For example, the OpenAI GPT-4o model is very chatty and verbose. It will often output the entire file into the chat and explain that it changed one line. This is a waste of time for both of us. Worse, this particular model tends to want to explain what YOU need to do, and does not give a complete solution. If you ask it to generate the complete solution, it often does most of it and in the comments will have "Add the rest of your code here". This is not helpful if you want hands-off, Agentic coding.

### Sudden Dumbness

I have noticed that sometimes, the LLM will just go off the rails and start doing something completely different. This is especially true when you are in a long thread and it has lost context.

This is particularly frustrating after an hour or two of really making good progress and it's cranking out fantastic code. Then, all of a sudden, it starts doing something completely different.

This does mean that you need to stay on your toes, save your changes and commit your "Apply"'s often (and even do a `git commit`) so that when this happens (not "if", but "when"), you can easily "Undo" the changes, and start a new thread.

## Cleaning up the Mess

Despite my best efforts, I ended up with a lot of Technical Debt, and I didn't like how much of the app was structured. The LLM still took the easiest path in a lot of cases. For example, by putting ALL of the React components in to the `components` folder, as one flat folder.

Or, instead of creating proper, reusable components, it would just add the code to an existing page, making like a 1,500 line React component/page.

Or, even when we had reusable components, and even if I mentioned it, it would still create a custom component or add the functionality to an existing component - just making a mess.

So, when the principal work was pretty much done, I took about a day to just go through and re-structure what was there.

> **"Don't break any existing functionality"**
>
> One key phrase you can add at any time to your prompt, which never hurts is, "Please don't break any existing functionality". This is significant because:
>  
> 1. I've had a perfectly working app, and the AI went in like a wrecking ball and broke several things. See "Sudden Dumbness", above! And
> 2. It will often acknowledge this and say something like "...and I will be careful not to break any existing functionality." AND it does a good job of not breaking anything!
{: .prompt-tip }

## Adding Polish, Fit and Finish

Finally, I did one more round where I went page-by-page, and gave the LLM a list of the buggy or aesthetic things to clean up. It generally did this fine. However, there are couple of things on this app that made the LLM just meltdown. Specifically, it was about applying the brand colors to the toggle on the Drinks page. It just kept getting confused and would start looping. This happened even after starting a new chat, and also restarting VS Code.

### A GitHub CoPilot Code Review

One thing I recently learned is that you can have GitHub Copilot do a code review for you. This is a good way to get a second set of eyes on your code, and can catch things you missed. Note that you can provide a separate set of instructions for this, like the more generic `copilot-instructions.md` file, which only apply to code reviews. You can do this from the Git screen before you commit your changes:

<img src="/assets/img/2025-04-17-vibe-coding-code-review.png" alt="GitHub CoPilot Code Review" style="width: 100%; max-width: 500px;"/>

## Conclusion

I went from making an Excel spreadsheet of my caffeine intake on Sunday, to having the app completed and deployed by Wednesday night - ~72 hours. So, this app:

> **[https://halflifecaffeine.com](https://halflifecaffeine.com)**

And this GitHub repository:

> **[https://github.com/halflifecaffeine/halflifecaffeine.github.io](https://github.com/halflifecaffeine/halflifecaffeine.github.io)**

which includes a GitHub Action that deploys the app to GitHub Pages, was all completed in ~72 hours. Well, maybe ~30 actual working hours. If I were to do this the "old fashioned" way, this would easily have taken realistically ~2 weeks.

Despite it's few flaws, I can't really justify coding any application without AI assistance. And now, I can't even make the case that professional software developer NOT Vibe Code. Put another way, doing and then fixing Vibe Coding mistakes, is still probably 5x faster than manually coding.

It is things like: just the sheer amount of clock time it takes to write 150 lines of code for a component. If the AI does it 95% correct - you can do that, and fix the 5% FAR faster than if you had to type that code yourself.

With that said, and we've all laughed at the memes, Vibe Coding should really be used by professionals. These AI's will mostly produce working code. That doesn't not mean that it is secure, efficient, or scalable. The amature Vibe Coder won't even know that's a problem, nevermind know how to fix it.

So, I would say that Vibe Coding is a great way to get started, and to get something working. But, the code needs to be reviewed and cleaned up by a professional. This is especially true if you are going to be using this code in a production environment.