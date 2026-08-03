# Interface web responsive — version 0.1

## Décision

FAIT. dispose d’une interface web dédiée, cohérente avec l’application iPhone mais adaptée aux usages du navigateur.

Le web ne doit pas être une reproduction agrandie de l’interface iOS. Il partage avec elle :

- la marque et la palette ;
- les quatre statuts ;
- le modèle de dossier ;
- les règles de validation ;
- les contenus et la logique métier ;
- les principes de confiance et d’accessibilité.

## Technologie du prototype

- Next.js avec App Router ;
- React ;
- TypeScript ;
- CSS natif fondé sur les tokens FAIT. ;
- données fictives locales ;
- aucun backend dans cette première phase.

## Adaptation par largeur

### Ordinateur

- barre latérale persistante ;
- vues maître/détail pour les dossiers ;
- utilisation de l’espace horizontal ;
- actions principales clairement isolées ;
- clavier et focus visibles.

### Tablette

- mise en page simplifiée ;
- panneaux empilables ;
- navigation conservée tant que la largeur le permet ;
- zones tactiles compatibles avec un usage tactile.

### Smartphone web

- navigation basse ;
- action Confier mise en avant ;
- cartes en colonne ;
- aucune dépendance aux interactions de survol ;
- prise en compte des zones sûres du navigateur.

## Écrans du prototype

1. Accueil ;
2. Dossiers ;
3. Détail d’un dossier ;
4. Confier ;
5. Analyse ;
6. Plan d’action ;
7. Validation sensible ;
8. Preuve ;
9. Notifications ;
10. Profil et foyer.

## Règles communes avec iOS

1. Une action principale par écran.
2. Toute donnée incertaine est signalée.
3. La source d’une information extraite reste identifiable.
4. Toute action engageante requiert une validation explicite.
5. Le contenu validé est figé.
6. Le résultat final est accompagné d’une preuve.
7. Les quatre statuts restent identiques sur toutes les plateformes.
8. Les données de démonstration sont fictives.

## Périmètre exclu

- authentification réelle ;
- backend ;
- stockage de documents ;
- envoi réel ;
- paiement ;
- OCR de production ;
- publication publique.

## Critère de validation

Le prototype web est validé lorsque le parcours courrier peut être réalisé sur ordinateur et smartphone sans explication extérieure, avec une compréhension claire de ce que FAIT. analyse, prépare, valide et considère comme terminé.
