-- ═══════════════════════════════════════════════════════════════════════════════
--  MEAL PLANNER — Auth Migration
--  Run this in: Supabase Dashboard → SQL Editor → New Query → Run
--  This upgrades the schema to support multiple authenticated users.
-- ═══════════════════════════════════════════════════════════════════════════════


-- ── 1. Drop existing tables ───────────────────────────────────────────────────
DROP TABLE IF EXISTS meal_plans CASCADE;
DROP TABLE IF EXISTS dishes     CASCADE;
DROP TABLE IF EXISTS profiles   CASCADE;


-- ── 2. Profiles (one per auth user) ──────────────────────────────────────────
CREATE TABLE profiles (
  id             UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID    UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name           TEXT,
  age            INTEGER,
  sex            TEXT    CHECK (sex IN ('male','female')),
  weight_lbs     NUMERIC(6,1),
  height_ft      INTEGER,
  height_in      INTEGER,
  activity_level   TEXT    CHECK (activity_level IN ('sedentary','light','moderate','active','very_active')),
  goal             TEXT,   -- comma-separated, e.g. 'lose,muscle' or 'maintain'
  goal_weight_lbs  NUMERIC(6,1),
  daily_calories   INTEGER,
  daily_protein_g  INTEGER,
  daily_carbs_g    INTEGER,
  daily_fat_g      INTEGER,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own profile" ON profiles FOR ALL
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);


-- ── 3. Dishes (NULL user_id = global seed data, visible to all) ──────────────
CREATE TABLE dishes (
  id           UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID    REFERENCES auth.users(id) ON DELETE CASCADE,  -- NULL = global
  name         TEXT    NOT NULL,
  category     TEXT    NOT NULL CHECK (category IN ('breakfast','lunch_dinner','snacks','gummies')),
  calories     INTEGER NOT NULL,
  protein_g    NUMERIC(6,1) NOT NULL,
  carbs_g      NUMERIC(6,1),
  fat_g        NUMERIC(6,1),
  servings     INTEGER DEFAULT 1,
  ingredients  TEXT[],
  instructions TEXT[],
  notes        TEXT,
  source       TEXT    DEFAULT 'manual',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE dishes ENABLE ROW LEVEL SECURITY;

-- Anyone can read global dishes (user_id IS NULL) or their own
CREATE POLICY "Read global and own dishes" ON dishes FOR SELECT
  USING (user_id IS NULL OR auth.uid() = user_id);

-- Users can only insert/update/delete their own dishes
CREATE POLICY "Manage own dishes" ON dishes FOR INSERT
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Update own dishes" ON dishes FOR UPDATE
  USING (auth.uid() = user_id);
CREATE POLICY "Delete own dishes" ON dishes FOR DELETE
  USING (auth.uid() = user_id);


-- ── 4. Meal Plans (always user-scoped) ───────────────────────────────────────
CREATE TABLE meal_plans (
  id             UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID    NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_date      DATE    NOT NULL DEFAULT CURRENT_DATE,
  dish_id        UUID    REFERENCES dishes(id) ON DELETE CASCADE,
  meal_slot      TEXT    NOT NULL
                         CHECK (meal_slot IN ('breakfast','lunch','dinner','snack_1','snack_2','supplement')),
  servings_count NUMERIC(4,1) DEFAULT 1,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own meals" ON meal_plans FOR ALL
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_meal_plans_date    ON meal_plans(plan_date);
CREATE INDEX IF NOT EXISTS idx_meal_plans_user    ON meal_plans(user_id);


-- ═══════════════════════════════════════════════════════════════════════════════
--  GLOBAL SEED DISHES (user_id = NULL — visible to all users)
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO dishes (name, category, calories, protein_g, carbs_g, fat_g, servings, ingredients, instructions, notes, source)
VALUES
('Classic Strawberry Lemonade Gummies','gummies',90,8,10,0.5,4,
  ARRAY['2 cups liquid (1 cup fresh-squeezed lemon juice + 1 cup water)','4 tbsp Vital Proteins beef gelatin','4 tbsp chia seeds','½ cup diced strawberries, blended smooth','3 tbsp allulose','Pinch of salt'],
  ARRAY['Gently warm liquid — do not boil.','Whisk in gelatin until fully dissolved.','Stir in chia seeds, blended strawberries, allulose, and salt.','Pour into silicone molds or a lined dish.','Refrigerate 2+ hours until set.','Store in fridge up to 1 week. One serving = 5 gummies.'],
  'Bright, tangy and refreshing. Great pre-workout treat.','manual'),

('Mango Turmeric Glow Gummies','gummies',100,8,13,0.5,4,
  ARRAY['1½ cups unsweetened mango juice','½ cup water','4 tbsp Vital Proteins beef gelatin','4 tbsp chia seeds','½ tsp turmeric','Pinch black pepper','¼ tsp fresh grated ginger','2 tbsp allulose'],
  ARRAY['Warm mango juice and water gently.','Whisk in gelatin until dissolved.','Stir in chia seeds, turmeric, pepper, ginger, and allulose.','Pour into molds. Refrigerate 2+ hours.'],
  'Anti-inflammatory boost — turmeric + black pepper combo is key.','manual'),

('Berry Hibiscus Gummies','gummies',85,8,9,0.5,4,
  ARRAY['2 cups strong-brewed hibiscus tea, cooled','4 tbsp beef gelatin','4 tbsp chia seeds','½ cup mixed berry purée (blend fresh or frozen berries)','3 tbsp allulose'],
  ARRAY['Brew hibiscus tea strong (4 tea bags in 2 cups). Cool completely.','Warm slightly and whisk in gelatin.','Stir in berry purée, chia seeds, and allulose.','Pour into molds. Refrigerate 2+ hours.'],
  'Naturally deep purple colour — rich in antioxidants.','manual'),

('Watermelon Mint Gummies','gummies',88,8,11,0.5,4,
  ARRAY['1¾ cups blended seedless watermelon (strained)','¼ cup water','4 tbsp beef gelatin','4 tbsp chia seeds','5 fresh mint leaves','2 tbsp allulose','Squeeze of lime'],
  ARRAY['Blend watermelon and strain. Combine with water.','Warm gently and muddle mint leaves in the liquid.','Remove mint, whisk in gelatin.','Stir in chia seeds, allulose, and lime juice.','Pour into molds. Refrigerate 2+ hours.'],
  'Hydrating and refreshing — perfect for summer.','manual'),

('Peach Green Tea Gummies','gummies',90,8,11,0.5,4,
  ARRAY['1½ cups brewed green tea, cooled','½ cup fresh peach purée','4 tbsp beef gelatin','4 tbsp chia seeds','2 tbsp allulose','¼ tsp vanilla extract'],
  ARRAY['Brew green tea. Cool completely.','Blend peach until smooth.','Warm tea and whisk in gelatin.','Stir in peach purée, chia seeds, allulose, and vanilla.','Pour into molds. Refrigerate 2+ hours.'],
  'Green tea provides a gentle caffeine lift.','manual'),

('Coconut Pineapple Gummies','gummies',115,7,12,4,4,
  ARRAY['1 cup light coconut milk','1 cup unsweetened pineapple juice','4 tbsp beef gelatin','4 tbsp chia seeds','2 tbsp allulose','Pinch of salt'],
  ARRAY['Warm coconut milk and pineapple juice gently — do not boil.','Whisk in gelatin until dissolved.','Stir in chia seeds, allulose, and salt.','Pour into molds. Refrigerate 2+ hours.'],
  'Slightly higher in fat due to coconut milk — very satisfying.','manual'),

('Grape Elderflower Gummies','gummies',95,8,12,0.5,4,
  ARRAY['1½ cups unsweetened purple grape juice','½ cup water','4 tbsp beef gelatin','4 tbsp chia seeds','1 tsp elderflower extract','2 tbsp allulose'],
  ARRAY['Warm grape juice and water.','Whisk in gelatin until dissolved.','Stir in chia seeds, elderflower extract, and allulose.','Pour into molds. Refrigerate 2+ hours.'],
  'Elegant floral flavour — feels very grown-up.','manual'),

('Apple Cider Ginger Gummies','gummies',95,8,12,0.5,4,
  ARRAY['1½ cups unsweetened apple cider','½ cup water','4 tbsp beef gelatin','4 tbsp chia seeds','½ tsp fresh grated ginger','¼ tsp cinnamon','Pinch of clove','2 tbsp allulose'],
  ARRAY['Warm apple cider and water.','Whisk in gelatin until dissolved.','Stir in chia seeds, ginger, cinnamon, clove, and allulose.','Pour into molds. Refrigerate 2+ hours.'],
  'Warming spices make this a great autumn or winter treat.','manual'),

('Tart Cherry Vanilla Gummies','gummies',100,8,13,0.5,4,
  ARRAY['1½ cups tart cherry juice','½ cup water','4 tbsp beef gelatin','4 tbsp chia seeds','½ tsp vanilla extract','2 tbsp allulose'],
  ARRAY['Warm tart cherry juice and water.','Whisk in gelatin until dissolved.','Stir in chia seeds, vanilla, and allulose.','Pour into molds. Refrigerate 2+ hours.'],
  'Tart cherry supports recovery and sleep quality.','manual'),

('Citrus Sunrise Gummies','gummies',105,8,13,0.5,4,
  ARRAY['1 cup fresh orange juice','½ cup carrot juice','½ cup water','4 tbsp beef gelatin','4 tbsp chia seeds','Pinch of turmeric','2 tbsp allulose','Squeeze of lemon'],
  ARRAY['Combine juices and water. Warm gently.','Whisk in gelatin until dissolved.','Stir in chia seeds, turmeric, allulose, and lemon.','Pour into molds. Refrigerate 2+ hours.'],
  'Vitamin C powerhouse — vibrant colour and flavour.','manual'),

('Chia Pudding with Berries & Almond Butter','breakfast',310,12,28,14,3,
  ARRAY['4 tbsp chia seeds','1 cup unsweetened almond or oat milk','2 tsp monk fruit sweetener','½ tsp vanilla extract','Per serving: ½ cup mixed berries','Per serving: 1 tbsp almond butter'],
  ARRAY['Whisk chia seeds into milk with sweetener and vanilla.','Refrigerate overnight or 4+ hours — stir once after 30 min.','Portion into 3 jars. Top with berries and almond butter to serve.'],
  'Make the night before — grab-and-go ready.','manual'),

('Greek Yogurt Parfait','breakfast',320,26,22,10,2,
  ARRAY['1 cup plain 2% Greek yogurt (Fage or Chobani)','½ cup fresh berries','1 tbsp almond butter','1 tsp monk fruit sweetener','Pinch of cinnamon'],
  ARRAY['Layer yogurt in a bowl or jar.','Top with berries, drizzle almond butter, add sweetener and cinnamon.'],
  'No-cook, no-fuss — one of the highest protein breakfasts.','manual'),

('Egg & Smoked Salmon Scramble','breakfast',380,32,4,24,2,
  ARRAY['4 large eggs','2 oz smoked salmon, torn into pieces','2 tbsp cream cheese or Greek yogurt','¼ red onion, small dice','1 tsp avocado oil','Salt, pepper, fresh or dried dill'],
  ARRAY['Sauté onion in avocado oil for 2 minutes.','Add whisked eggs and cream cheese. Scramble on low heat slowly.','Fold in salmon at the very end. Season with dill.'],
  'Rich in omega-3s — exceptional for brain function and satiety.','manual'),

('Cottage Cheese Bowl with Fruit','breakfast',290,28,18,6,2,
  ARRAY['1 cup low-fat cottage cheese','½ cup pineapple chunks or sliced peach','1 tbsp hemp seeds','Drizzle of allulose','Pinch of cinnamon'],
  ARRAY['Combine cottage cheese, fruit, hemp seeds in a bowl.','Drizzle allulose and add cinnamon.'],
  'No cook — portable in a container for on-the-go days.','manual'),

('Turkey & Egg White Veggie Scramble','breakfast',350,35,6,16,2,
  ARRAY['3 oz lean ground turkey (93/7)','4 egg whites (or ½ cup carton)','½ cup baby spinach','¼ bell pepper, diced','1 tsp avocado oil','Garlic powder, cumin, salt'],
  ARRAY['Brown turkey in avocado oil with garlic powder and cumin.','Add bell pepper, cook 2 minutes. Add spinach until wilted.','Pour in egg whites and scramble until cooked through.'],
  'Highest protein breakfast in the guide at 35g.','manual'),

('Banana Nice Cream Protein Bowl','breakfast',340,22,38,12,2,
  ARRAY['2 frozen bananas','1 scoop unflavored or vanilla collagen peptides (2 tbsp)','1 tbsp almond butter','1 tsp cacao nibs or unsweetened cocoa powder','Pinch of salt'],
  ARRAY['Blend frozen bananas in a high-powered blender until smooth and creamy — scrape down as needed.','Blend in collagen peptides.','Serve in a bowl topped with almond butter drizzle and cacao nibs.'],
  'Satisfies chocolate and banana cravings simultaneously.','manual'),

('Banana Chocolate Protein Mug Cake','breakfast',360,24,30,14,2,
  ARRAY['½ ripe banana, mashed','2 large eggs','2 tbsp almond flour','1 tbsp unsweetened cocoa powder','1 tbsp allulose','½ tsp baking powder','Pinch of salt','Optional: 1 tsp almond butter to top'],
  ARRAY['Mix all ingredients until smooth in a mug or ramekin.','Microwave 90 seconds, or bake at 350°F for 12 minutes.','Serve warm. Top with almond butter if desired.'],
  'Double the recipe in a small baking dish for batch prep — bake 18-20 min.','manual'),

('Savory Egg Cups (Batch Egg Muffins)','breakfast',310,26,4,20,3,
  ARRAY['6 large eggs','3 oz turkey sausage or cooked shredded chicken','½ cup chopped spinach','¼ cup diced bell pepper','Salt, pepper, garlic powder'],
  ARRAY['Whisk eggs with seasoning. Stir in all fillings.','Grease a 9-cup muffin tin. Divide mixture evenly.','Bake at 350°F for 18–20 minutes until set and golden.','Store in fridge up to 4 days. Reheat 45 seconds in microwave.'],
  'Batch cook Sunday — breakfast sorted all week.','manual'),

('Smoked Salmon & Avocado Plate','breakfast',370,24,6,28,2,
  ARRAY['3 oz smoked salmon','½ avocado, sliced','2 tbsp cream cheese or labneh','Sliced cucumber','Capers','Thin-sliced red onion','Fresh dill','Lemon wedge'],
  ARRAY['Arrange all ingredients on a plate.','Squeeze lemon over everything and serve immediately.'],
  'No cook — the healthy fat from avocado and salmon keeps you satiated for hours.','manual'),

('Warm Egg Drop Soup','breakfast',280,20,6,14,2,
  ARRAY['3 cups chicken or bone broth (low sodium)','3 eggs, beaten','½ cup chopped scallions','1 tsp sesame oil','½ tsp ginger','Soy sauce or coconut aminos to taste'],
  ARRAY['Bring broth to a gentle simmer with ginger and soy sauce.','Slowly pour in beaten eggs while stirring in a circle to create ribbons.','Top with scallions and a drizzle of sesame oil. Serve immediately.'],
  'Add shredded chicken for extra protein. Works as a light lunch too.','manual'),

('Seasoned Shrimp Stir-Fry','lunch_dinner',380,38,12,14,2,
  ARRAY['½ lb large shrimp, peeled and deveined','½ bell pepper, ¼ onion, 1 carrot — all chopped','1 tsp avocado oil','½ tsp Maggi Masala seasoning','½ tsp garlic paste','½ tsp ginger paste','Salt, pepper, squeeze of lemon'],
  ARRAY['Heat oil in a skillet. Sauté onion + garlic + ginger paste 2 minutes.','Add carrot and bell pepper, cook 3 minutes until slightly softened.','Add shrimp and Maggi Masala. Cook until shrimp turns pink, about 3–4 minutes.','Finish with a squeeze of lemon. Serve as-is or over cauliflower rice.'],
  'Fast, flavourful, and high protein.','manual'),

('Salmon with Roasted Veggies','lunch_dinner',420,36,14,22,2,
  ARRAY['2 servings Morey''s Seasoned Wild Alaskan Salmon (or 10oz fresh salmon)','1 cup broccoli florets','1 cup zucchini, chopped','½ cup cherry tomatoes','1 tsp avocado oil','Garlic, salt, pepper','Lemon wedges'],
  ARRAY['Toss veggies with avocado oil, garlic, salt, pepper. Roast at 400°F for 20 minutes.','Cook salmon per package directions (bake or pan-sear 4 min per side).','Plate together and squeeze lemon over everything.'],
  'Sheet pan meal — minimal dishes, maximal nutrients.','manual'),

('Chicken Tikka (No Rice)','lunch_dinner',410,42,10,22,2,
  ARRAY['12 oz boneless skinless chicken thigh, cubed','½ cup plain Greek yogurt (for marinade)','1 tsp each: garam masala, cumin, coriander, turmeric, chili powder','2 garlic cloves + 1 tsp ginger','½ cup diced tomatoes','¼ cup heavy cream or coconut cream','1 tsp avocado oil'],
  ARRAY['Marinate chicken in yogurt + spices + garlic + ginger for at least 30 minutes.','Grill or broil chicken until cooked through with a slight char.','In the same pan, sauté tomatoes in oil, add remaining spices, then add cream. Simmer 5 minutes.','Toss grilled chicken into the sauce. Serve with cucumber slices.'],
  'Skip the naan and rice — the tikka sauce is the star.','manual'),

('Egg Drop Bone Broth Soup with Chicken','lunch_dinner',320,35,6,10,2,
  ARRAY['4 cups low-sodium chicken bone broth','6 oz cooked shredded chicken breast','2 eggs, beaten','1 cup baby bok choy or spinach','1 tsp sesame oil','Soy sauce or coconut aminos to taste','Ginger, scallions'],
  ARRAY['Bring broth to a simmer with ginger and soy sauce.','Add shredded chicken and bok choy. Cook 3 minutes.','Stream in beaten eggs while stirring slowly to create ribbons.','Finish with sesame oil and scallions. Serve immediately.'],
  'Deeply nourishing — great on low-appetite or tired days.','manual'),

('Ground Turkey Taco Bowl (No Tortilla)','lunch_dinner',440,40,14,22,2,
  ARRAY['10 oz lean ground turkey (93/7)','1 tsp each: cumin, chili powder, garlic powder, smoked paprika, oregano','½ cup no-sugar-added salsa','Base: shredded lettuce or cauliflower rice','¼ avocado','2 tbsp Greek yogurt (instead of sour cream)','Pico de gallo'],
  ARRAY['Brown turkey in a dry pan. Season with taco spice blend.','Add salsa and simmer 5 minutes.','Serve over lettuce or cauliflower rice with all toppings.'],
  'All the taco flavour, none of the carb guilt.','manual'),

('Lemon Herb Baked Cod','lunch_dinner',350,40,4,14,2,
  ARRAY['2 cod fillets (5–6 oz each)','1 tbsp avocado oil','Zest + juice of 1 lemon','2 garlic cloves, minced','Fresh or dried: thyme, parsley, dill','Side: sautéed asparagus or green beans'],
  ARRAY['Mix oil, lemon zest + juice, garlic, and herbs into a paste.','Coat both sides of the cod fillets.','Bake at 400°F for 12–15 minutes until cod flakes easily.','Serve with sautéed greens on the side.'],
  'Lean white fish — highest protein-to-calorie ratio in the guide.','manual'),

('Spicy Korean-Style Ground Beef Bowl','lunch_dinner',450,38,14,26,2,
  ARRAY['10 oz lean ground beef (90/10)','2 tbsp coconut aminos or low-sodium soy sauce','1 tsp sesame oil','1 tsp gochujang (or red chili flakes)','1 tsp garlic','1 tsp ginger','Allulose to taste','Base: shredded cabbage + sliced cucumber','Topping: sesame seeds + scallions'],
  ARRAY['Brown ground beef in a skillet. Drain excess fat.','Mix sauce ingredients. Pour over beef and simmer 3 minutes.','Serve over cabbage and cucumber slaw, top with sesame seeds and scallions.'],
  'Gochujang adds a slow heat that builds as you eat — adjust to taste.','manual'),

('Chicken Lettuce Wraps','lunch_dinner',360,36,10,16,2,
  ARRAY['10 oz ground chicken','½ cup water chestnuts, diced (canned, drained)','2 tbsp hoisin sauce','1 tbsp coconut aminos','1 tsp sesame oil','2 garlic cloves','1 tsp ginger','Romaine or butter lettuce cups'],
  ARRAY['Brown ground chicken with garlic and ginger.','Add water chestnuts and all sauces. Cook 3 minutes.','Spoon into lettuce cups. Top with scallions and serve immediately.'],
  'Great for meal prep (store filling separately).','manual'),

('Zucchini Noodle Shrimp Scampi','lunch_dinner',380,37,8,20,2,
  ARRAY['½ lb large shrimp, peeled and deveined','2 medium zucchini, spiralized or peeled into ribbons','3 garlic cloves, sliced thin','1 tbsp butter + 1 tsp avocado oil','¼ cup dry white wine or chicken broth','Lemon juice, red pepper flakes, fresh parsley, salt and pepper'],
  ARRAY['Sauté garlic in butter and oil for 1 minute over medium heat.','Add shrimp and cook until pink, about 3 minutes. Remove shrimp.','Deglaze pan with wine or broth. Add lemon juice and red pepper flakes.','Add zucchini noodles for 1–2 minutes only — they release water fast.','Return shrimp to pan. Toss, plate, and top with parsley.'],
  'Zucchini noodles absorb the scampi butter beautifully.','manual'),

('Baked Chicken Thighs with Roasted Cauliflower','lunch_dinner',470,44,10,28,2,
  ARRAY['2 bone-in, skin-on chicken thighs (or 3 boneless skinless)','1 tsp each: smoked paprika, garlic powder, onion powder, dried oregano, salt','1 tsp avocado oil','1 small head cauliflower, cut into florets','Dipping sauce: 2 tbsp Greek yogurt + lemon + garlic + za''atar'],
  ARRAY['Rub chicken with oil and the full spice blend.','Roast at 425°F for 35 minutes total.','After 10 minutes, add cauliflower to the same pan with oil and salt.','Rest 5 minutes before serving with yogurt dipping sauce.'],
  'Highest calorie and protein meal in the guide — perfect for active days.','manual'),

('Apple & Almond Butter','snacks',190,4,24,10,1,
  ARRAY['1 medium apple or pear','1.5 tbsp almond butter'],
  ARRAY['Slice the fruit.','Dip into almond butter or spread on slices.'],
  'Keep almond butter to 1.5 tbsp to stay ~190 cal.','manual'),

('Grapes, Cheese & Crackers','snacks',200,6,22,10,1,
  ARRAY['~15 green grapes','1 Amul cheese cube (or 1 oz sharp white cheddar)','5 Simple Mills almond crackers'],
  ARRAY['Arrange grapes, cheese, and crackers on a small plate.','Eat slowly — this is surprisingly satisfying.'],
  'Portion the crackers carefully — 5 = ~40 cal vs 17 on the box.','manual'),

('Cucumber & Labneh Dip','snacks',120,8,6,6,1,
  ARRAY['1 cup cucumber slices','3 tbsp labneh or Greek yogurt','Za''atar, salt, and a squeeze of lemon'],
  ARRAY['Season labneh with za''atar, salt, and lemon.','Serve cucumber slices alongside for dipping.'],
  'Best second snack on busy days — low cal, high protein ratio.','manual'),

('Hard-Boiled Eggs','snacks',140,12,1,10,1,
  ARRAY['2 large eggs','Everything bagel seasoning or hot sauce'],
  ARRAY['Boil eggs: place in cold water, bring to boil, cook 10 min, ice bath.','Peel and serve with seasoning.'],
  'Batch cook 6–8 eggs Sunday. Most efficient protein-per-calorie snack.','manual'),

('Frozen Banana Bites with Dark Chocolate','snacks',140,2,24,8,2,
  ARRAY['1 banana, sliced into rounds (~12 pieces)','1 oz 85%+ dark chocolate, melted','Optional: flaky sea salt, crushed almond'],
  ARRAY['Melt dark chocolate in microwave in 20-second intervals, stirring each time.','Dip banana rounds halfway. Place on parchment paper.','Sprinkle with sea salt. Freeze at least 1 hour.','Store in freezer zip bag. One serving = 6 bites.'],
  'Satisfies the banana + chocolate craving for just 140 cal.','manual'),

('Greek Yogurt Evening Boost','snacks',200,20,16,4,1,
  ARRAY['1 cup plain 2% Greek yogurt','½ cup mixed berries','Drizzle of allulose'],
  ARRAY['Combine in a bowl.','Top with berries and drizzle allulose lightly.'],
  'Key evening snack on busy days — the anchor for hitting 100g protein.','manual');
