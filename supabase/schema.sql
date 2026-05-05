-- ============================================================
-- ZeNN Sudoku - Supabase Database Schema
-- ============================================================

-- ─── PROFILES ────────────────────────────────────────────────
create table if not exists public.profiles (
  id              uuid references auth.users on delete cascade primary key,
  username        text,
  email           text,
  avatar_url      text,
  total_diamonds  int  not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Auto-create profile after sign-up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, avatar_url, username)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'avatar_url',
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ─── DAILY PUZZLES ───────────────────────────────────────────
create table if not exists public.daily_puzzles (
  id         uuid        primary key default gen_random_uuid(),
  date       date        unique not null,
  puzzle     text        not null,  -- 81-char string (0 = empty)
  solution   text        not null,  -- 81-char string (full solution)
  difficulty text        not null default 'hard',
  created_at timestamptz not null default now()
);

alter table public.daily_puzzles enable row level security;

create policy "Daily puzzles are publicly readable"
  on public.daily_puzzles for select
  using (true);

-- ─── COMPLETIONS ─────────────────────────────────────────────
-- puzzle_type: 'easy' | 'medium' | 'hard' | 'daily'
create table if not exists public.completions (
  id              uuid        primary key default gen_random_uuid(),
  user_id         uuid        not null references public.profiles(id) on delete cascade,
  puzzle_type     text        not null check (puzzle_type in ('easy','medium','hard','daily')),
  daily_puzzle_id uuid        references public.daily_puzzles(id),
  time_taken      int,        -- seconds
  diamonds_earned int         not null,
  completed_at    timestamptz not null default now(),

  -- Prevent duplicate daily completions
  constraint uq_daily_completion unique (user_id, daily_puzzle_id)
);

alter table public.completions enable row level security;

create policy "Users can insert own completions"
  on public.completions for insert
  with check (auth.uid() = user_id);

create policy "Users can view own completions"
  on public.completions for select
  using (auth.uid() = user_id);

-- ─── DIAMOND TRANSACTIONS ────────────────────────────────────
-- transaction_type: 'puzzle_complete' | 'daily_bonus' | 'monthly_bonus'
create table if not exists public.diamond_transactions (
  id               uuid        primary key default gen_random_uuid(),
  user_id          uuid        not null references public.profiles(id) on delete cascade,
  amount           int         not null,
  transaction_type text        not null,
  description      text,
  created_at       timestamptz not null default now()
);

alter table public.diamond_transactions enable row level security;

create policy "Users can view own transactions"
  on public.diamond_transactions for select
  using (auth.uid() = user_id);

create policy "Users can insert own transactions"
  on public.diamond_transactions for insert
  with check (auth.uid() = user_id);

-- ─── DIAMOND AWARD FUNCTION ──────────────────────────────────
-- Called after a puzzle is completed; updates balance atomically
create or replace function public.award_diamonds(
  p_user_id         uuid,
  p_amount          int,
  p_transaction_type text,
  p_description     text default null
)
returns void language plpgsql security definer as $$
begin
  -- Update balance
  update public.profiles
  set total_diamonds = total_diamonds + p_amount,
      updated_at     = now()
  where id = p_user_id;

  -- Record transaction
  insert into public.diamond_transactions (user_id, amount, transaction_type, description)
  values (p_user_id, p_amount, p_transaction_type, p_description);
end;
$$;

-- ─── MONTHLY BONUS CHECK ─────────────────────────────────────
-- Returns true when the user has completed every daily puzzle in a month
create or replace function public.check_monthly_bonus(
  p_user_id uuid,
  p_year    int,
  p_month   int
)
returns boolean language plpgsql security definer as $$
declare
  v_total_days   int;
  v_completed    int;
begin
  -- How many daily puzzles exist for that month
  select count(*) into v_total_days
  from public.daily_puzzles
  where extract(year  from date) = p_year
    and extract(month from date) = p_month;

  if v_total_days = 0 then return false; end if;

  -- How many the user has completed
  select count(*) into v_completed
  from public.completions c
  join public.daily_puzzles dp on dp.id = c.daily_puzzle_id
  where c.user_id   = p_user_id
    and c.puzzle_type = 'daily'
    and extract(year  from dp.date) = p_year
    and extract(month from dp.date) = p_month;

  return v_completed >= v_total_days;
end;
$$;

-- ─── LEADERBOARD VIEW (optional) ─────────────────────────────
create or replace view public.leaderboard as
select
  p.id,
  p.username,
  p.avatar_url,
  p.total_diamonds,
  count(c.id) filter (where c.puzzle_type = 'easy')   as easy_count,
  count(c.id) filter (where c.puzzle_type = 'medium')  as medium_count,
  count(c.id) filter (where c.puzzle_type = 'hard')    as hard_count,
  count(c.id) filter (where c.puzzle_type = 'daily')   as daily_count
from public.profiles p
left join public.completions c on c.user_id = p.id
group by p.id
order by p.total_diamonds desc;
