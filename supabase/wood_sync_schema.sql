-- Backend đồng bộ đang dùng trong dự án Supabase sua-hat-manager.
-- Bảng có tiền tố wood_ để tách hoàn toàn dữ liệu hai ứng dụng.
create table if not exists public.wood_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'admin' check (role in ('owner','admin','viewer')),
  created_at timestamptz not null default now()
);

create table if not exists public.wood_app_state (
  id text primary key default 'main' check (id = 'main'),
  data jsonb not null default '{"materials":[],"lots":[],"issues":[]}'::jsonb,
  version bigint not null default 1,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

alter table public.wood_profiles enable row level security;
alter table public.wood_app_state enable row level security;

create policy wood_profiles_read_self on public.wood_profiles
for select to authenticated using (id = (select auth.uid()));
create policy wood_state_read on public.wood_app_state
for select to authenticated using ((select auth.uid()) is not null);
create policy wood_state_insert on public.wood_app_state
for insert to authenticated with check ((select auth.uid()) is not null and updated_by = (select auth.uid()));
create policy wood_state_update on public.wood_app_state
for update to authenticated using ((select auth.uid()) is not null)
with check ((select auth.uid()) is not null and updated_by = (select auth.uid()));

grant usage on schema public to authenticated;
grant select on public.wood_profiles to authenticated;
grant select, insert, update on public.wood_app_state to authenticated;

create or replace function public.wood_touch_state() returns trigger
language plpgsql set search_path=public as $$
begin new.updated_at=now(); new.version=old.version+1; return new; end $$;
create trigger wood_state_touch before update on public.wood_app_state
for each row execute function public.wood_touch_state();

insert into public.wood_app_state(id,data)
values ('main','{"materials":[],"lots":[],"issues":[]}'::jsonb)
on conflict(id) do nothing;

alter publication supabase_realtime add table public.wood_app_state;
