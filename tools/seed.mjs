import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_KEY;

if (!url || !key) {
  console.error('SUPABASE_URL et SUPABASE_SERVICE_KEY sont requis.');
  process.exit(1);
}

const db = createClient(url, key, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const NAMES = [
  'Toto', 'Simon', 'Nibel', 'Huchuch', 'Kali',
  'Ombrelle', 'Omega', 'Nat', 'Puk', 'Gaspacho',
  'Luna', 'Karo', 'Bidule', 'Zephyr', 'Mango',
  'Pixel', 'Nova', 'Silex', 'Torpille', 'Vega',
];

const PASSWORD = 'Test1234!';
const MAX_STAGE = 10;

const scoreFor = (stage) =>
  Math.round((1200 + stage * 420) * (0.75 + Math.random() * 0.5));

async function seedUser(name, index) {
  const email = `${name.toLowerCase()}@peacebreak.test`;

  const { data, error } = await db.auth.admin.createUser({
    email,
    password: PASSWORD,
    email_confirm: true,
    user_metadata: { username: name },
  });

  if (error) {
    if (error.message.includes('already been registered')) {
      console.log(`- ${name} existe déjà, ignoré`);
      return;
    }
    throw error;
  }

  const userId = data.user.id;

  const cleared = Math.min(MAX_STAGE, Math.floor((index / NAMES.length) * 12));

  const rows = [];
  for (let stage = 1; stage <= cleared; stage++) {
    rows.push({
      user_id: userId,
      stage_number: stage,
      best_score: scoreFor(stage),
    });
  }

  if (rows.length > 0) {
    const { error: progressError } = await db
      .from('stage_progress')
      .insert(rows);
    if (progressError) throw progressError;
  }

  const total = rows.reduce((sum, row) => sum + row.best_score, 0);

  const { error: profileError } = await db
    .from('profiles')
    .update({
      total_score: total,
      coins: Math.round(total / 8),
      next_stage: Math.min(cleared + 1, MAX_STAGE),
      max_lives: 3 + (index % 3),
    })
    .eq('id', userId);

  if (profileError) throw profileError;

  console.log(
    `+ ${name.padEnd(10)} ${String(cleared).padStart(2)} stages   ` +
    `${String(total).padStart(6)} pts`,
  );
}

console.log(`Création de ${NAMES.length} comptes...\n`);
for (const [index, name] of NAMES.entries()) {
  try {
    await seedUser(name, index);
  } catch (err) {
    console.error(`! ${name} : ${err.message}`);
  }
}
console.log(`\nTerminé. Mot de passe commun : ${PASSWORD}`);
