-- phase119: "Picked up worksheets" on the Calendar.
-- Run once in the Supabase SQL Editor of the "Enrollment Hub" project (bcnmsryahczapnxbpkve).
--
-- Adds three columns to schedule_attendance, the table the Calendar's "arrived" tick already uses.
-- A visit can now be: Came (arrived = true), Picked up (picked_up = true), or nothing (shown as Missed
-- once the day has passed). Rescheduled visits are the existing one-week moves (schedule_moves).
-- No data is changed or removed. Safe to run more than once.

alter table public.schedule_attendance
  add column if not exists picked_up    boolean not null default false,
  add column if not exists picked_up_at timestamptz,
  add column if not exists picked_up_by text;

-- The Calendar saves a pick-up with the same insert/update it uses for the arrived tick, so the
-- existing row-level security rules on schedule_attendance already cover it — nothing to add there.

-- Check: should list the three new columns.
select column_name, data_type, column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'schedule_attendance'
  and column_name in ('picked_up', 'picked_up_at', 'picked_up_by')
order by column_name;
