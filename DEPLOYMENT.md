# Nourish — Complete Beginner Deployment Guide
## No technical experience needed — follow every step exactly as written

**Total time:** About 45–60 minutes
**What you'll need:** A computer, a web browser, and your email address

---

## Before You Start — What You're About to Do

You're going to:
1. Create 4 free accounts (takes ~15 minutes)
2. Set up your database on Supabase (stores your recipes and meal plans)
3. Upload your project files to GitHub (free cloud storage for code)
4. Deploy your app on Render (makes it live on the internet)

**You do NOT need to know how to code.** Just follow each step exactly.

---

# PHASE 1 — Create Your 4 Free Accounts

---

## Account 1 — Anthropic (for Claude AI)

This is what powers the "Find 5 Recipes with AI" feature.

**Steps:**

1. Open a new browser tab and go to: **https://console.anthropic.com**
2. Click the blue button that says **"Sign up"**
3. Enter your email address and click **"Continue"**
4. Enter a password (at least 8 characters) and click **"Continue"**
5. Check your email inbox — you'll get a verification email from Anthropic
6. Click the **"Verify email"** button in that email
7. You'll be taken back to Anthropic's website — you may need to log in
8. After logging in, you'll see a dashboard. Look for a box that says **"Claim your free credits"** or it may show you a welcome screen — click through it
9. In the left sidebar, click **"API Keys"**
10. Click the button that says **"Create Key"**
11. In the box that appears, type a name like: `nourish-app`
12. Click **"Create Key"**
13. A long code will appear on screen — it starts with `sk-ant-api`
14. **IMPORTANT:** Click the copy button next to it (or highlight it all and press Ctrl+C on Windows / Cmd+C on Mac)
15. Open Notepad (Windows) or TextEdit (Mac) and paste it there temporarily — you'll need it later
16. Click **"Done"** or close the box

> ✅ You now have your Claude API key saved in Notepad.

---

## Account 2 — GitHub (stores your code files)

**Steps:**

1. Open a new browser tab and go to: **https://github.com**
2. Click **"Sign up"** in the top right corner
3. Enter your email address and click **"Continue"**
4. Create a password and click **"Continue"**
5. Choose a username (e.g., `divuleader` or anything you like) and click **"Continue"**
6. Answer the "Are you human?" puzzle
7. Click **"Create account"**
8. Check your email — GitHub will send you a 6-digit launch code
9. Enter that code on the GitHub website
10. On the "Welcome to GitHub" screen, click **"Skip personalization"** at the bottom (or answer the questions if you prefer)
11. You should now see your GitHub dashboard — it will mostly be empty, that's fine

> ✅ GitHub account created.

---

## Account 3 — Supabase (your database)

**Steps:**

1. Open a new browser tab and go to: **https://supabase.com**
2. Click **"Start your project"** (green button)
3. Click **"Continue with GitHub"**
4. A window may pop up asking you to authorize Supabase — click **"Authorize supabase"**
5. You'll be taken to your Supabase dashboard
6. Click the green button **"New project"**
7. You'll see a form — fill it in like this:
   - **Organization:** It should already show your name — leave it as-is
   - **Name:** Type `nourish-meal-planner`
   - **Database Password:** Click **"Generate a password"** — a random password will appear. Click the copy icon and paste it into your Notepad document (you might need it later if anything goes wrong)
   - **Region:** Click the dropdown and choose the region closest to where you live (e.g., if you're in the US East, choose "US East")
   - **Pricing Plan:** Make sure **"Free"** is selected
8. Click **"Create new project"**
9. You'll see a loading screen that says "Setting up your project" — this takes about 1–2 minutes. Just wait.
10. Once it finishes, you'll see your project dashboard

> ✅ Supabase project created. Do NOT close this tab — you need it in Phase 2.

---

## Account 4 — Render (makes your app live on the internet)

**Steps:**

1. Open a new browser tab and go to: **https://render.com**
2. Click **"Get Started for Free"**
3. Click **"GitHub"** to sign up with your GitHub account
4. Click **"Authorize Render"** in the popup
5. You'll be taken to your Render dashboard — it will be mostly empty

> ✅ Render account created.

---

# PHASE 2 — Set Up Your Database (Supabase)

This creates all the tables that will store your recipes, meal plans, and profile.

---

## Step 2A — Run the Database Setup Script

1. Go back to your **Supabase browser tab** (from Phase 1, Account 3)
2. Look at the left sidebar — find and click **"SQL Editor"** (it has a code icon that looks like `</>`)
3. Click the button **"New query"** (usually in the top left of the SQL editor area)
4. A large blank text area will appear
5. Now you need to open your project folder on your computer:
   - On **Mac:** Open Finder, go to your "Meal Planner" folder
   - On **Windows:** Open File Explorer, go to your "Meal Planner" folder
6. Find the file called **`supabase-schema.sql`** and open it with a text editor:
   - **Mac:** Right-click it → Open With → TextEdit
   - **Windows:** Right-click it → Open With → Notepad
7. You'll see a lot of text — press **Ctrl+A** (Windows) or **Cmd+A** (Mac) to select ALL of it
8. Press **Ctrl+C** (Windows) or **Cmd+C** (Mac) to copy it
9. Go back to your Supabase browser tab
10. Click inside the big blank text area in the SQL Editor
11. Press **Ctrl+A** to select any existing text, then press **Delete** to clear it
12. Press **Ctrl+V** (Windows) or **Cmd+V** (Mac) to paste
13. You should now see a LOT of text in the SQL editor
14. Click the green **"Run"** button (it may also say **"RUN"** with a play icon ▶)
15. Wait a few seconds
16. At the bottom of the screen, you should see a green checkmark or message saying **"Success"**

> If you see a red error message, don't panic. Check that you copied ALL the text from the file and try again.

## Step 2B — Verify Your Tables Were Created

1. In the left sidebar, click **"Table Editor"** (it looks like a grid/table icon)
2. You should see 3 tables listed: `dishes`, `meal_plans`, and `profiles`
3. Click on **"dishes"** — you should see rows of data (your recipes are already loaded!)
4. If you see the tables, everything worked correctly ✅

## Step 2C — Copy Your Supabase Keys

You need two pieces of information from Supabase.

1. In the left sidebar, click the **gear icon ⚙️** at the very bottom (Settings)
2. Click **"API"** in the settings menu
3. You'll see two things you need — copy each one to your Notepad:

   **Key 1 — Project URL:**
   - Look for **"Project URL"**
   - It looks like: `https://abcdefghijk.supabase.co`
   - Click the copy icon next to it and paste it into your Notepad

   **Key 2 — Anon Public Key:**
   - Look for **"Project API keys"** section
   - Find **"anon" "public"**
   - It's a very long string starting with `eyJhb...`
   - Click the copy icon next to it and paste it into your Notepad

> Your Notepad should now have 3 things saved:
> - Your Claude API key (from Phase 1)
> - Your Supabase URL
> - Your Supabase Anon Key

---

# PHASE 3 — Create the .env File (Your Secret Keys File)

This file tells your app where to find Supabase and Claude. It stays on your computer and is NEVER shared.

**Steps:**

1. Open your **Meal Planner** project folder on your computer
2. Find the file called **`.env.example`**
   - **Note for Windows users:** This file starts with a dot. If you can't see it, open File Explorer → click "View" at the top → check "Hidden items"
   - **Note for Mac users:** Press Cmd+Shift+. (period) to show hidden files in Finder
3. **Make a copy of this file:**
   - Right-click it → Copy
   - Right-click in the same folder → Paste
   - You'll get a file called **`.env.example copy`** (Mac) or **`.env.example - Copy`** (Windows)
4. **Rename the copy to just `.env`** (remove "example copy" or "example - Copy"):
   - Right-click the copy → Rename
   - Delete everything and type: `.env`
   - Press Enter
   - If it asks "Are you sure you want to change the extension?" — click Yes
5. Now **open the `.env` file** with a text editor:
   - **Mac:** Right-click → Open With → TextEdit
   - **Windows:** Right-click → Open With → Notepad
6. You'll see something like this:
   ```
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-public-key-here
   CLAUDE_API_KEY=sk-ant-your-key-here
   PORT=3000
   ```
7. Replace each placeholder with your real values from your Notepad:
   - Replace `https://your-project-id.supabase.co` with your **Supabase URL**
   - Replace `your-anon-public-key-here` with your **Supabase Anon Key**
   - Replace `sk-ant-your-key-here` with your **Claude API Key**
   - Leave `PORT=3000` exactly as it is
8. **Save the file** (Ctrl+S on Windows, Cmd+S on Mac)
9. Close the text editor

> ✅ Your .env file is ready. This file is listed in .gitignore so it will NEVER accidentally get uploaded to GitHub — your keys stay private.

---

# PHASE 4 — Upload Your Files to GitHub

You need a free app called **GitHub Desktop** — it's the easiest way to upload your project without using any command line.

---

## Step 4A — Install GitHub Desktop

1. Go to: **https://desktop.github.com**
2. Click the purple **"Download for macOS"** or **"Download for Windows"** button
3. Once downloaded:
   - **Mac:** Open the .dmg file, drag GitHub Desktop to your Applications folder, then open it from Applications
   - **Windows:** Run the .exe installer file, it installs automatically and opens
4. When GitHub Desktop opens, click **"Sign in to GitHub.com"**
5. Click **"Continue with browser"** — your browser will open
6. Click **"Authorize desktop"**
7. It will ask to open GitHub Desktop — click **"Open GitHub Desktop"** (or "Allow")
8. Back in GitHub Desktop, fill in:
   - **Name:** Your real name (or any name)
   - **Email:** Your email address
9. Click **"Finish"**

---

## Step 4B — Create a New Repository

1. In GitHub Desktop, click **"Create a New Repository on your hard drive..."**
   (Or go to: File menu → New Repository)
2. Fill in the form:
   - **Name:** `nourish-meal-planner`
   - **Description:** `My personal AI meal planner`
   - **Local Path:** Click **"Choose..."** and navigate to the PARENT folder that CONTAINS your "Meal Planner" folder. For example, if your files are in `Documents/Meal Planner/`, click on `Documents`
   - **Initialize this repository with a README:** Uncheck this box
   - **Git Ignore:** None
   - **License:** None
3. Click **"Create Repository"**

---

## Step 4C — Move Your Files Into the Repository Folder

1. GitHub Desktop will show you an empty repository
2. Click **"Show in Finder"** (Mac) or **"Show in Explorer"** (Windows) — this opens the folder GitHub just created, which will be at something like `Documents/nourish-meal-planner/`
3. Now open a **second Finder/Explorer window** and navigate to your original **"Meal Planner"** folder
4. Select ALL the files and folders inside "Meal Planner":
   - Press **Ctrl+A** (Windows) or **Cmd+A** (Mac) to select everything
5. Copy them: **Ctrl+C** (Windows) or **Cmd+C** (Mac)
6. Switch to the first window (the GitHub repo folder `nourish-meal-planner`)
7. Paste them: **Ctrl+V** (Windows) or **Cmd+V** (Mac)
8. All your files should now be inside the `nourish-meal-planner` folder

> Your `nourish-meal-planner` folder should now contain:
> `.env`, `.env.example`, `.gitignore`, `DEPLOYMENT.md`, `package.json`, `server.js`, `supabase-schema.sql`, and a `public` folder (containing `index.html`)

---

## Step 4D — Commit and Publish Your Files

1. Go back to **GitHub Desktop**
2. It should now show a list of files on the left side — these are all your new files
3. At the bottom left, there's a box — fill it in:
   - **Summary (required):** Type `Initial commit — Nourish meal planner`
   - **Description:** Leave blank
4. Click the blue button **"Commit to main"**
5. Now click **"Publish repository"** (blue button in the top center)
6. A dialog box appears:
   - **Name:** Leave as `nourish-meal-planner`
   - **Description:** Leave blank or add something
   - **Keep this code private:** Check this box ✓ (keeps your code private)
   - **Organization:** Leave as "None"
7. Click **"Publish Repository"**
8. Wait 10–30 seconds while it uploads

> ✅ Your code is now on GitHub! You can verify by going to github.com, logging in, clicking your profile icon → "Your repositories" — you should see `nourish-meal-planner`.

---

# PHASE 5 — Deploy to Render (Make It Live)

---

## Step 5A — Create the Web Service

1. Go to your **Render** browser tab (from Phase 1, Account 4), or go to **https://dashboard.render.com**
2. Click the **"New +"** button (top right of the dashboard)
3. Select **"Web Service"** from the dropdown menu
4. You'll see "Connect a repository" — click **"Connect account"** next to GitHub
5. A popup will appear asking you to connect GitHub — click **"Install"** or **"Configure"**
6. On the GitHub authorization page, select **"All repositories"** (or find `nourish-meal-planner` specifically) and click **"Install & Authorize"**
7. Back on Render, you should now see your repository `nourish-meal-planner` in the list
8. Click **"Connect"** next to `nourish-meal-planner`

---

## Step 5B — Configure the Service

You'll now see a settings page. Fill in these fields exactly:

| Setting | What to type |
|---------|-------------|
| **Name** | `nourish-meal-planner` |
| **Region** | Choose the one closest to you |
| **Branch** | `main` |
| **Runtime** | `Node` (should auto-detect) |
| **Build Command** | `npm install` |
| **Start Command** | `node server.js` |
| **Instance Type** | Click **"Free"** |

Scroll down until you see **"Environment Variables"**

---

## Step 5C — Add Your Secret Keys to Render

This is the most important step. You're giving Render your private keys so the app can connect to Supabase and Claude.

1. Under "Environment Variables", click **"Add Environment Variable"**
2. Add the first variable:
   - **Key:** `SUPABASE_URL`
   - **Value:** Paste your Supabase URL from your Notepad (e.g., `https://abcdefgh.supabase.co`)
   - Click the **+** button or press Enter to add it

3. Click **"Add Environment Variable"** again:
   - **Key:** `SUPABASE_ANON_KEY`
   - **Value:** Paste your long Supabase anon key from your Notepad (starts with `eyJh...`)
   - Add it

4. Click **"Add Environment Variable"** again:
   - **Key:** `CLAUDE_API_KEY`
   - **Value:** Paste your Claude API key from your Notepad (starts with `sk-ant-...`)
   - Add it

> Double-check: you should have exactly 3 environment variables added.

---

## Step 5D — Deploy!

1. Scroll to the bottom of the page
2. Click the big blue **"Create Web Service"** button
3. Render will start deploying your app — you'll see a logs screen with text scrolling
4. This takes **3–7 minutes** the first time — just wait and watch the logs
5. You're looking for a line that says something like:
   ```
   ✅  Meal Planner running → http://localhost:10000
      Supabase : ✓ configured
      Claude   : ✓ configured
   ```
6. Once you see that, look at the **top of the page** — there will be a link that looks like:
   `https://nourish-meal-planner.onrender.com`
   (the exact name may be slightly different)
7. **Click that link!** Your app is now live on the internet! 🎉

---

# PHASE 6 — First Time Setup in Your App

Now that it's live, do this once to personalise it:

1. **Go to "My Profile"** tab at the top of your app
2. Fill in your name, age, sex, weight, and height
3. Select your activity level and goal
4. Click **"Calculate & Save My Macros ✨"**
5. You'll see your personalised daily targets appear

6. **Go to "Library"** — you'll see all 36 recipes already loaded ✅

7. **Try the AI feature:**
   - Click **"✨ Add Dish"** in the nav
   - Type a dish name, e.g., `Salmon Bowl`
   - Select a category
   - Click **"Find 5 Recipes with Claude AI"**
   - After 5–10 seconds, 5 recipes appear
   - Click **"Preview ▼"** to see ingredients and steps
   - Click **"+ Add"** to save it to your library

8. **Build a meal plan:**
   - Click **"Meal Plan"**
   - Click **"+ Add"** next to "Breakfast"
   - Search for a recipe and click it to select it
   - Click **"Add to Plan"**
   - Watch your macro bars update in real time!

---

# Troubleshooting — Common Issues

---

**The app shows "Almost ready!" instead of loading**

Your environment variables weren't saved correctly. To fix:
1. Go to dashboard.render.com
2. Click on your `nourish-meal-planner` service
3. Click **"Environment"** in the left sidebar
4. Check that all 3 variables are there and have correct values
5. If you need to change one, click the edit (pencil) icon
6. After saving changes, click **"Manual Deploy"** → **"Deploy latest commit"**

---

**The app loads but the Library is empty**

The database setup SQL didn't run properly. To fix:
1. Go back to your Supabase project
2. Click **"SQL Editor"** → **"New query"**
3. Re-paste ALL the content from `supabase-schema.sql`
4. Click **"Run"**

---

**Claude AI search gives an error**

Your Claude API key might be wrong. To check:
1. Go to console.anthropic.com and log in
2. Click **"API Keys"** — make sure your key is active (green dot)
3. If the key was deleted or expired, create a new one
4. Update the `CLAUDE_API_KEY` in your Render environment variables

---

**The app takes 30 seconds to load sometimes**

This is normal! Render's free tier "sleeps" your app when nobody has used it for 15 minutes. The first visit after sleeping takes about 30 seconds to "wake up." After that first load, it's fast.

To fix this permanently (optional):
1. Go to **https://uptimerobot.com** — it's free
2. Create an account
3. Add a new monitor:
   - **Monitor Type:** HTTP(s)
   - **Friendly Name:** `Nourish App`
   - **URL:** Your Render URL (e.g., `https://nourish-meal-planner.onrender.com/api/health`)
   - **Monitoring Interval:** 5 minutes
4. Click **"Create Monitor"**
5. UptimeRobot will ping your app every 5 minutes, keeping it awake

---

# Updating Your App in the Future

If you ever want to make a change:

1. Edit the files on your computer
2. Open **GitHub Desktop**
3. You'll see the changed files listed
4. Type a short summary in the bottom-left box (e.g., "Updated styling")
5. Click **"Commit to main"**
6. Click **"Push origin"**
7. Render automatically detects the change and re-deploys (takes 2–3 minutes)

---

# Summary — Your 3 Keys (Save These Safely!)

After completing this guide, you should have saved:

| Key | Where it came from | Looks like |
|-----|-------------------|------------|
| Supabase URL | Supabase → Settings → API | `https://abc123.supabase.co` |
| Supabase Anon Key | Supabase → Settings → API | `eyJhbGciOiJIUzI1...` (very long) |
| Claude API Key | console.anthropic.com → API Keys | `sk-ant-api03-...` |

**Store these somewhere safe** (like a password manager or a private note) — if you ever need to redeploy or update your Render settings, you'll need them again.

---

*Your Nourish meal planner is now live! ☕*
*If you get stuck on any step, the key pieces of information you need are always in your Supabase settings (the URL and anon key) and in your Anthropic console (the API key).*
