# Enrollment Pathway — standalone setup

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
