-- ============================================================
-- DU MCQ Practice — Supabase schema for short share-links
-- Run this once in: Supabase Dashboard → SQL Editor → New query
-- ============================================================

-- One row per shared question set. `id` is a random 8-char code
-- generated client-side; `payload` is the same deflate+base64url
-- blob the app already uses inside URL-hash links.
create table if not exists public.quiz_sets (
  id         text primary key,
  payload    text not null,
  created_at timestamptz not null default now(),
  constraint quiz_sets_id_len    check (char_length(id) between 6 and 16),
  constraint quiz_sets_payload   check (char_length(payload) between 1 and 300000)
);

comment on table  public.quiz_sets         is 'Shared MCQ question sets behind #s= short links';
comment on column public.quiz_sets.id      is 'Random unguessable share code (client-generated)';
comment on column public.quiz_sets.payload is 'Deflate-compressed base64url question array';

-- Row Level Security: the anon key may ONLY insert and read.
-- No updates, no deletes, no other tables — that is what makes
-- shipping the anon key in supabase-config.js acceptable.
alter table public.quiz_sets enable row level security;

drop policy if exists "anyone can read shared sets" on public.quiz_sets;
create policy "anyone can read shared sets"
  on public.quiz_sets for select
  to anon, authenticated
  using (true);

drop policy if exists "anyone can create shared sets" on public.quiz_sets;
create policy "anyone can create shared sets"
  on public.quiz_sets for insert
  to anon, authenticated
  with check (true);

-- (intentionally NO update/delete policies for anon)

-- Optional: auto-expire sets after 180 days (keeps the free tier tidy).
-- Supabase has pg_cron enabled: Database → Extensions → pg_cron, then:
-- select cron.schedule(
--   'purge-old-quiz-sets',
--   '0 3 * * *',
--   $$ delete from public.quiz_sets where created_at < now() - interval '180 days' $$
-- );

-- Optional: index for the cleanup job / time queries
create index if not exists quiz_sets_created_at_idx on public.quiz_sets (created_at);
