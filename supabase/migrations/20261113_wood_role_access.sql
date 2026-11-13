-- Wood app access control for the shared mahi-manager Supabase project.
-- Does not modify the housing app's public.profiles or housing tables.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

alter table public.wood_profiles alter column role set default 'viewer';

create or replace function public.current_wood_role()
returns text language sql stable security definer
set search_path=public set row_security=off
as $$ select role from public.wood_profiles where id=auth.uid() $$;

create or replace function public.has_wood_access()
returns boolean language sql stable security definer
set search_path=public set row_security=off
as $$ select coalesce(public.current_wood_role() in ('owner','admin','viewer'),false) $$;

create or replace function public.can_manage_wood()
returns boolean language sql stable security definer
set search_path=public set row_security=off
as $$ select coalesce(public.current_wood_role() in ('owner','admin'),false) $$;

create or replace function public.is_wood_owner()
returns boolean language sql stable security definer
set search_path=public set row_security=off
as $$ select coalesce(public.current_wood_role()='owner',false) $$;

revoke all on function public.current_wood_role() from public;
revoke all on function public.has_wood_access() from public;
revoke all on function public.can_manage_wood() from public;
revoke all on function public.is_wood_owner() from public;
grant execute on function public.current_wood_role(),public.has_wood_access(),public.can_manage_wood(),public.is_wood_owner() to authenticated;

drop policy if exists wood_state_read on public.wood_app_state;
drop policy if exists wood_state_insert on public.wood_app_state;
drop policy if exists wood_state_update on public.wood_app_state;
create policy wood_state_read on public.wood_app_state for select to authenticated using(public.has_wood_access());
create policy wood_state_insert on public.wood_app_state for insert to authenticated with check(public.can_manage_wood() and updated_by=auth.uid());
create policy wood_state_update on public.wood_app_state for update to authenticated using(public.can_manage_wood()) with check(public.can_manage_wood() and updated_by=auth.uid());

drop policy if exists wood_profiles_read_self on public.wood_profiles;
drop policy if exists wood_profiles_owner_insert on public.wood_profiles;
drop policy if exists wood_profiles_owner_update on public.wood_profiles;
drop policy if exists wood_profiles_owner_delete on public.wood_profiles;
create policy wood_profiles_read_self on public.wood_profiles for select to authenticated using(id=auth.uid() or public.can_manage_wood());
create policy wood_profiles_owner_insert on public.wood_profiles for insert to authenticated with check(public.is_wood_owner());
create policy wood_profiles_owner_update on public.wood_profiles for update to authenticated using(public.is_wood_owner()) with check(public.is_wood_owner());
create policy wood_profiles_owner_delete on public.wood_profiles for delete to authenticated using(public.is_wood_owner());

grant select,insert,update,delete on public.wood_profiles to authenticated;

create or replace function public.list_wood_staff()
returns table(user_id uuid,email text,full_name text,role text,created_at timestamptz)
language plpgsql security definer set search_path=public,auth set row_security=off
as $$
begin
 if not public.is_wood_owner() then raise exception 'Chỉ chủ xưởng được xem danh sách nhân sự'; end if;
 return query select w.id,u.email::text,w.full_name,w.role,w.created_at
 from public.wood_profiles w left join auth.users u on u.id=w.id
 order by case w.role when 'owner' then 0 when 'admin' then 1 else 2 end,w.created_at;
end $$;

create or replace function public.assign_wood_role(p_email text,p_full_name text,p_role text)
returns void language plpgsql security definer set search_path=public,auth set row_security=off
as $$
declare target_id uuid;
begin
 if not public.is_wood_owner() then raise exception 'Chỉ chủ xưởng được phân quyền'; end if;
 if lower(trim(p_role)) not in ('admin','viewer') then raise exception 'Vai trò chỉ được là admin hoặc viewer'; end if;
 select id into target_id from auth.users where lower(email)=lower(trim(p_email)) limit 1;
 if target_id is null then raise exception 'Không tìm thấy tài khoản Auth có email này. Hãy tạo tài khoản trong Authentication trước.'; end if;
 insert into public.wood_profiles(id,full_name,role)
 values(target_id,coalesce(nullif(trim(p_full_name),''),split_part(trim(p_email),'@',1)),lower(trim(p_role)))
 on conflict(id) do update set full_name=excluded.full_name,role=excluded.role;
end $$;

revoke all on function public.list_wood_staff() from public,anon;
revoke all on function public.assign_wood_role(text,text,text) from public,anon;
grant execute on function public.list_wood_staff() to authenticated;
grant execute on function public.assign_wood_role(text,text,text) to authenticated;
