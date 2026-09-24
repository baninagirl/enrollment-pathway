# Kumon Hub — standalone setup

> This file predates the login system and the Kumon Hub expansion (roles, and more pages
> to come). The steps below (1–3) are still accurate for the original one-page app —
> see **"Kumon Hub — Phase 1: roles"** further down for what's new.

This is the same app, rebuilt to run outside Claude on your own Supabase project + Vercel,
instead of Claude's built-in storage. Three steps: set up the database, fill in two values,
deploy the folder.

## 1. Set up Supabase (5 min)

1. Go to supabase.com → your project (or create a new one — free tier is plenty for this).
2. Open **SQL Editor** → **New query**, paste in the contents of `schema.sql` from this folder,
   and run it. This creates the 5 tables the app needs (students, diagnostics, trainings,
   schedules, settings) and turns on Realtime so everyone's screen updates live.
3. Go to **Project Settings → API**. You need two values from this page:
   - **Project URL** (looks like `https://xxxxx.supabase.co`)
   - **anon public** key (a long string under "Project API keys")

## 2. Fill in your keys

Open `index.html` in a text editor, find this near the top of the `<script>` block:

```js
const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
```

Replace both placeholder strings with the values from step 1.3, keeping the quotes. Save.

## 3. Deploy to Vercel

1. Go to [vercel.com/new](https://vercel.com/new).
2. Drag this whole folder (or just `index.html`) onto the page, or use "Upload" if you don't
   see a drop zone.
3. Click Deploy. No build settings needed — it's a static file.

You'll get a URL like `your-project.vercel.app`. Share that with your team — that's the app,
live, shared, saving to your Supabase project.

## Updating it later

If you (or Claude) change `index.html` again, just drag the folder onto vercel.com/new again,
or drag it onto your existing project's page — Vercel will redeploy the same URL.

## Good to know

- **No login screen**, same as the Claude version. Anyone with the app's URL can read and
  write everything — the Supabase anon key isn't a secret, it's expected to be visible in the
  page. `schema.sql` sets up policies that keep it open on purpose, matching how it worked in
  Claude. If you want real access control (a login, or view-only for some people), that's a
  bigger change — ask Claude when you're ready for it.
- **Realtime**: multiple people editing at once will see each other's changes within a second
  or two, same as before.
- **Nothing else changed** — same calendar, enrollment tracker, roster, students tab, settings.
  Only how it stores data changed.

## Kumon Hub — Phase 1: roles

The app is growing into a few pages under one "Kumon Hub" umbrella — `index.html` (the
Pipeline, unchanged) is now the first of several. `admin.html` is the second: it manages who
has access and what they can do. Two roles: **admin** (day-to-day access, the default for
everyone) and **superadmin** (everything admin can do, plus managing other people's accounts —
more admin-only actions will land here as later pages are added, e.g. approving payments).

Setup, one time only:

1. In Supabase's SQL Editor, run `phase1-roles.sql` from this folder. It adds the table that
   tracks roles and quietly backfills one for every login you already have (everyone starts
   as "admin").
2. Still in the SQL Editor, run one more line — with your own login's email — to make
   yourself the first superadmin (the file has this at the very bottom too):

   ```sql
   update profiles set role = 'superadmin' where email = 'you@example.com';
   ```
3. Deploy `admin.html` alongside `index.html` the same way you deploy everything else (same
   GitHub Desktop → commit → push, Vercel picks it up automatically). It'll be reachable at
   `your-project.vercel.app/admin.html`, and an "Admin" link will appear in the Pipeline's
   nav rail for superadmins automatically — everyone else just won't see that link.

Adding a new team member from here on: create their login the same way as before (Supabase →
Authentication → Users → Add User, Auto Confirm checked). They'll show up on the Admin page
automatically as "admin" — go there to make them superadmin if they should be.
