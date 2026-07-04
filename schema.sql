-- 결(Kyeol) — Supabase 스키마. SQL Editor에 통째로 붙여넣고 Run.
-- events: 감정 사건 1행 = 1기록. RLS로 본인 데이터만 접근.

create table if not exists public.events (
  id         text primary key,
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data       jsonb not null,                 -- 앱의 이벤트 객체 전체
  updated_at timestamptz not null default now(),
  deleted    boolean not null default false  -- soft delete (기기간 삭제 전파용)
);

alter table public.events enable row level security;

drop policy if exists own_select on public.events;
drop policy if exists own_insert on public.events;
drop policy if exists own_update on public.events;
drop policy if exists own_delete on public.events;

create policy own_select on public.events for select using (auth.uid() = user_id);
create policy own_insert on public.events for insert with check (auth.uid() = user_id);
create policy own_update on public.events for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy own_delete on public.events for delete using (auth.uid() = user_id);

create index if not exists events_user_idx on public.events(user_id);
