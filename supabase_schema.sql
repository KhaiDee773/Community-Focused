-- ============================================
-- Community Focused (CF) - Supabase Schema
-- ============================================
-- Description: Complete database schema with RLS policies
-- Security: All tables have Row Level Security enabled
-- ============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. PROFILES TABLE
-- ============================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    is_banned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Everyone can read non-banned profiles
CREATE POLICY "Public profiles are viewable by everyone" 
    ON profiles FOR SELECT 
    USING (is_banned = FALSE);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" 
    ON profiles FOR UPDATE 
    USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile" 
    ON profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- ============================================
-- 2. POSTS TABLE
-- ============================================
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    media_urls TEXT[], -- Array of image/video URLs
    media_type TEXT CHECK (media_type IN ('image', 'video', 'none')),
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- RLS Policies for posts
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Everyone can read posts from non-banned users
CREATE POLICY "Posts are viewable by everyone" 
    ON posts FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = posts.user_id 
            AND profiles.is_banned = FALSE
        )
    );

-- Users can create their own posts
CREATE POLICY "Users can create posts" 
    ON posts FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own posts
CREATE POLICY "Users can update own posts" 
    ON posts FOR UPDATE 
    USING (auth.uid() = user_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete own posts" 
    ON posts FOR DELETE 
    USING (auth.uid() = user_id);

-- ============================================
-- 3. LIKES TABLE
-- ============================================
CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    reaction_type TEXT DEFAULT 'like' CHECK (reaction_type IN ('like', 'love', 'haha', 'wow', 'sad', 'angry')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id) -- One reaction per user per post
);

CREATE INDEX idx_likes_post_id ON likes(post_id);
CREATE INDEX idx_likes_user_id ON likes(user_id);

ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- Everyone can read likes
CREATE POLICY "Likes are viewable by everyone" 
    ON likes FOR SELECT 
    USING (TRUE);

-- Users can create their own likes
CREATE POLICY "Users can create likes" 
    ON likes FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own likes
CREATE POLICY "Users can delete own likes" 
    ON likes FOR DELETE 
    USING (auth.uid() = user_id);

-- ============================================
-- 4. COMMENTS TABLE (Threaded)
-- ============================================
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE, -- For threading
    content TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_comment_id);

ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Everyone can read comments
CREATE POLICY "Comments are viewable by everyone" 
    ON comments FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = comments.user_id 
            AND profiles.is_banned = FALSE
        )
    );

-- Users can create comments
CREATE POLICY "Users can create comments" 
    ON comments FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own comments
CREATE POLICY "Users can update own comments" 
    ON comments FOR UPDATE 
    USING (auth.uid() = user_id);

-- Users can delete their own comments
CREATE POLICY "Users can delete own comments" 
    ON comments FOR DELETE 
    USING (auth.uid() = user_id);

-- ============================================
-- 5. FOLLOWERS TABLE
-- ============================================
CREATE TABLE followers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    following_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id) -- Can't follow yourself
);

CREATE INDEX idx_followers_follower_id ON followers(follower_id);
CREATE INDEX idx_followers_following_id ON followers(following_id);

ALTER TABLE followers ENABLE ROW LEVEL SECURITY;

-- Everyone can read followers
CREATE POLICY "Followers are viewable by everyone" 
    ON followers FOR SELECT 
    USING (TRUE);

-- Users can follow others
CREATE POLICY "Users can follow others" 
    ON followers FOR INSERT 
    WITH CHECK (auth.uid() = follower_id);

-- Users can unfollow
CREATE POLICY "Users can unfollow" 
    ON followers FOR DELETE 
    USING (auth.uid() = follower_id);

-- ============================================
-- 6. MESSAGES TABLE (Real-time Chat)
-- ============================================
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    receiver_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Users can read messages they sent or received
CREATE POLICY "Users can read their messages" 
    ON messages FOR SELECT 
    USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Users can send messages
CREATE POLICY "Users can send messages" 
    ON messages FOR INSERT 
    WITH CHECK (auth.uid() = sender_id);

-- Users can update read status
CREATE POLICY "Users can update message status" 
    ON messages FOR UPDATE 
    USING (auth.uid() = receiver_id);

-- ============================================
-- 7. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    actor_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow', 'mention', 'share')),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can read their own notifications
CREATE POLICY "Users can read own notifications" 
    ON notifications FOR SELECT 
    USING (auth.uid() = user_id);

-- System can create notifications (handled by triggers)
CREATE POLICY "Allow notification creation" 
    ON notifications FOR INSERT 
    WITH CHECK (TRUE);

-- Users can update their notification status
CREATE POLICY "Users can update notification status" 
    ON notifications FOR UPDATE 
    USING (auth.uid() = user_id);

-- ============================================
-- 8. APP_SETTINGS TABLE (Dynamic CMS)
-- ============================================
CREATE TABLE app_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default settings
INSERT INTO app_settings (key, value, description) VALUES
    ('app_name_full', 'Community Focused', 'Full application name'),
    ('app_name_short', 'CF', 'Short application name'),
    ('primary_color', '#6366F1', 'Primary brand color (hex)'),
    ('secondary_color', '#8B5CF6', 'Secondary brand color (hex)'),
    ('logo_url', 'https://placeholder.com/logo.png', 'Application logo URL'),
    ('splash_duration', '3000', 'Splash screen duration in milliseconds');

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- Everyone can read app settings
CREATE POLICY "App settings are public" 
    ON app_settings FOR SELECT 
    USING (TRUE);

-- Only authenticated users with admin role can update
-- (Admin authentication handled in application layer)

-- ============================================
-- 9. TRANSLATIONS TABLE (i18n)
-- ============================================
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'lo', -- 'lo' for Lao
    value TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(key, language)
);

-- Insert default Lao translations
INSERT INTO translations (key, language, value) VALUES
    ('welcome', 'lo', 'ຍິນດີຕ້ອນຮັບ'),
    ('login', 'lo', 'ເຂົ້າສູ່ລະບົບ'),
    ('signup', 'lo', 'ລົງທະບຽນ'),
    ('email', 'lo', 'ອີເມວ'),
    ('password', 'lo', 'ລະຫັດຜ່ານ'),
    ('feed', 'lo', 'ຟີດ'),
    ('chat', 'lo', 'ແຊັດ'),
    ('profile', 'lo', 'ໂປຣໄຟລ໌'),
    ('settings', 'lo', 'ການຕັ້ງຄ່າ'),
    ('post', 'lo', 'ໂພສ'),
    ('comment', 'lo', 'ຄໍາເຫັນ'),
    ('like', 'lo', 'ຖືກໃຈ'),
    ('share', 'lo', 'ແບ່ງປັນ'),
    ('follow', 'lo', 'ຕິດຕາມ'),
    ('unfollow', 'lo', 'ຍົກເລີກຕິດຕາມ');

ALTER TABLE translations ENABLE ROW LEVEL SECURITY;

-- Everyone can read translations
CREATE POLICY "Translations are public" 
    ON translations FOR SELECT 
    USING (TRUE);

-- ============================================
-- 10. LAYOUT_CONFIG TABLE (UI Configuration)
-- ============================================
CREATE TABLE layout_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    config JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default layout configurations
INSERT INTO layout_config (key, config) VALUES
    ('feed_layout', '{
        "showReactions": true,
        "showComments": true,
        "showShares": true,
        "postsPerPage": 10
    }'::jsonb),
    ('navigation', '{
        "tabs": ["feed", "chat", "profile", "settings"],
        "showLabels": true
    }'::jsonb);

ALTER TABLE layout_config ENABLE ROW LEVEL SECURITY;

-- Everyone can read layout config
CREATE POLICY "Layout config is public" 
    ON layout_config FOR SELECT 
    USING (TRUE);

-- ============================================
-- 11. ADMIN_USERS TABLE (Secure Admin Access)
-- ============================================
CREATE TABLE admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, -- Bcrypt hash of admin password
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Only the admin user can read their own record
CREATE POLICY "Admin users can read own record" 
    ON admin_users FOR SELECT 
    USING (auth.uid() = user_id);

-- ============================================
-- DATABASE FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to relevant tables
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at 
    BEFORE UPDATE ON posts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at 
    BEFORE UPDATE ON comments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to create notification on like
CREATE OR REPLACE FUNCTION create_like_notification()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, actor_id, type, post_id)
    SELECT posts.user_id, NEW.user_id, 'like', NEW.post_id
    FROM posts
    WHERE posts.id = NEW.post_id
    AND posts.user_id != NEW.user_id; -- Don't notify yourself
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_like_create_notification
    AFTER INSERT ON likes
    FOR EACH ROW EXECUTE FUNCTION create_like_notification();

-- Function to create notification on comment
CREATE OR REPLACE FUNCTION create_comment_notification()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, actor_id, type, post_id, comment_id)
    SELECT posts.user_id, NEW.user_id, 'comment', NEW.post_id, NEW.id
    FROM posts
    WHERE posts.id = NEW.post_id
    AND posts.user_id != NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_comment_create_notification
    AFTER INSERT ON comments
    FOR EACH ROW EXECUTE FUNCTION create_comment_notification();

-- Function to create notification on follow
CREATE OR REPLACE FUNCTION create_follow_notification()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, actor_id, type)
    VALUES (NEW.following_id, NEW.follower_id, 'follow');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_follow_create_notification
    AFTER INSERT ON followers
    FOR EACH ROW EXECUTE FUNCTION create_follow_notification();

-- Function to update post likes count
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_like_update_post_count
    AFTER INSERT OR DELETE ON likes
    FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();

-- Function to update post comments count
CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_comment_update_post_count
    AFTER INSERT OR DELETE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();

-- ============================================
-- STORAGE BUCKETS SETUP
-- ============================================
-- Run these in Supabase Dashboard > Storage

-- Create storage buckets (run in Supabase UI)
-- 1. avatars (public)
-- 2. post_media (public)
-- 3. chat_media (private)

-- Storage policies (add in Supabase UI)
-- Bucket: avatars
--   - Allow authenticated users to upload
--   - Allow everyone to read

-- Bucket: post_media
--   - Allow authenticated users to upload
--   - Allow everyone to read

-- Bucket: chat_media
--   - Allow authenticated users to upload
--   - Allow only participants to read

-- ============================================
-- END OF SCHEMA
-- ============================================
