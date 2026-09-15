-- Peace Break — schéma de base de données.
--
-- Sur un projet Supabase neuf :
--   1. Exécuter ce fichier dans le SQL Editor
--   2. Exécuter seed.sql
--   3. Désactiver la confirmation d'email dans Auth > Providers > Email
--   4. Compiler l'app avec --dart-define pointant sur l'instance

\restrict ttIRyapW3L9OlkZHXe0sh8CZDlxLbSAyrOoV356f6ymuSIfps07ThWeiyMJZOmo

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.11 (Debian 17.11-0+deb13u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: item_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.item_kind AS ENUM (
    'life_plus',
    'paddle_skin',
    'ball_skin'
);


--
-- Name: complete_stage(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_stage(p_stage integer, p_score integer, p_coins integer) RETURNS TABLE(previous_score integer, saved_score integer, coins_added integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_user   uuid := auth.uid();
  v_old    integer;
  v_saved  integer;
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;
  if p_stage < 1 or p_score < 0 or p_coins < 0 then
    raise exception 'invalid arguments';
  end if;

  select best_score into v_old
  from public.stage_progress
  where user_id = v_user and stage_number = p_stage;

  v_saved := greatest(coalesce(v_old, 0), p_score);

  insert into public.stage_progress (user_id, stage_number, best_score)
  values (v_user, p_stage, v_saved)
  on conflict (user_id, stage_number)
  do update set best_score = v_saved, completed_at = now();

  update public.profiles p
  set
    coins = p.coins + p_coins,
    total_score = (
      select coalesce(sum(sp.best_score), 0)
      from public.stage_progress sp
      where sp.user_id = v_user
    ),
    next_stage = greatest(p.next_stage, least(p_stage + 1, 10))
  where p.id = v_user;

  return query select coalesce(v_old, 0), v_saved, p_coins;
end $$;


--
-- Name: delete_account(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_account() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'auth'
    AS $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  delete from auth.users where id = v_user;
end $$;


--
-- Name: email_for_username(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.email_for_username(p_username text) RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'auth'
    AS $$
  select u.email
  from auth.users u
  join public.profiles p on p.id = u.id
  where lower(p.username) = lower(p_username)
  limit 1
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data ->> 'username');
  return new;
end $$;


--
-- Name: inventory_set_kind(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.inventory_set_kind() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  select kind into new.kind from public.items where id = new.item_id;
  return new;
end $$;


--
-- Name: purchase_item(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.purchase_item(p_item_id text) RETURNS TABLE(new_coins integer, new_max_lives integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_user  uuid := auth.uid();
  v_price integer;
  v_kind  item_kind;
  v_coins integer;
  v_lives integer;
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  select price, kind into v_price, v_kind
  from public.items
  where id = p_item_id;

  if v_price is null then
    raise exception 'unknown item';
  end if;

  -- Verrouille la ligne du profil le temps de la transaction.
  select coins, max_lives into v_coins, v_lives
  from public.profiles
  where id = v_user
  for update;

  if v_coins < v_price then
    raise exception 'insufficient funds';
  end if;

  if v_kind <> 'life_plus' and exists (
    select 1 from public.inventory
    where user_id = v_user and item_id = p_item_id
  ) then
    raise exception 'already owned';
  end if;

  if v_kind = 'life_plus' then
    v_lives := least(v_lives + 1, 10);
    update public.profiles
    set coins = coins - v_price, max_lives = v_lives
    where id = v_user;
  else
    update public.profiles set coins = coins - v_price where id = v_user;
    insert into public.inventory (user_id, item_id, kind)
    values (v_user, p_item_id, v_kind);
  end if;

  return query
    select p.coins, p.max_lives from public.profiles p where p.id = v_user;
end $$;


--
-- Name: reset_progress(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_progress() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  delete from public.stage_progress where user_id = v_user;

  update public.profiles
  set total_score = 0, coins = 0, next_stage = 1
  where id = v_user;
end $$;


--
-- Name: username_available(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.username_available(p_username text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select not exists (
    select 1 from public.profiles where lower(username) = lower(p_username)
  )
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory (
    user_id uuid NOT NULL,
    item_id text NOT NULL,
    kind public.item_kind NOT NULL,
    equipped boolean DEFAULT false NOT NULL,
    purchased_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    price integer NOT NULL,
    kind public.item_kind NOT NULL,
    asset text,
    CONSTRAINT items_price_check CHECK ((price >= 0))
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    username text NOT NULL,
    total_score integer DEFAULT 0 NOT NULL,
    coins integer DEFAULT 0 NOT NULL,
    max_lives integer DEFAULT 3 NOT NULL,
    next_stage integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT profiles_coins_check CHECK ((coins >= 0)),
    CONSTRAINT profiles_max_lives_check CHECK (((max_lives >= 1) AND (max_lives <= 10))),
    CONSTRAINT profiles_next_stage_check CHECK ((next_stage >= 1)),
    CONSTRAINT profiles_total_score_check CHECK ((total_score >= 0)),
    CONSTRAINT profiles_username_check CHECK ((username ~ '^[A-Za-z0-9]{3,10}$'::text))
);


--
-- Name: leaderboard; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.leaderboard AS
 SELECT row_number() OVER (ORDER BY total_score DESC, (lower(username))) AS rank,
    id,
    username,
    total_score
   FROM public.profiles;


--
-- Name: stage_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stage_progress (
    user_id uuid NOT NULL,
    stage_number integer NOT NULL,
    best_score integer DEFAULT 0 NOT NULL,
    completed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT stage_progress_best_score_check CHECK ((best_score >= 0)),
    CONSTRAINT stage_progress_stage_number_check CHECK ((stage_number >= 1))
);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (user_id, item_id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: stage_progress stage_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stage_progress
    ADD CONSTRAINT stage_progress_pkey PRIMARY KEY (user_id, stage_number);


--
-- Name: inventory_one_equipped_per_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX inventory_one_equipped_per_kind ON public.inventory USING btree (user_id, kind) WHERE equipped;


--
-- Name: profiles_username_lower_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX profiles_username_lower_idx ON public.profiles USING btree (lower(username));


--
-- Name: inventory inventory_kind_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER inventory_kind_trigger BEFORE INSERT ON public.inventory FOR EACH ROW EXECUTE FUNCTION public.inventory_set_kind();


--
-- Name: inventory inventory_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: inventory inventory_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: stage_progress stage_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stage_progress
    ADD CONSTRAINT stage_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: items catalogue lisible; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "catalogue lisible" ON public.items FOR SELECT TO authenticated USING (true);


--
-- Name: inventory inventaire du proprietaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "inventaire du proprietaire" ON public.inventory TO authenticated USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: inventory; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;

--
-- Name: items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profil modifiable par son proprietaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profil modifiable par son proprietaire" ON public.profiles FOR UPDATE TO authenticated USING ((auth.uid() = id)) WITH CHECK (((auth.uid() = id) AND (coins = ( SELECT profiles_1.coins
   FROM public.profiles profiles_1
  WHERE (profiles_1.id = auth.uid()))) AND (total_score = ( SELECT profiles_1.total_score
   FROM public.profiles profiles_1
  WHERE (profiles_1.id = auth.uid())))));


--
-- Name: profiles profil supprimable par son proprietaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profil supprimable par son proprietaire" ON public.profiles FOR DELETE TO authenticated USING ((auth.uid() = id));


--
-- Name: profiles profil visible par son proprietaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profil visible par son proprietaire" ON public.profiles FOR SELECT TO authenticated USING ((auth.uid() = id));


--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: stage_progress progression lisible par son proprietaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "progression lisible par son proprietaire" ON public.stage_progress FOR SELECT TO authenticated USING ((auth.uid() = user_id));


--
-- Name: stage_progress progression modifiable par son proprietaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "progression modifiable par son proprietaire" ON public.stage_progress TO authenticated USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: stage_progress; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.stage_progress ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict ttIRyapW3L9OlkZHXe0sh8CZDlxLbSAyrOoV356f6ymuSIfps07ThWeiyMJZOmo


-- Trigger sur auth.users : crée le profil à l'inscription.
-- Absent du dump car le schéma auth appartient à Supabase.
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
