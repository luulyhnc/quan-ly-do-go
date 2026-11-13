-- Wood app role access for shared mahi-manager Supabase project.
-- Housing tables and public.profiles are intentionally untouched.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

alter table public.wood_profiles alter column role set default 'viewer';

-- Internal helpers are not exposed through the PostgREST API.
create or replace function private.current_wood_role()
returns text language sql stable security definer
set search_path = '' set row_security = off
as $$ select role from public.wood_profiles where id = (select auth.uid()) $$;

create or replace function private.has_wood_access()
returns boolean language sql stable security definer
set search_path = '' set row_security = off
as $$ select coalesce(private.current_wood_role() in ('owner','admin','viewer'),false) $$;

create or replace function private.can_manage_wood()
returns boolean language sql stable security definer
set search_path = '' set row_security = off
as $$ select coalesce(private.current_wood_role() in ('owner','admin'),false) $$;

create or replace function private.is_wood_owner()
returns boolean language sql stable security definer
set search_path = '' set row_security = off
as $$ select coalesce(private.current_wood_role()='owner',false) $$;

revoke all on function private.current_wood_role(), private.has_wood_access(), private.can_manage_wood(), private.is_wood_owner() from public, anon, authenticated;
grant execute on function private.current_wood_role(), private.has_wood_access(), private.can_manage_wood(), private.is_wood_owner() to authenticated;

-- Public API wrappers are SECURITY INVOKER; authorization happens in private functions/RLS.
create or replace function public.current_wood_role()
returns text language sql stable security invoker
set search_path = ''
as $$ select private.current_wood_role() $$;
create or replace function public.has_wood_access()
returns boolean language sql stable security invoker
set search_path = ''
as $$ select private.has_wood_access() $$;
create or replace function public.can_manage_wood()
returns boolean language sql stable security invoker
set search_path = ''
as $$ select private.can_manage_wood() $$;
create or replace function public.is_wood_owner()
returns boolean language sql stable security invoker
set search_path = ''
as $$ select private.is_wood_owner() $$;

revoke all on function public.current_wood_role(), public.has_wood_access(), public.can_manage_wood(), public.is_wood_owner() from public, anon;
grant execute on function public.current_wood_role(), public.has_wood_access(), public.can_manage_wood(), public.is_wood_owner() to authenticated;

drop policy if exists wood_state_read on public.wood_app_state;
drop policy if exists wood_state_insert on public.wood_app_state;
drop policy if exists wood_state_update on public.wood_app_state;
create policy wood_state_read on public.wood_app_state for select to authenticated using (private.has_wood_access());
create policy wood_state_insert on public.wood_app_state for insert to authenticated with check (private.can_manage_wood() and updated_by=(select auth.uid()));
create policy wood_state_update on public.wood_app_state for update to authenticated using (private.can_manage_wood()) with check (private.can_manage_wood() and updated_by=(select auth.uid()));

drop policy if exists wood_profiles_read_self on public.wood_profiles;
drop policy if exists wood_profiles_owner_insert on public.wood_profiles;
drop policy if exists wood_profiles_owner_update on public.wood_profiles;
drop policy if exists wood_profiles_owner_delete on public.wood_profiles;
create policy wood_profiles_read_self on public.wood_profiles for select to authenticated using (id=(select auth.uid()) or private.can_manage_wood());
create policy wood_profiles_owner_insert on public.wood_profiles for insert to authenticated with check (private.is_wood_owner());
create policy wood_profiles_owner_update on public.wood_profiles for update to authenticated using (private.is_wood_owner()) with check (private.is_wood_owner());
create policy wood_profiles_owner_delete on public.wood_profiles for delete to authenticated using (private.is_wood_owner());

grant select,insert,update,delete on public.wood_profiles to authenticated;

create or replace function private.list_wood_staff()
returns table(user_id uuid,email text,full_name text,role text,created_at timestamptz)
language plpgsql security definer
set search_path = '' set row_security = off
as $$
begin
 if auth.uid() is null or not private.is_wood_owner() then
   raise exception 'Chỉ chủ xưởng được xem danh sách nhân sự';
 end if;
 return query
   select w.id,u.email::text,w.full_name,w.role,w.created_at
   from public.wood_profiles w
   left join auth.users u on u.id=w.id
   order by case w.role when 'owner' then 0 when 'admin' then 1 else 2 end,w.created_at;
end $$;

create or replace function private.assign_wood_role(p_email text,p_full_name text,p_role text)
returns void language plpgsql security definer
set search_path = '' set row_security = off
as $$
declare target_id uuid;
begin
 if auth.uid() is null or not private.is_wood_owner() then
   raise exception 'Chỉ chủ xưởng được phân quyền';
 end if;
 if lower(trim(p_role)) not in ('admin','viewer') then
   raise exception 'Vai trò chỉ được là admin hoặc viewer';
 end if;
 select id into target_id from auth.users where lower(email)=lower(trim(p_email)) limit 1;
 if target_id is null then
   raise exception 'Không tìm thấy tài khoản Auth có email này. Hãy tạo tài khoản trong Authentication trước.';
 end if;
 insert into public.wood_profiles(id,full_name,role)
 values(target_id,coalesce(nullif(trim(p_full_name),''),split_part(trim(p_email),'@',1)),lower(trim(p_role)))
 on conflict(id) do update set full_name=excluded.full_name,role=excluded.role;
end $$;

revoke all on function private.list_wood_staff(), private.assign_wood_role(text,text,text) from public, anon, authenticated;
grant execute on function private.list_wood_staff(), private.assign_wood_role(text,text,text) to authenticated;

create or replace function public.list_wood_staff()
returns table(user_id uuid,email text,full_name text,role text,created_at timestamptz)
language sql security invoker set search_path = ''
as $$ select * from private.list_wood_staff() $$;

create or replace function public.assign_wood_role(p_email text,p_full_name text,p_role text)
returns void language sql security invoker set search_path = ''
as $$ select private.assign_wood_role(p_email,p_full_name,p_role) $$;

revoke all on function public.list_wood_staff(), public.assign_wood_role(text,text,text) from public, anon;
grant execute on function public.list_wood_staff(), public.assign_wood_role(text,text,text) to authenticated;
