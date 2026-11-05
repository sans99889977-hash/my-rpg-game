-- RPG Adventure: Supabase schema (run in Supabase Dashboard > SQL Editor)
-- Auth users are managed by Supabase Auth. The game maps usernames to synthetic
-- addresses ending in @players.invalid; disable Email confirmations for this
-- username-only login flow (Authentication > Providers > Email).

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null check (char_length(username) between 3 and 24),
  username_key text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.game_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.player_stats (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  power bigint not null default 0,
  class_key text,
  level integer not null default 1,
  updated_at timestamptz not null default now()
);

create or replace view public.leaderboard
with (security_invoker = true) as
select p.username, s.power, s.class_key, s.level, s.updated_at
from public.player_stats s
join public.profiles p on p.id = s.user_id;

create table if not exists public.guilds (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  owner_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.guild_members (
  guild_id uuid not null references public.guilds(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (guild_id, user_id),
  -- MVP: a player can belong to only one guild at a time.
  unique (user_id)
);

create table if not exists public.game_events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  reward jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create index if not exists game_events_active_dates_idx
  on public.game_events (active, starts_at, ends_at);
create index if not exists player_stats_power_idx
  on public.player_stats (power desc);
create index if not exists guild_members_guild_idx
  on public.guild_members (guild_id);

alter table public.profiles enable row level security;
alter table public.game_saves enable row level security;
alter table public.player_stats enable row level security;
alter table public.guilds enable row level security;
alter table public.guild_members enable row level security;
alter table public.game_events enable row level security;

-- Profiles: public usernames for leaderboard/guild roster; only owner can mutate own row.
drop policy if exists "profiles readable" on public.profiles;
create policy "profiles readable" on public.profiles for select using (true);
drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles for insert to authenticated with check (id = auth.uid());
drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Saves are private to their account.
drop policy if exists "save read own" on public.game_saves;
create policy "save read own" on public.game_saves for select to authenticated using (user_id = auth.uid());
drop policy if exists "save insert own" on public.game_saves;
create policy "save insert own" on public.game_saves for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "save update own" on public.game_saves;
create policy "save update own" on public.game_saves for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Public leaderboard data, writable only by the player who owns the row.
drop policy if exists "stats readable" on public.player_stats;
create policy "stats readable" on public.player_stats for select using (true);
drop policy if exists "stats insert own" on public.player_stats;
create policy "stats insert own" on public.player_stats for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "stats update own" on public.player_stats;
create policy "stats update own" on public.player_stats for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Guild discovery is public; only owner creates/edits; members can join/leave themselves.
drop policy if exists "guilds readable" on public.guilds;
create policy "guilds readable" on public.guilds for select using (true);
drop policy if exists "guild create own" on public.guilds;
create policy "guild create own" on public.guilds for insert to authenticated with check (owner_id = auth.uid());
drop policy if exists "guild owner update" on public.guilds;
create policy "guild owner update" on public.guilds for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists "guild members readable" on public.guild_members;
create policy "guild members readable" on public.guild_members for select using (true);
drop policy if exists "join as self" on public.guild_members;
create policy "join as self" on public.guild_members for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "leave as self" on public.guild_members;
create policy "leave as self" on public.guild_members for delete to authenticated using (user_id = auth.uid());

-- Event records are public-read. Create/manage events from the Supabase dashboard
-- or a trusted server using the service_role key (never put service_role in HTML).
drop policy if exists "active events readable" on public.game_events;
create policy "active events readable" on public.game_events for select using (active = true);

-- Realtime presence/broadcast channels (world-online and party-*) are used by the client.
-- No service_role key is required in the browser. Configure Realtime channel access
-- to permit authenticated users to join these channels in your project settings.
