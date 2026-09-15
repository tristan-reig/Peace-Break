-- Catalogue de la boutique.
-- À exécuter après schema.sql.

insert into public.items (id, name, description, price, kind, asset) values
  ('life_plus',      'Life+',         'Ajoute définitivement une vie maximum', 5000, 'life_plus',   null),
  ('paddle_wood',    'Raquette bois', 'Une raquette en bois massif',            800, 'paddle_skin', 'paddle_wood'),
  ('paddle_neon',    'Raquette néon', 'Brille dans le noir',                   1500, 'paddle_skin', 'paddle_neon'),
  ('paddle_plasma',  'Plasma',        'Un arc de plasma contenu',              3200, 'paddle_skin', 'paddle_plasma'),
  ('paddle_circuit', 'Circuit',       'Gravée dans le silicium',               2600, 'paddle_skin', 'paddle_circuit'),
  ('paddle_vector',  'Vecteur',       'Pur fil de lumière',                    4000, 'paddle_skin', 'paddle_vector'),
  ('ball_fire',      'Balle de feu',  'Une balle incandescente',               1200, 'ball_skin',   'ball_fire'),
  ('ball_crystal',   'Balle cristal', 'Translucide et élégante',               2000, 'ball_skin',   'ball_crystal'),
  ('ball_pixel',     'Pixel',         'Huit bits, pas un de plus',             1800, 'ball_skin',   'ball_pixel'),
  ('ball_plasma',    'Plasma',        'Une sphère de gaz ionisé',              3400, 'ball_skin',   'ball_plasma'),
  ('ball_void',      'Vide',          'Elle absorbe la lumière',               4500, 'ball_skin',   'ball_void')
on conflict (id) do nothing;
