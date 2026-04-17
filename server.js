import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';
import { config } from 'dotenv';
// node-fetch is included as a fallback; Node 18+ has native fetch built-in.
// If you're on Node <18, uncomment: import fetch from 'node-fetch';

config();

const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ───────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Serve frontend with env-var injection ────────────────────────────────────
// The index.html contains __SUPABASE_URL__ and __SUPABASE_ANON_KEY__ placeholders.
// The server replaces them at request time so secrets never sit in the static file.
app.get('/', (req, res) => {
  const templatePath = path.join(__dirname, 'public', 'index.html');
  if (!fs.existsSync(templatePath)) {
    return res.status(404).send('Frontend not found. Make sure public/index.html exists.');
  }
  let html = fs.readFileSync(templatePath, 'utf8');

  // Inject env vars as a <script> tag — more reliable than string replacement
  const envScript = `<script>
window.__ENV__ = {
  SUPABASE_URL: ${JSON.stringify(process.env.SUPABASE_URL || '')},
  SUPABASE_ANON_KEY: ${JSON.stringify(process.env.SUPABASE_ANON_KEY || '')}
};
</script>`;
  html = html.replace('</head>', envScript + '\n</head>');

  // Also do the original placeholder replacement as a fallback
  html = html
    .replace(/__SUPABASE_URL__/g,      process.env.SUPABASE_URL      || '')
    .replace(/__SUPABASE_ANON_KEY__/g, process.env.SUPABASE_ANON_KEY || '');

  res.send(html);
});

// Serve other static assets (CSS, images, etc.) from public/
app.use(express.static(path.join(__dirname, 'public'), {
  index: false  // prevent express from auto-serving index.html — we handle that above
}));

// ── Health check ─────────────────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({
    status : 'ok',
    supabase: !!process.env.SUPABASE_URL,
    claude  : !!process.env.CLAUDE_API_KEY
  });
});

// ── Public config (safe to expose — anon key only) ────────────────────────────
app.get('/api/config', (req, res) => {
  res.json({
    supabaseUrl:     process.env.SUPABASE_URL      || '',
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY || ''
  });
});

// ── Claude API Proxy ─────────────────────────────────────────────────────────
// Keeps your Claude API key server-side only — never exposed to the browser.
app.post('/api/search-recipes', async (req, res) => {
  const { dishName, category, userMacros } = req.body;

  if (!dishName || !category) {
    return res.status(400).json({ error: 'dishName and category are required.' });
  }

  const CLAUDE_API_KEY = process.env.CLAUDE_API_KEY;
  if (!CLAUDE_API_KEY) {
    return res.status(500).json({ error: 'CLAUDE_API_KEY is not configured on the server.' });
  }

  const categoryLabels = {
    breakfast    : 'Breakfast',
    lunch_dinner : 'Lunch or Dinner',
    snacks       : 'Snack (under 250 cal)',
    gummies      : 'Protein Gummy / Supplement'
  };
  const label = categoryLabels[category] || 'Meal';

  const macroContext = userMacros
    ? `The user's daily targets are ${userMacros.calories} cal | ${userMacros.protein_g}g protein | ${userMacros.carbs_g}g carbs | ${userMacros.fat_g}g fat.
       Size the ${label} as an appropriate fraction of those totals.`
    : `Aim for high protein (≥25g if a main meal, ≥8g if a snack) and moderate calories for a ${label}.`;

  const prompt = `You are a professional nutritionist and chef. A user wants to add "${dishName}" as a ${label} to their high-protein, low-starch-carb meal plan.

${macroContext}

Provide exactly 5 distinct recipe variations for "${dishName}" that:
- Fit the ${label} category
- Emphasise whole foods and high protein
- Minimise added starchy carbohydrates (rice, bread, pasta) unless it is a Gummy category

Return ONLY a valid JSON array — no markdown fences, no commentary, just the raw JSON.
Each element must contain exactly these keys:
{
  "name": "Full descriptive recipe name",
  "calories": <integer per serving>,
  "protein_g": <number per serving>,
  "carbs_g": <number per serving>,
  "fat_g": <number per serving>,
  "servings": <integer the recipe makes>,
  "ingredients": ["amount + ingredient", "..."],
  "instructions": ["Step 1 …", "Step 2 …"],
  "notes": "One-sentence prep tip or nutrition highlight"
}`;

  try {
    // Uses Node 18+ native fetch (or node-fetch if imported above)
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method : 'POST',
      headers: {
        'Content-Type'      : 'application/json',
        'x-api-key'         : CLAUDE_API_KEY,
        'anthropic-version' : '2023-06-01'
      },
      body: JSON.stringify({
        model      : 'claude-haiku-4-5-20251001',
        max_tokens : 4096,
        messages   : [{ role: 'user', content: prompt }]
      })
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('Claude API error:', errText);
      return res.status(502).json({ error: 'Claude API returned an error. Check your API key and quota.' });
    }

    const data    = await response.json();
    const content = data.content?.[0]?.text || '[]';

    let recipes;
    try {
      recipes = JSON.parse(content);
    } catch {
      // Try to extract JSON array if model wrapped it
      const match = content.match(/\[[\s\S]*\]/);
      recipes = match ? JSON.parse(match[0]) : [];
    }

    res.json({ recipes });
  } catch (err) {
    console.error('Search recipes error:', err);
    res.status(500).json({ error: 'Internal server error while contacting Claude.' });
  }
});

// ── Restaurant Menu Search ────────────────────────────────────────────────────
app.post('/api/restaurant-search', async (req, res) => {
  const { query, category, userMacros } = req.body;
  if (!query) return res.status(400).json({ error: 'query is required.' });

  const CLAUDE_API_KEY = process.env.CLAUDE_API_KEY;
  if (!CLAUDE_API_KEY) return res.status(500).json({ error: 'CLAUDE_API_KEY not configured.' });

  const macroContext = userMacros
    ? `The user's daily targets are ${userMacros.calories} cal | ${userMacros.protein_g}g protein | ${userMacros.carbs_g}g carbs | ${userMacros.fat_g}g fat. Size items as an appropriate fraction of those totals.`
    : `The user is focused on high protein (≥25g per main meal, ≥8g per snack) and low starchy carbs.`;

  const prompt = `You are a nutrition expert with deep knowledge of restaurant menus and their nutritional content.

The user is searching for: "${query}"
Meal category: ${category || 'any'}
${macroContext}

Your task:
1. Identify the restaurant from the query (it may be just a restaurant name like "Chipotle", or a specific dish like "McDonald's Big Mac", or "Starbucks breakfast").
2. Return real menu items that match or are closely related to the search.
3. Return better alternatives from the SAME restaurant that are more aligned with the user's high-protein, lower-carb goals.

Use your knowledge of real published nutritional data from these restaurants. Be accurate with calories and macros.

Return ONLY valid JSON in this exact shape — no markdown, no commentary:
{
  "restaurant": "Restaurant Name",
  "matches": [
    {
      "name": "Exact menu item name",
      "calories": <integer>,
      "protein_g": <number>,
      "carbs_g": <number>,
      "fat_g": <number>,
      "servings": 1,
      "category": "${category || 'lunch_dinner'}",
      "notes": "Brief nutrition note"
    }
  ],
  "better": [
    {
      "name": "Better menu item name",
      "calories": <integer>,
      "protein_g": <number>,
      "carbs_g": <number>,
      "fat_g": <number>,
      "servings": 1,
      "category": "${category || 'lunch_dinner'}",
      "why": "One sentence on why this is a better choice for the user's goals",
      "notes": "Brief nutrition note"
    }
  ]
}

Return 3–5 matches and 3–5 better alternatives. If the restaurant is not found or the query is ambiguous, make your best inference.`;

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': CLAUDE_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 4096,
        messages: [{ role: 'user', content: prompt }]
      })
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('Claude API error:', errText);
      return res.status(502).json({ error: 'Claude API returned an error.' });
    }

    const data    = await response.json();
    const content = data.content?.[0]?.text || '{}';

    let result;
    try {
      result = JSON.parse(content);
    } catch {
      const match = content.match(/\{[\s\S]*\}/);
      result = match ? JSON.parse(match[0]) : { matches: [], better: [] };
    }

    res.json(result);
  } catch (err) {
    console.error('Restaurant search error:', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// ── SPA fallback (all other routes → index) ──────────────────────────────────
app.get('*', (req, res) => {
  const templatePath = path.join(__dirname, 'public', 'index.html');
  if (!fs.existsSync(templatePath)) {
    return res.status(404).send('Not found.');
  }
  let html = fs.readFileSync(templatePath, 'utf8');

  const envScript = `<script>
window.__ENV__ = {
  SUPABASE_URL: ${JSON.stringify(process.env.SUPABASE_URL || '')},
  SUPABASE_ANON_KEY: ${JSON.stringify(process.env.SUPABASE_ANON_KEY || '')}
};
</script>`;
  html = html.replace('</head>', envScript + '\n</head>');
  html = html
    .replace(/__SUPABASE_URL__/g,      process.env.SUPABASE_URL      || '')
    .replace(/__SUPABASE_ANON_KEY__/g, process.env.SUPABASE_ANON_KEY || '');
  res.send(html);
});

// ── Start ────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n✅  Meal Planner running → http://localhost:${PORT}`);
  console.log(`   Supabase : ${process.env.SUPABASE_URL ? '✓ configured' : '✗ missing SUPABASE_URL'}`);
  console.log(`   Claude   : ${process.env.CLAUDE_API_KEY ? '✓ configured' : '✗ missing CLAUDE_API_KEY'}\n`);
});
