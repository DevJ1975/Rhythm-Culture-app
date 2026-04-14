-- =============================================================
-- Rhythm Culture — Supabase Database Setup
-- Run this in: Supabase Dashboard → SQL Editor → New query
-- =============================================================

-- ---------------------------------------------------------------
-- 1. PROFILES (extends auth.users)
-- ---------------------------------------------------------------
create table if not exists public.profiles (
    id               uuid primary key references auth.users(id) on delete cascade,
    username         text unique not null,
    display_name     text not null,
    email            text not null,
    profile_image_url text,
    bio              text,
    artist_type      text,                   -- matches ArtistType raw values
    genres           text[]   default '{}',
    location         text,
    followers_count  int      default 0,
    following_count  int      default 0,
    posts_count      int      default 0,
    created_at       timestamptz default now()
);

-- Make profiles readable by everyone, writable only by owner
alter table public.profiles enable row level security;

create policy "Profiles are viewable by everyone"
    on public.profiles for select
    using (true);

create policy "Users can insert their own profile"
    on public.profiles for insert
    with check (auth.uid() = id);

create policy "Users can update their own profile"
    on public.profiles for update
    using (auth.uid() = id);

-- ---------------------------------------------------------------
-- 2. POSTS
-- ---------------------------------------------------------------
create table if not exists public.posts (
    id               uuid primary key default gen_random_uuid(),
    author_id        uuid not null references public.profiles(id) on delete cascade,
    caption          text not null default '',
    media_urls       text[]   default '{}',
    media_type       text     default 'image',  -- 'image' | 'video'
    post_type        text     default 'standard', -- 'standard' | 'drop' | 'battle' | 'showcase' | 'collab'
    genre            text,
    likes_count      int      default 0,
    comments_count   int      default 0,
    vibe_fire        int      default 0,
    vibe_move        int      default 0,
    vibe_vibes       int      default 0,
    vibe_respect     int      default 0,
    created_at       timestamptz default now()
);

alter table public.posts enable row level security;

create policy "Posts are viewable by everyone"
    on public.posts for select
    using (true);

create policy "Users can insert their own posts"
    on public.posts for insert
    with check (auth.uid() = author_id);

create policy "Users can update their own posts"
    on public.posts for update
    using (auth.uid() = author_id);

create policy "Users can delete their own posts"
    on public.posts for delete
    using (auth.uid() = author_id);

-- ---------------------------------------------------------------
-- 3. COMMENTS
-- ---------------------------------------------------------------
create table if not exists public.comments (
    id               uuid primary key default gen_random_uuid(),
    post_id          uuid not null references public.posts(id) on delete cascade,
    author_id        uuid not null references public.profiles(id) on delete cascade,
    text             text not null,
    likes_count      int  default 0,
    created_at       timestamptz default now()
);

alter table public.comments enable row level security;

create policy "Comments are viewable by everyone"
    on public.comments for select
    using (true);

create policy "Users can insert their own comments"
    on public.comments for insert
    with check (auth.uid() = author_id);

create policy "Users can delete their own comments"
    on public.comments for delete
    using (auth.uid() = author_id);

-- ---------------------------------------------------------------
-- 4. FOLLOWS
-- ---------------------------------------------------------------
create table if not exists public.follows (
    follower_id  uuid not null references public.profiles(id) on delete cascade,
    following_id uuid not null references public.profiles(id) on delete cascade,
    created_at   timestamptz default now(),
    primary key (follower_id, following_id)
);

alter table public.follows enable row level security;

create policy "Follows are viewable by everyone"
    on public.follows for select
    using (true);

create policy "Users can follow others"
    on public.follows for insert
    with check (auth.uid() = follower_id);

create policy "Users can unfollow"
    on public.follows for delete
    using (auth.uid() = follower_id);

-- ---------------------------------------------------------------
-- 5. AUTO-UPDATE FOLLOWER / FOLLOWING COUNTS
-- ---------------------------------------------------------------
create or replace function public.update_follow_counts()
returns trigger language plpgsql security definer as $$
begin
    if tg_op = 'INSERT' then
        update public.profiles set following_count = following_count + 1 where id = new.follower_id;
        update public.profiles set followers_count = followers_count + 1 where id = new.following_id;
    elsif tg_op = 'DELETE' then
        update public.profiles set following_count = following_count - 1 where id = old.follower_id;
        update public.profiles set followers_count = followers_count - 1 where id = old.following_id;
    end if;
    return null;
end;
$$;

create trigger on_follow_change
    after insert or delete on public.follows
    for each row execute function public.update_follow_counts();

-- ---------------------------------------------------------------
-- 6. STORAGE BUCKET
-- ---------------------------------------------------------------
-- Run this separately in the Supabase Storage tab:
--   Create a bucket named "media" (public: true)
--   Then add an RLS policy: authenticated users can upload to their own folder (media/{user_id}/*)
