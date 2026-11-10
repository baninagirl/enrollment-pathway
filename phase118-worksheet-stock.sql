-- Kumon Hub — Phase 118: Worksheets page (stock per level, order suggestions, order checks). Admins only.
-- Run in Supabase (project "Enrollment Hub", address starts with bcnmsryahczapnxbpkve):
-- SQL Editor > New query > paste > Run. Safe to re-run. Run it BEFORE committing worksheets.html.
--
-- ws_counts   one row per shelf count of a subject (PSE / ME / EEU, or AT = achievement tests): how many copies of each block were on the
--             shelf that day, plus where every child was that day (so the Hub can work out what was used since).
-- ws_orders   the Kumon orders, read from the "Web Ordering Detail" PDFs (one row per order number).
-- ws_settings page settings (how many weeks to plan for, last month's "Used" from Kumon's Stock Summary).
-- Only admins and superadmins can see or change any of it (same rule as the PTC admin parts: ptc_is_admin()).

create table if not exists ws_counts (
  id          uuid primary key default gen_random_uuid(),
  subject     text not null,                          -- PSE / ME / EEU, or AT (achievement tests)
  counted_on  date not null,
  counted_by  text,
  lines       jsonb not null default '{}'::jsonb,   -- { "B": { "1": 40, "11": 35, ... }, ... }
  positions   jsonb not null default '{}'::jsonb,   -- { "<subject_enrollment_id>": <page number across levels>, ... }
  created_at  timestamptz not null default now()
);
-- (re-run safe) which subjects a count can be for: worksheets per subject, plus AT = achievement tests
alter table ws_counts drop constraint if exists ws_counts_subject_check;
alter table ws_counts add constraint ws_counts_subject_check check (subject in ('PSE','ME','EEU','AT'));
create index if not exists idx_ws_counts_subject on ws_counts(subject, counted_on desc);

create table if not exists ws_orders (
  id          uuid primary key default gen_random_uuid(),
  order_no    text not null unique,
  order_date  date,
  status      text,
  order_type  text,
  order_by    text,
  received_on date,                                  -- set when the boxes arrive; only then it counts as stock
  lines       jsonb not null default '{}'::jsonb,    -- { "ME": { "B": { "41": 100 } }, "EEU": {...}, "PSE": {...} }
  items       jsonb not null default '[]'::jsonb,    -- other items (tests, stickers…): [{ name, qty, cost }]
  remark      text,
  file_name   text,
  uploaded_by text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table if not exists ws_settings (
  id    text primary key,
  value jsonb not null default '{}'::jsonb
);

alter table ws_counts   enable row level security;
alter table ws_orders   enable row level security;
alter table ws_settings enable row level security;
grant select, insert, update, delete on ws_counts, ws_orders, ws_settings to authenticated;

drop policy if exists "ws counts admins" on ws_counts;
drop policy if exists "ws orders admins" on ws_orders;
drop policy if exists "ws settings admins" on ws_settings;
create policy "ws counts admins" on ws_counts for all
  using ((select public.ptc_is_admin())) with check ((select public.ptc_is_admin()));
create policy "ws orders admins" on ws_orders for all
  using ((select public.ptc_is_admin())) with check ((select public.ptc_is_admin()));
create policy "ws settings admins" on ws_settings for all
  using ((select public.ptc_is_admin())) with check ((select public.ptc_is_admin()));

-- Check: should show 3 rows, all rls_on = true.
select tablename, rowsecurity as rls_on from pg_tables
 where schemaname = 'public' and tablename in ('ws_counts','ws_orders','ws_settings') order by tablename;
