# ☕ Café Menu System v2 — Supabase + GitHub Pages

A fully persistent, cross-device menu website with CMS admin panel.
Data lives in **Supabase (hosted Postgres)** — survives browser clears, works on any device.

---

## 📁 Folder Structure

```
cafe-menu-v2/
├── config.js               ← Your Supabase credentials (edit this first)
├── index.html              ← Public menu (customers)
├── supabase-setup.sql      ← Run once in Supabase SQL Editor
├── README.md
└── admin/
    └── index.html          ← Admin CMS (PIN-protected)
```

---

## 🚀 Setup in 4 Steps

### Step 1 — Create a Free Supabase Project

1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Choose a region close to you, set a database password
3. Wait ~2 minutes for it to provision

### Step 2 — Run the Database Schema

1. In your Supabase project → **SQL Editor** → **New Query**
2. Paste the entire contents of `supabase-setup.sql`
3. Click **Run** — this creates your tables, RLS policies, and seeds sample data

### Step 3 — Add Your Credentials to config.js

1. In Supabase → **Settings → API**
2. Copy **Project URL** and **anon public** key
3. Open `config.js` and paste them:

```js
const SUPABASE_URL  = 'https://xyzabc.supabase.co';
const SUPABASE_ANON = 'eyJhbGci...';
```

> ⚠️ Use the **anon** key, NOT the `service_role` key.

### Step 4 — Deploy to GitHub Pages

1. Create a new **public** GitHub repo (e.g. `cafe-menu`)
2. Upload all files maintaining this structure:
   ```
   config.js
   index.html
   admin/index.html
   ```
3. Go to repo **Settings → Pages → Deploy from branch: main / root**
4. Your live URLs will be:
   - **Menu**: `https://YOUR_USERNAME.github.io/cafe-menu/`
   - **Admin**: `https://YOUR_USERNAME.github.io/cafe-menu/admin/`

5. In Admin → QR Code panel, paste your GitHub Pages URL to generate a printable QR.

---

## 🔐 Security Guide

### What's protected and how

| Layer | Mechanism |
|-------|-----------|
| Admin access | PIN stored in Supabase `settings` table |
| Brute-force | 5 attempts → 30-second lockout (client-side) |
| Session | `sessionStorage` — clears on tab close |
| DB reads | Supabase Row Level Security — public read allowed (menu is public) |
| DB writes | Supabase RLS — anon key can write (PIN is the frontend gate) |
| XSS | All user content HTML-escaped before rendering |
| HTTPS | GitHub Pages enforces HTTPS automatically |

### ⚠️ Critical: Do These Immediately

1. **Change the default PIN** — Admin → Settings → Security. Default is `1234`.
2. **Rename the admin folder** — before pushing to GitHub, rename `admin/` to something random like `mgmt-x7k2/`. Update the link in `index.html`'s sidebar. This obscures the admin URL.
3. **Never share the admin URL** publicly — post menus and QR codes only.

### Understanding the anon key

The `SUPABASE_ANON` key is **safe to be public** by design — it's the Supabase anon key intended for client-side use. What protects your data is:
- **Row Level Security (RLS)** on all tables
- The current RLS allows public writes (the PIN is your gate)

### For production hardening (optional)

If you want stronger server-side write protection:

**Option A — Restrict writes via RLS to a secret header:**
```sql
-- In Supabase SQL Editor:
DROP POLICY "anon_write_items" ON items;
CREATE POLICY "anon_write_items" ON items FOR ALL
  USING (current_setting('request.headers')::json->>'x-admin-secret' = 'YOUR_SECRET');
```
Then send the header from admin JS on every write.

**Option B — Use Supabase Edge Functions as a proxy:**
Your admin writes go to an Edge Function that checks the PIN server-side before calling the DB.

**Option C — Cloudflare Access (free):**
Put the entire `/admin/` path behind Cloudflare Access — it prompts for a Google/email login before the page even loads.

### What the anon key cannot do

- It cannot bypass RLS policies
- It cannot access other Supabase projects
- It cannot call the Supabase management API
- It cannot read your `service_role` key

---

## 🖼️ Images — Best Practice

Since Supabase stores image URLs (not files), you have two options:

### Option A — External host (recommended)
1. Upload to [imgbb.com](https://imgbb.com) (free, no account needed) or [Cloudinary](https://cloudinary.com) (free 25GB)
2. Copy the direct image URL
3. Paste it into the "Image URL" field in the admin item sheet

### Option B — Base64 upload
- Works for small images (< 300KB)
- Stored as a long base64 string in the database
- Fine for logos; avoid for menu item photos (large)

---

## 🔄 Real-time Updates

The public menu subscribes to Supabase Realtime — when you save a change in admin, the menu page **updates automatically** within seconds on all connected devices, no page refresh needed.

---

## 💾 Backup & Restore

- **Export**: Admin → Settings → Export JSON — downloads a full snapshot
- **Import**: Admin → Settings → Import JSON — replaces all data (with confirmation)
- Supabase also provides automated daily backups on the free tier (last 7 days)

---

## 🛠️ Tech Stack

- Pure HTML / CSS / JavaScript — no build step, no npm
- [Supabase JS v2](https://supabase.com/docs/reference/javascript) via CDN — database client + realtime
- [QRCode.js](https://github.com/davidshimjs/qrcodejs) via CDN — QR generation
- Google Fonts — Cormorant Garamond + DM Sans
- CSS custom properties, Grid, Flexbox, `clamp()` — responsive
- Intersection Observer — scroll animations
- `sessionStorage` — admin session (clears on tab close)

---

## 🧩 Customise the Design

**Change colour palette** — edit CSS variables at the top of `index.html`:
```css
:root {
  --c-gold:    #c9a96e;   /* accent colour */
  --c-bg:      #0e0b08;   /* background    */
  --c-text:    #f0e8d8;   /* body text     */
  --c-surface: #161210;   /* card bg       */
}
```

**Change fonts** — swap the Google Fonts import URL and update the `font-family` declarations.

---

Made with ☕ + Supabase
