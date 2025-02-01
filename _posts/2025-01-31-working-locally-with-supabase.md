---
title: "Working Locally with Supabase"
date: 2025-01-31 21:03:00 -500
categories: [App Development, Backend]
tags: [homelab, supabase, postgres, docker]
published: true
---

I started my journey sort of backwards, where I started with a backend up on [supabase.com](https://supabase.com), and I'm now learning how to use it locally. The point of this post is to document the steps I took to get a local Supabase instance running, and how to do migrations and interact with other instances.

## What is Supabase?

Supabase is an open-source Firebase alternative. It's a service that provides a Postgres database, authentication, and storage. It's a great way to get started with a backend without having to worry about setting up a server, and it's free for hobby projects.

![Supabase Logo](/assets/img/2025-01-31-supabase-logo.png "Supabase Logo")

I couldn't be more impressed with this platform because this solves 100% of the issues you'd have with MOST applications. This gives you a full-on, proper RDBMS like PostgrSQL (which includes Row Level Security (RLS)), a full-on authentication system that has API's for signing up, logging in, forgot password, MFA/2FA, and more. Then, it also has API's (in REST and GraphQL if you want) for interacting with the database. It uses Kong as an internal API gateway too.

> In short, Supabase is a "Backend as a Service" (Baas) platform, which is a complete "backend" for most applications. This includes: database, authentication, storage, and API's for it all. It's a turn-key, purpose-built backend.
{: .prompt-tip }

You can host up to two free instances on [supabase.com](https://supabase.com), but this is a free and opensource tool, so you can host it anywhere. Even better, it's Docker/Docker-Compose based. So, in literally minutes, you can stand up a full instance on your workstation too!

One of the best things though is that the platform is hardened by default, and you almost have to use "database migrations" to make changes to the database. This is a good thing! However, there is some nuance to this, and this post will cover some of this (mostly for my benefit!)

## Installing Supabase Locally on Docker

### STEP 1: Installing Docker in WSL

At the moment I'm primarily using Windows 11 and WSL2 with Ubuntu 24.04. In the Ubuntu instance, I first need to get Docker installed. You can of-course install Docker Desktop on Windows 11, but Docker is "native" in Linux, plus the Node/NPM stuff seems to work far better on the Linux side. I always use this install guide since is works every time and takes care of the details:

> **[Install using the `apt` repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)**

When done, you should be able to verify with `docker --version`.

### STEP 2: Installing NodeJS and NPM

It's very likely you have some king of NodeJS or NPM needs in modern day development, but if you don't have those installed, you can do so with:

```bash
sudo apt install nodejs npm
```

You can verify those with `node --version` and `npm --version`.

### STEP 3: Installing Supabase CLI

Assuming you now have Docker and NodeJS/NPM installed, you can now install the Supabase CLI. This is a tool that helps you interact with your Supabase instance, and it's a requirement for running migrations.

```bash
# Install globally
npm install -g supabase-cli

# Install in your Node project folder
npm install supabase-cli

## NOTE: NOT installing it globally will require you to use `npx supabase` instead of `supabase`
```

You can verify the installation with `supabase --version` or `npx supabase --version`.

### STEP 4: Running a Supabase Locally

Now that you have the CLI installed, you can run a Supabase instance locally. This is done with Docker, and you can use the following command to get it running:

```bash
supabase start
```

Then, it will output something like this:

```text
*supabase local development setup is running.

         API URL: http://127.0.0.1:54321
     GraphQL URL: http://127.0.0.1:54321/graphql/v1
  S3 Storage URL: http://127.0.0.1:54321/storage/v1/s3
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
    Inbucket URL: http://127.0.0.1:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: <anon-key>
service_role key: <service-role-key>
   S3 Access Key: <s3-access-key>
   S3 Secret Key: <s3-secret-key>
       S3 Region: local
We recommend updating regularly for new features and bug fixes: https://supabase.com/docs/guides/cli/getting-started#updating-the-supabase-cli*
```

## Basic Operations

There are really two main things that I find useful:

1. The Supabase `supabase` CLI tool
2. The "Studio" web interface

What I found a bit surprising first is that if you navigate to the studio, there is not authentication. But worse, when went to the "SQL Editor" to run a script, I kept getting;

```text
ERROR: 42501: must be member of role "supabase_admin"
```

This is because the default user is not an admin, and you can't change that. As it turns out, the whole platform is based around the modern idea of "database migrations". That is, you make a set of changes on your local instance, and then you "migrate" those changes to another instance.

### Linking to a Supabase Instance

Assuming you have a Supabase instance on supabase.com or someplace else, you need to "link" to it. The Supabase CLI can only understand being connected to one remote instance at a time, but you can have multiple local instances. To link to a remote instance, you can use the following command:

```bash
# To specify the URL and key:
supabase link --project-ref <your-instance>

# Or to be prompted:
supabase link
```

It will prompt you for your database password. The `<your-instance>` is the URL of your Supabase instance, which you can find in the settings of your instance. For example, if your URL is `https://ncuwgemslxkchvzjrlib.supabase.co` then you would use `ncuwgemslxkchvzjrlib` for your `<your-instance>`. 

The database password was provided to you when you created the instance. If you didn't capture it, you can reset it from Project Settings -> Configuration -> Database, the URL wil be something like this:

> **`https://supabase.com/dashboard/project/<your-instance>/settings/database`**

When you run `supabase link`, this will do a `diff` on the remote instance vs your local instance and show you the output.

### Doing a Dump of the Structure

If you want to see the structure of your remote database, you can do a dump of the structure with the following command:

```bash
npx supabase db dump > ./prod-dump.sql
```

Again, note that you can't just copy this code and run it in your SQL Query of your local instance. You won't have privileges to do most of the things. This is where the migrations come in.

### Sync/Reset Local Instance from Remote

Assuming your have a new, empty Supabase local instance, you can sync it with your remote instance with the following command:

```bash
npx supabase db reset
```

This will completely factory-reset your local instance, and then apply all the migrations from your remote instance. This is a good way to get your local instance in sync with your remote instance.

> DANGER ZONE: This is destructive and will overwrite your local instance.
{: .prompt-danger }

## Running Migrations

The idea of migrations is that you create a set of changes to your database, and then you "migrate" those changes to another instance. This is a good way to keep your database changes in sync across multiple instances. You can store your migration files (just `.sql` files) and store those in your GitHub repo.

### Creating a Migration

This is where some of the real magic of Supabase comes in. You can modify the database how you see fit, and it keeps track of the changes. When you are happy with the state of your database, you can then create a migration file that represents those changes. It's a delta of the changes you made.

> WARNING: Like with any other technology that works with database migrations, these CAN be destructive, where you could lose data. If you are making new tables or adding columns (with a `default`), you'll be fine, but if you are dropping columns or tables, you could lose data. Be careful!
{: .prompt-warning }

To create a migration, you can use the following command:

```bash
npx supabase migration new <name>
```

Where `<name>` is typically something like `create_users_table`. This will create a new migration file in your `migrations` folder. You can then edit this file to add your changes.

### Pulling Migrations from Remote

If you have migrations on your remote instance that you want to pull down, you can use the following command:

```bash
npx supabase db pull
```

Note that in WSL, it won't cache that database password, so you will be prompted every time. So, you can store an envriorment variable with the password in your `.env` file:

```bash
SUPABASE_DB_URL=postgresql://postgres:<db-pass>@<your-instance>.supabase.co:5432/postgres
```

Then, you can use the following command:

```bash
npx supabase db pull -p $SUPABASE_DB_URL
```

This will pull down all the migrations from your remote instance and store them in your `migrations` folder, in a file name like `20250201000659_remote_schema.sql`.

### Pushing Migrations to Remote

If you have migrations on your local instance that you want to push up, you can use the following command:

```bash
npx supabase db push --dry-run -p $SUPABASE_DB_URL
```

With `--dry-run` obviously to show you what it *would* do. If you're happy with that, you can remove `--dry-run` and run it again.

## Next Steps...

This is a very basic overview of how to get started with Supabase locally. There are many more features and capabilities that I haven't covered here, but this should be enough to get you started.

My next thought is how to do this from a CI/CD pipeline. For example, I often use GitHub Actions with an on-prem runner in a container. So presumably, I could run the Supabase CLI in a container and do the migration for each environment from there. When the front-end gets pushed to a new environment, this Supabase folder will have the migrations to apply for each environment. I'll have to experiment with that and see how it goes.