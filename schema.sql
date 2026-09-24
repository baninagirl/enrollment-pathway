-- Enrollment Pathway — Supabase schema
-- Run this once in your Supabase project's SQL editor (Database > SQL Editor > New query).
-- Safe to re-run: each statement either creates something fresh or is a no-op if it already exists.

create extension if not exists pgcrypto;

create table if not exists students (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  parent_name text,
  parent_phone text,
  parent_email text,
  age_grade text,
  subject text,
  notes text,
  status text,
  follow_up_status text,
  follow_up_notes text,
  created_at timestamptz not null default now()
);

create table if not exists diagnostics (
  id uuid primary key default gen_random_uuid(),
  student_id uuid references students(id) on delete cascade,
  student_name text,
  parent_name text,
  contact text,
  age_grade text,
  date text,
  time text,
  examiner text,
  subject text,
  inquiry text,
  status text,
  outcome text,
  notes text,
  follow_up_status text,
  follow_up_notes text,
  created_at timestamptz not null default now()
);

create table if not exists trainings (
  id uuid primary key default gen_random_uuid(),
  student_id uuid references students(id) on delete cascade,
  student_name text,
  session_number int,
  date text,
  time text,
  trainer text,
  status text,
  created_at timestamptz not null default now()
);

create table if not exists schedules (
  id uuid primary key default gen_random_uuid(),
  student_id uuid references students(id) on delete cascade,
  student_name text,
  slots jsonb,
  start_date text,
  status text,
  created_at timestamptz not null default now()
);

-- One row: id = 'staff', value = {"examiners": [...], "trainer": "..."}
create table if not exists settings (
  id text primary key,
  value jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Turn on Realtime so every team member's screen updates live when someone else makes a change.
-- (Dashboard alternative: Database > Replication > toggle these 5 tables on.)
-- Note: unlike the rest of this script, this one line isn't safe to re-run — if you run the
-- whole script twice you'll get a harmless "already member of publication" error here; ignore it.
alter publication supabase_realtime add table students, diagnostics, trainings, schedules, settings;

-- Row Level Security ---------------------------------------------------------
-- This app has no login screen — like the Claude version it replaces, anyone with the app's
-- URL and your Supabase anon key can read and write everything. The anon key is not secret
-- (it ends up in the page source no matter what), so the only real gate is these policies.
-- The policies below just keep that same "anyone on the link can use it" behavior. If you
-- want real access control later, add Supabase Auth and tighten these policies to check
-- auth.uid() — ask Claude for help with that when you're ready.

alter table students enable row level security;
alter table diagnostics enable row level security;
alter table trainings enable row level security;
alter table schedules enable row level security;
alter table settings enable row level security;

drop policy if exists "public access" on students;
create policy "public access" on students for all using (true) with check (true);

drop policy if exists "public access" on diagnostics;
create policy "public access" on diagnostics for all using (true) with check (true);

drop policy if exists "public access" on trainings;
create policy "public access" on trainings for all using (true) with check (true);

drop policy if exists "public access" on schedules;
create policy "public access" on schedules for all using (true) with check (true);

drop policy if exists "public access" on settings;
create policy "public access" on settings for all using (true) with check (true);
