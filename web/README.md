# FAIT. — Prototype web responsive

Interface web de démonstration de FAIT., cohérente avec le prototype iOS et adaptée aux usages navigateur.

## URL publique de test

**https://fait-ten.vercel.app/**

Cette URL correspond au déploiement Vercel du prototype web sur la branche de travail. Elle doit être vérifiée après chaque nouveau déploiement avant fusion dans `main`.

## Technologies

- Next.js 16.2 avec App Router
- React 19.2
- TypeScript
- CSS natif et variables de design FAIT.

## Lancer localement

Depuis le dossier `web` :

```bash
npm install
npm run dev
```

Ouvrir ensuite `http://localhost:3000`.

Pour vérifier la version de production :

```bash
npm run build
npm run start
```

## Contenu de cette première version

- navigation latérale sur ordinateur ;
- navigation basse sur smartphone ;
- accueil avec synthèse des dossiers ;
- liste et détail des dossiers ;
- parcours « Confier un courrier » ;
- analyse et correction simulées ;
- plan d’action ;
- validation sensible ;
- preuve de résolution ;
- notifications ;
- profil et foyer ;
- simulation du mode hors ligne.

## Principes conservés depuis iOS

- identité « Sceau de confiance » ;
- palette officielle ;
- quatre statuts : À traiter, En cours, Besoin de vous, Fait ;
- validation explicite avant toute action engageante ;
- source visible pour les données extraites ;
- aucune donnée personnelle ni action réelle dans le prototype.

## Différences volontaires avec l’application iPhone

Le web utilise une barre latérale sur les grands écrans, davantage d’espace horizontal et des vues maître/détail. Sur mobile, l’interface retrouve une navigation basse proche de l’application, sans prétendre reproduire les comportements natifs iOS.
