# Design tokens mobiles — version 0.1

## Objectif

Traduire la charte graphique validée en règles exploitables par les applications natives iPhone et Android.

Les valeurs peuvent être ajustées après les premiers tests d’accessibilité, mais leurs rôles doivent rester stables.

# Couleurs de marque

| Token | Valeur | Usage |
|---|---:|---|
| `brand.primary` | `#2E6B4F` | actions principales, éléments actifs, sceau |
| `brand.secondary` | `#A8C5B0` | surfaces douces, illustrations, accents |
| `surface.warm` | `#FAF7F2` | fond principal clair |
| `neutral.taupe` | `#CFC6B8` | séparateurs et surfaces secondaires |
| `text.primary` | `#2B2E28` | texte principal et fond sombre |

# Couleurs fonctionnelles

Les valeurs exactes seront validées par contraste.

| Token | Sens |
|---|---|
| `status.todo.background` | À traiter — beige chaud |
| `status.todo.foreground` | texte et icône brun foncé |
| `status.progress.background` | En cours — bleu doux |
| `status.progress.foreground` | texte et icône bleu foncé |
| `status.user.background` | Besoin de vous — orange doux |
| `status.user.foreground` | texte et icône orange foncé |
| `status.done.background` | Fait — vert doux |
| `status.done.foreground` | texte et icône vert foncé |
| `feedback.error` | erreur ou blocage réel |
| `feedback.warning` | vigilance sans danger immédiat |
| `feedback.success` | confirmation d’une action |

La couleur n’est jamais le seul vecteur d’information : un libellé et une icône sont obligatoires.

# Mode sombre

Principes :

- éviter le noir pur ;
- utiliser Olive charbon comme base ;
- conserver le Vert confiance comme accent sans saturation excessive ;
- réduire les grandes surfaces Sauge douce ;
- vérifier chaque statut séparément ;
- préserver la profondeur des cartes sans ombres lourdes.

# Typographie

## Familles

- titres et éléments de marque : **Satoshi** ;
- interface et contenus : **Inter** ;
- police système autorisée en développement et en secours.

## Échelle recommandée

| Token | Taille de base | Usage |
|---|---:|---|
| `type.display` | 32 | onboarding et écrans vides |
| `type.title1` | 28 | titre principal d’écran |
| `type.title2` | 22 | section importante |
| `type.title3` | 18 | carte ou sous-section |
| `type.body` | 16 | texte courant |
| `type.callout` | 15 | informations secondaires |
| `type.caption` | 13 | métadonnées |
| `type.micro` | 11 | usage exceptionnel seulement |

Les tailles doivent suivre Dynamic Type sur iOS et la mise à l’échelle système sur Android.

# Espacements

Base : grille de 4 points.

| Token | Valeur |
|---|---:|
| `space.1` | 4 |
| `space.2` | 8 |
| `space.3` | 12 |
| `space.4` | 16 |
| `space.5` | 20 |
| `space.6` | 24 |
| `space.8` | 32 |
| `space.10` | 40 |
| `space.12` | 48 |

Marges d’écran recommandées :

- compact : 16 ;
- standard : 20 ;
- grand écran : 24 à 32.

# Rayons

| Token | Valeur | Usage |
|---|---:|---|
| `radius.small` | 8 | petits champs et chips |
| `radius.medium` | 12 | boutons et éléments compacts |
| `radius.large` | 16 | cartes |
| `radius.xlarge` | 24 | panneaux et modales |
| `radius.pill` | 999 | statuts et filtres |

Les composants iOS peuvent paraître légèrement plus doux. Les composants Android peuvent être légèrement plus structurés, sans modifier l’identité générale.

# Élévation

Niveaux :

1. surface plate ;
2. carte interactive ;
3. barre ou bouton flottant ;
4. feuille modale ;
5. dialogue critique.

Sur iOS, privilégier contraste, matière et profondeur discrète. Sur Android, utiliser l’élévation et les états Material de manière mesurée.

# Zones tactiles

- cible minimale : 44 × 44 points sur iOS ;
- cible minimale : 48 × 48 dp sur Android ;
- espacement suffisant entre deux actions sensibles ;
- aucun lien essentiel dépendant d’une petite icône seule.

# Boutons

## Primaire

- hauteur visuelle recommandée : 52 ;
- largeur pleine sur les validations importantes ;
- fond `brand.primary` ;
- libellé court et explicite ;
- état de chargement sans déplacement du contenu ;
- état désactivé compréhensible.

## Secondaire

- contour ou surface claire ;
- texte Vert confiance ;
- importance visuelle inférieure au bouton principal.

## Destructif

- jamais vert ;
- libellé précis ;
- confirmation supplémentaire lorsque l’action est irréversible.

# Cartes dossier

Structure :

1. icône ou catégorie ;
2. titre ;
3. organisme ou contexte ;
4. statut ;
5. prochaine action ;
6. date limite ou mise à jour.

Une carte ne doit pas dépasser deux actions directes. L’ouverture du détail reste l’action principale.

# Icônes

- style simple, arrondi et cohérent ;
- épaisseur uniforme ;
- pas de mélange de familles visuelles ;
- libellés associés pour les fonctions importantes ;
- symboles natifs autorisés lorsqu’ils sont familiers et cohérents.

## iOS

Utiliser les symboles système lorsque pertinent, sans imiter une marque extérieure. Adapter graisse et taille au contexte.

## Android

Utiliser une famille cohérente avec Compose et Material, personnalisée lorsque l’identité FAIT. l’exige.

# Animation et retours

- transitions courtes et discrètes ;
- retour tactile sur les validations importantes ;
- animation du sceau uniquement lors d’un accomplissement réel ;
- aucune animation bloquant l’action ;
- respect des réglages de réduction des mouvements.

# Accessibilité

Critères minimum :

- contrastes conformes WCAG AA ;
- texte agrandissable sans troncature critique ;
- parcours complet au lecteur d’écran ;
- ordre de navigation logique ;
- descriptions d’icônes ;
- erreurs annoncées clairement ;
- aucun message uniquement visuel ou sonore.

# Nommage technique

Les tokens doivent conserver les mêmes noms fonctionnels sur iOS et Android, même si leur implémentation diffère.

Exemples :

- Swift : `FaitColor.brandPrimary` ;
- Kotlin : `FaitColors.BrandPrimary` ;
- Swift : `FaitSpacing.medium` ;
- Kotlin : `FaitSpacing.Medium`.

L’application ne doit pas contenir de couleurs ou espacements importants écrits directement dans les écrans hors système de tokens.
