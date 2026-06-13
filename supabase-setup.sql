-- ============================================================
-- CAFÉ MENU SYSTEM — Supabase Schema
-- Run this entire file in: Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- 1. SETTINGS (single-row table for café info)
CREATE TABLE IF NOT EXISTS settings (
  id          SERIAL PRIMARY KEY,
  key         TEXT UNIQUE NOT NULL,
  value       TEXT NOT NULL DEFAULT '',
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CATEGORIES
CREATE TABLE IF NOT EXISTS categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  emoji       TEXT DEFAULT '',
  sort_order  INTEGER DEFAULT 1,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 3. MENU ITEMS
CREATE TABLE IF NOT EXISTS items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name        TEXT NOT NULL,
  description TEXT DEFAULT '',
  price       NUMERIC(10,2) NOT NULL DEFAULT 0,
  emoji       TEXT DEFAULT '🍽️',
  image_url   TEXT DEFAULT '',
  badges      TEXT[] DEFAULT '{}',
  tags        TEXT[] DEFAULT '{}',
  calories    TEXT DEFAULT '',
  allergens   TEXT DEFAULT '',
  prep_time   TEXT DEFAULT '',
  available   BOOLEAN DEFAULT TRUE,
  sort_order  INTEGER DEFAULT 1,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY — Allow public reads, restrict writes
-- ============================================================

ALTER TABLE settings   ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE items       ENABLE ROW LEVEL SECURITY;

-- Public can READ everything (the menu site is public)
CREATE POLICY "public_read_settings"
  ON settings FOR SELECT USING (true);

CREATE POLICY "public_read_categories"
  ON categories FOR SELECT USING (true);

CREATE POLICY "public_read_items"
  ON items FOR SELECT USING (true);

-- Anyone can INSERT/UPDATE/DELETE (PIN protection is in the frontend)
-- For stronger security, replace anon key with a service role key
-- stored only on a backend proxy — see README security notes.
CREATE POLICY "anon_write_settings"
  ON settings FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "anon_write_categories"
  ON categories FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "anon_write_items"
  ON items FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- SEED DEFAULT DATA
-- ============================================================

-- Settings
INSERT INTO settings (key, value) VALUES
  ('cafe_name',    'Maison Dorée'),
  ('cafe_tagline', 'est. 2018 · Fine dining & café'),
  ('cafe_logo',    ''),
  ('footer_text',  'Open daily · 8am – 10pm'),
  ('admin_pin',    '1234')
ON CONFLICT (key) DO NOTHING;

-- Categories
INSERT INTO categories (id, name, emoji, sort_order) VALUES
  ('11111111-1111-1111-1111-111111111101', 'Breakfast', '🌅', 1),
  ('11111111-1111-1111-1111-111111111102', 'Mains',     '🍽️', 2),
  ('11111111-1111-1111-1111-111111111103', 'Desserts',  '🍮', 3),
  ('11111111-1111-1111-1111-111111111104', 'Drinks',    '☕', 4)
ON CONFLICT (id) DO NOTHING;

-- Items
INSERT INTO items (category_id, name, description, price, emoji, badges, tags, calories, allergens, prep_time, available, sort_order) VALUES
  ('11111111-1111-1111-1111-111111111101', 'Shakshuka',        'Slow-simmered tomato and pepper sauce with poached eggs, crumbled feta, and fresh herbs. Served with warm sourdough.',         14.00, '🍳', ARRAY['popular','veg'], ARRAY['eggs','gluten-free bread avail.'], '420 kcal', 'Eggs, Dairy',  '15 min', true, 1),
  ('11111111-1111-1111-1111-111111111101', 'Avocado Toast',    'Stone-ground sourdough, smashed hass avocado, lemon zest, chilli flakes, everything bagel seasoning.',                        12.50, '🥑', ARRAY['veg'],           ARRAY['vegan option','add egg +2'],    '380 kcal', 'Gluten',       '10 min', true, 2),
  ('11111111-1111-1111-1111-111111111102', 'Pan-Seared Salmon','Atlantic salmon fillet, herb butter, caperberries, wilted spinach, and lemon-dill crème fraîche.',                            28.00, '🐟', ARRAY['popular'],        ARRAY['gluten-free','pescatarian'],    '560 kcal', 'Fish, Dairy',  '20 min', true, 1),
  ('11111111-1111-1111-1111-111111111102', 'Truffle Risotto',  'Arborio rice, black truffle shavings, parmesan, white wine reduction, fresh chives.',                                         24.00, '🍚', ARRAY['new','veg'],      ARRAY['vegetarian','gf'],             '640 kcal', 'Dairy',        '25 min', true, 2),
  ('11111111-1111-1111-1111-111111111103', 'Crème Brûlée',     'Classic vanilla bean custard with a crisp caramelised sugar crust. Served with fresh berries.',                               9.00,  '🍮', ARRAY['popular'],        ARRAY['gluten-free'],                 '320 kcal', 'Eggs, Dairy',  '10 min', true, 1),
  ('11111111-1111-1111-1111-111111111104', 'Pour-Over Coffee', 'Single-origin Ethiopian Yirgacheffe, medium roast, floral and citrus notes.',                                                  5.50,  '☕', ARRAY[]::TEXT[],         ARRAY['vegan','hot/iced'],            '5 kcal',   'None',         '5 min',  true, 1);

-- ============================================================
-- SUPABASE STORAGE — Bucket for menu images
-- ============================================================

-- Create a public storage bucket for menu item images
INSERT INTO storage.buckets (id, name, public)
VALUES ('menu-images', 'menu-images', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public (anon) to read/select files
CREATE POLICY "anon_select_menu_images"
  ON storage.objects FOR SELECT
  TO anon
  USING (bucket_id = 'menu-images');

-- Allow anon to upload files
CREATE POLICY "anon_insert_menu_images"
  ON storage.objects FOR INSERT
  TO anon
  WITH CHECK (bucket_id = 'menu-images');

-- Allow anon to update files
CREATE POLICY "anon_update_menu_images"
  ON storage.objects FOR UPDATE
  TO anon
  USING (bucket_id = 'menu-images')
  WITH CHECK (bucket_id = 'menu-images');

-- Allow anon to delete files
CREATE POLICY "anon_delete_menu_images"
  ON storage.objects FOR DELETE
  TO anon
  USING (bucket_id = 'menu-images');

-- ============================================================
-- ARABIC LANGUAGE SUPPORT — Add Arabic name columns
-- ============================================================

ALTER TABLE items ADD COLUMN IF NOT EXISTS name_ar TEXT DEFAULT '';
ALTER TABLE items ADD COLUMN IF NOT EXISTS description_ar TEXT DEFAULT '';
ALTER TABLE categories ADD COLUMN IF NOT EXISTS name_ar TEXT DEFAULT '';

-- ============================================================
-- DONE. Now grab your Project URL + anon key from:
-- Supabase Dashboard → Settings → API
-- and paste them into config.js
-- ============================================================
