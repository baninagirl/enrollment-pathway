-- Kumon Hub — Phase 1: roles (admin / superadmin)
-- Run this in Supabase: SQL Editor > New query. Safe to re-run.
--
-- What this does:
--   1. Adds a `profiles` table — one row per login, holding their role.
--   2. Auto-creates a profile (role: admin, the safer default) whenever a new login
--      is created in Supabase, so you never have to remember to do it by hand.
--   3. Backfills a profile for any logins that already exist (e.g. the account(s)
--      you made before running this).
--   4. Locks it down so only a superadmin can change anyone's role.
--
-- After running this, open the SQL editor again and run ONE line (see the very
-- bottom of this file) to make your own account the first superadmin — every
-- other account defaults to admin until a superadmin changes it in the app's
-- new Admin page.

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'admin' check (role in ('admin','superadmin')),
  created_at timestamptz not null default now()
);

alter table profiles enable row level security;

-- Anyone logged in can see the team list (just email + role, nothing sensitive) —
-- needed so the app can show "that's you" and so a future page can show who's on
-- the team without needing superadmin access just to look.
drop policy if exists "read all profiles" on profiles;
create policy "read all profiles" on profiles for select
  using (auth.role() = 'authenticated');

-- Only a superadmin can change anyone's role — checks the CALLER's own profiles row.
drop policy if exists "superadmins manage roles" on profiles;
create policy "superadmins manage roles" on profiles for update
  using (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'))
  with check (exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'superadmin'));

-- Auto-creates a profile row (role: admin) the moment a new login is added in
-- Supabase's Authentication tab — SECURITY DEFINER so it can insert despite RLS.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'admin')
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill: give every login that already exists a profile row, if it doesn't have
-- one yet (e.g. the account(s) you created before this migration existed).
insert into profiles (id, email, role)
select id, email, 'admin' from auth.users
on conflict (id) do nothing;

-- LAST STEP — run this separately, with your own login email, to make yourself the
-- first superadmin (everyone else stays "admin" until you promote them in the app):
--
--   update profiles set role = 'superadmin' where email = 'you@example.com';
