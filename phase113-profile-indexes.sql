-- Kumon Hub — Phase 113: indexes so a Student profile opens instantly, however much history builds up
-- Run this in Supabase (project "Enrollment Hub"): SQL Editor > New query. Safe to re-run. Changes no data.
--
-- The profile page reads one child's records at a time (their subjects, schedules, past months, projection,
-- absences, PTCs, payments and attendance ticks). These indexes let the database jump straight to that child.

create index if not exists idx_history_student          on enrollment_monthly_history(student_id);
create index if not exists idx_schedules_student        on schedules(student_id);
create index if not exists idx_projections_student      on study_projections(student_id);
create index if not exists idx_absences_student         on absence_records(student_id);
create index if not exists idx_ptc_milestones_student   on ptc_milestones(student_id);
create index if not exists idx_receipts_student         on payment_receipts(student_id);
create index if not exists idx_attendance_sched_week    on schedule_attendance(schedule_id, week_start);

select 'profile indexes ready' as status;
