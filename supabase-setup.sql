-- SECRET SANTA: Supabase SQL setup
-- Vykdyk visa failo turinį Supabase -> SQL Editor -> New query -> Run.
-- Šis skriptas paruošia 8 dalyvius ir atsitiktinį paskirstymą be savo vardo.

create extension if not exists pgcrypto;

create table if not exists public.santa_players (
  id integer primary key,
  name text not null unique,
  claimed_by uuid unique,
  drawn_at timestamptz
);

create table if not exists public.santa_assignments (
  giver_id integer primary key references public.santa_players(id) on delete cascade,
  receiver_id integer not null unique references public.santa_players(id) on delete cascade
);

insert into public.santa_players (id, name) values
  (1, 'Dainius'),
  (2, 'Žana'),
  (3, 'Martynas'),
  (4, 'Rafal'),
  (5, 'Evelina'),
  (6, 'Božena'),
  (7, 'Justina'),
  (8, 'Simona')
on conflict (id) do nothing;

-- Sukuria paskirstymą tik tada, jei jo dar nėra.
do $$
declare
  giver_ids integer[] := array[1,2,3,4,5,6,7,8];
  receiver_ids integer[];
begin
  if (select count(*) from public.santa_assignments) = 0 then
    loop
      select array_agg(x order by random()) into receiver_ids
      from unnest(giver_ids) as t(x);
      exit when not exists (
        select 1
        from generate_subscripts(giver_ids, 1) as s(i)
        where giver_ids[s.i] = receiver_ids[s.i]
      );
    end loop;

    insert into public.santa_assignments (giver_id, receiver_id)
    select giver_ids[s.i], receiver_ids[s.i]
    from generate_subscripts(giver_ids, 1) as s(i);
  end if;
end $$;

alter table public.santa_players enable row level security;
alter table public.santa_assignments enable row level security;

-- Tiesioginės lentelių užklausos uždraustos. Duomenys pasiekiami tik per saugias funkcijas.
revoke all on public.santa_players from anon, authenticated;
revoke all on public.santa_assignments from anon, authenticated;

create or replace function public.claim_player(p_name text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id integer;
  v_owner uuid;
begin
  if auth.uid() is null then
    raise exception 'Reikia prisijungti';
  end if;

  select id, claimed_by into v_id, v_owner
  from public.santa_players
  where name = p_name;

  if v_id is null then
    raise exception 'Neteisingas vardas';
  end if;

  if v_owner is not null and v_owner <> auth.uid() then
    raise exception 'Šis vardas jau užimtas kitame įrenginyje';
  end if;

  update public.santa_players
  set claimed_by = auth.uid()
  where id = v_id;
end;
$$;

create or replace function public.my_player()
returns table(name text, has_drawn boolean)
language sql
security definer
set search_path = public
as $$
  select p.name, (p.drawn_at is not null)
  from public.santa_players p
  where p.claimed_by = auth.uid()
  limit 1;
$$;

create or replace function public.get_status()
returns table(name text, is_drawn boolean)
language sql
security definer
set search_path = public
as $$
  select p.name, (p.drawn_at is not null)
  from public.santa_players p
  order by p.id;
$$;

create or replace function public.draw_card()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_giver integer;
  v_receiver integer;
  v_target text;
begin
  if auth.uid() is null then
    raise exception 'Reikia prisijungti';
  end if;

  select id into v_giver
  from public.santa_players
  where claimed_by = auth.uid();

  if v_giver is null then
    raise exception 'Pirmiausia pasirink savo vardą';
  end if;

  select receiver_id into v_receiver
  from public.santa_assignments
  where giver_id = v_giver;

  if v_receiver is null then
    raise exception 'Paskirstymas nerastas';
  end if;

  update public.santa_players
  set drawn_at = coalesce(drawn_at, now())
  where id = v_giver;

  select name into v_target
  from public.santa_players
  where id = v_receiver;

  -- Grąžinamas tik prisijungusio dalyvio gavėjas.
  return v_target;
end;
$$;

revoke all on function public.claim_player(text) from public;
revoke all on function public.my_player() from public;
revoke all on function public.get_status() from public;
revoke all on function public.draw_card() from public;

grant execute on function public.claim_player(text) to authenticated;
grant execute on function public.my_player() to authenticated;
grant execute on function public.get_status() to authenticated;
grant execute on function public.draw_card() to authenticated;
