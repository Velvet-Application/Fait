# FAIT. — Socle produit v0.3

**Statut :** projet incubé en parallèle de Velvet  
**Priorité :** 20 % maximum tant que la bêta externe de Velvet n'est pas stable  
**Marque de travail validée :** FAIT. — sous réserve des vérifications juridiques  
**Promesse :** *Vous demandez. C'est fait.*  
**Identité visuelle :** Concept 3 — Sceau de confiance  
**Plateformes cibles :** applications natives iPhone et Android  
**Technologies retenues :** SwiftUI et Kotlin/Jetpack Compose

FAIT. est un assistant d'exécution du quotidien. Il ne se contente pas de rappeler, classer ou conseiller : il transforme un courrier, un contrat, un e-mail ou une demande en actions suivies jusqu'à leur résolution.

## Périmètre de départ

1. Contrats et abonnements
2. Échéances administratives
3. Courriers et documents à traiter
4. Résiliations et demandes simples
5. Suivi des démarches du foyer

## Règle fondatrice

Toute action engageante — paiement, résiliation, signature, transmission sensible ou prise d'engagement — nécessite une validation explicite de l'utilisateur.

## Identité mobile

Le logo validé associe le mot-symbole **FAIT.** à un sceau de confiance contenant une coche. La charte est conçue dès l'origine pour deux applications natives :

- iPhone : expérience respectant les conventions iOS, l'accessibilité, les zones sûres et les déclinaisons d'icône ;
- Android : expérience respectant les conventions Android, les icônes adaptatives et la diversité des appareils.

Les deux plateformes partagent la marque, les contenus, les statuts et la logique métier, mais ne doivent pas être de simples copies visuelles l'une de l'autre.

## Architecture retenue

- iPhone : Swift + SwiftUI ;
- Android : Kotlin + Jetpack Compose ;
- API métier commune et versionnée ;
- stockage documentaire chiffré ;
- moteur d'analyse documentaire indépendant ;
- moteur d'exécution soumis aux validations utilisateur ;
- journal d'événements et preuves de résolution.

## Navigation du prototype

1. **Accueil**
2. **Dossiers**
3. **Confier**
4. **Notifications**
5. **Profil**

Le bouton **Confier quelque chose** est le point d'entrée principal.

## Trois parcours fondateurs

1. comprendre et traiter un courrier ;
2. résilier ou renégocier un contrat ;
3. anticiper une échéance obligatoire.

## Structure du dépôt

- `docs/00_NOM_ET_POSITIONNEMENT.md`
- `docs/01_VISION_PRODUIT.md`
- `docs/02_CIBLES_ET_PROBLEMES.md`
- `docs/03_MVP_V0_1.md`
- `docs/04_PARCOURS_UTILISATEUR.md`
- `docs/05_CONFIANCE_SECURITE.md`
- `docs/06_ARCHITECTURE_FONCTIONNELLE.md`
- `docs/07_MODELE_ECONOMIQUE.md`
- `docs/08_ROADMAP_80_20.md`
- `docs/09_CONCURRENCE_DIFFERENCIATION.md`
- `docs/10_JOURNAL_DECISIONS.md`
- `docs/11_CHARTE_GRAPHIQUE_MOBILE.md`
- `docs/12_PARCOURS_FONDATEURS.md`
- `docs/13_ARCHITECTURE_NATIVE.md`
- `docs/14_SPEC_ECRANS_MVP.md`
- `docs/15_MODELE_DONNEES_DOSSIER.md`
- `docs/16_DESIGN_TOKENS_MOBILE.md`
- `planning/backlog_initial.csv`

## Prochaine phase

Produire une maquette fonctionnelle basse fidélité, puis initialiser un prototype natif limité aux écrans structurants et à des données fictives internes.

## Organisation

Velvet conserve la priorité opérationnelle. FAIT. avance lentement sur la validation du besoin, la confiance, le positionnement et le prototype avant tout développement important.
