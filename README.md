# Peace Break

Jeu de casse-briques pour Android, avec progression sauvegardée,
boutique et classement en ligne.

## Fonctionnalités

- 10 niveaux de difficulté croissante, chacun avec son temps imparti
- Bonus et malus à attraper pendant la partie
- Score basé sur les briques, le temps restant et les vies conservées
- Boutique de skins pour la raquette et la balle
- Classement des dix meilleurs joueurs
- Compte utilisateur avec progression synchronisée

## Compilation

    flutter pub get
    flutter build apk --release

L'application se connecte par défaut à une instance Supabase publique.
Pour utiliser la vôtre :

    flutter build apk --release \
      --dart-define=SUPABASE_URL=https://votre-projet.supabase.co \
      --dart-define=SUPABASE_PUBLISHABLE_KEY=votre_cle

La clé « publishable » de Supabase est destinée aux clients publics :
elle ne donne accès qu'à ce que les politiques de sécurité au niveau
des lignes autorisent.

## Schéma de base de données

Les scripts SQL se trouvent dans `supabase/`.

## Comptes de démonstration

Le dossier `tools/` contient un script Node qui crée des comptes de test.
Il n'est pas nécessaire pour compiler l'application.

    npm install
    SUPABASE_URL=... SUPABASE_SERVICE_KEY=... node tools/seed.mjs

## Technologies

Flutter, Flame, Supabase.

## Licence

GPL-3.0. Voir `LICENSE`.

Polices : Press Start 2P et IBM Plex Mono, SIL Open Font License 1.1.
