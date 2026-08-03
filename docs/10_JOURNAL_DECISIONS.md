# Journal des décisions

## 3 août 2026

### Décision 001 — Lancer une incubation parallèle

Le projet est validé, mais Velvet reste prioritaire selon une répartition 80/20.

### Décision 002 — Séparation totale

Le projet doit avoir sa propre marque, son propre dépôt, sa propre base et ses propres règles de données.

### Décision 003 — Point d'entrée

Le MVP commence par les contrats, échéances, courriers et démarches administratives simples.

### Décision 004 — Contrôle utilisateur

Toute action engageante nécessite une validation explicite.

### Décision 005 — Nom de travail

Le nom retenu pour la construction du produit est **FAIT.** avec la signature **« Vous demandez. C'est fait. »**. Son exploitation commerciale définitive reste conditionnée à la recherche d'antériorité et aux vérifications juridiques.

### Décision 006 — Différenciation

Le produit est un assistant d'exécution et de résolution, pas seulement un assistant d'organisation.

### Décision 007 — Transparence humaine

Toute intervention humaine sur un dossier est clairement annoncée à l'utilisateur.

### Décision 008 — Dépôt dédié

Le socle produit est hébergé dans le dépôt `Velvet-Application/Fait`, indépendamment du dépôt Velvet.

### Décision 009 — Identité visuelle validée

La charte graphique **Concept 3 — Sceau de confiance** est validée comme identité officielle de travail.

Le logo est composé d'un sceau souple et arrondi intégrant une coche de validation, associé au mot-symbole **FAIT.**.

### Décision 010 — Palette et typographies

La palette officielle repose sur le Vert confiance `#2E6B4F`, la Sauge douce `#A8C5B0`, le Blanc chaleureux `#FAF7F2`, le Gris taupe `#CFC6B8` et l'Olive charbon `#2B2E28`.

La typographie principale est **Satoshi** et la typographie secondaire est **Inter**.

### Décision 011 — Applications natives

L'objectif produit reste confirmé : applications natives iPhone et Android, avec une expérience adaptée à chaque plateforme plutôt qu'une simple interface identique emballée sur deux systèmes.

L'identité reste commune, mais les comportements, la navigation, les transitions, les icônes et certains composants respectent les conventions propres à iOS et Android.

### Décision 012 — Système de statuts

Les quatre statuts structurants sont verrouillés :

1. **À traiter** ;
2. **En cours** ;
3. **Besoin de vous** ;
4. **Fait**.

### Décision 013 — Technologies natives

Les technologies retenues pour le prototype et la future application sont :

- **Swift + SwiftUI** pour iPhone ;
- **Kotlin + Jetpack Compose** pour Android.

Une API métier commune porte les dossiers, documents, validations, statuts, événements et preuves. Aucune interface web encapsulée ne doit constituer l'application finale.

### Décision 014 — Navigation du prototype

La navigation principale comprend :

1. Accueil ;
2. Dossiers ;
3. Confier ;
4. Notifications ;
5. Profil.

L'action **Confier quelque chose** est le point d'entrée central.

### Décision 015 — Objet central

Le **dossier** devient l'objet central du produit. Il regroupe les sources, l'analyse, le plan d'action, les validations, les exécutions, l'historique et la preuve de résolution.

### Décision 016 — Validation figée

Toute validation sensible porte sur un contenu figé. Une modification substantielle du destinataire, du texte, des pièces, de la date, du coût ou de la conséquence impose une nouvelle validation utilisateur.

### Décision 017 — Périmètre du prototype

Le premier prototype ne contient ni paiement, ni accès bancaire, ni marketplace, ni appel vocal IA, ni automatisation irréversible sans accord explicite.

### Décision 018 — Priorité iOS dans Xcode

Le premier prototype est réalisé exclusivement pour **iPhone dans Xcode**, avec Swift et SwiftUI.

Il doit être exécutable dans le simulateur et installable sur un iPhone de test. Il utilise des données fictives et des services simulés derrière des protocoles afin de préparer le raccordement futur à l'API.

Android reste une cible produit confirmée, mais sa réalisation est différée jusqu'à validation du parcours, de la navigation, de la confiance et de l'accessibilité sur iPhone.

### Décision 019 — Architecture web V2 verrouillée

L'architecture web V2 devient la référence officielle : aucun menu latéral permanent, en-tête flottant, dock inférieur centré et action **Confier** surélevée. L'accueil reste éditorial et les dossiers sont présentés comme des parcours de résolution, afin de distinguer FAIT. de Velvet et des tableaux de bord SaaS ou IA génériques.

### Décision 020 — Logo final intégré

Le logo final **Sceau de confiance + FAIT. + « Vous demandez. C'est fait. »** est intégré sous forme vectorielle. Le sceau seul devient l'icône de navigateur et la base des futures icônes d'application iOS et Android.

### Décision 021 — FAIT. devient un orchestrateur du quotidien

La vision cible évolue d'un assistant auquel l'utilisateur confie manuellement une démarche vers un orchestrateur capable, avec autorisation, de détecter les sujets utiles dans les e-mails, documents, calendriers et services connectés, puis de les transformer en dossiers et actions suivies jusqu'à résolution.

### Décision 022 — Connecteurs e-mail et calendriers

Les connecteurs prioritaires sont Gmail, Outlook/Microsoft 365, Google Calendar, Microsoft Calendar et les calendriers locaux iOS et Android. FAIT. pourra analyser les messages entrants, détecter factures, contrats, rendez-vous et échéances, préparer des brouillons et synchroniser les événements autorisés.

### Décision 023 — Autonomie progressive et explicable

L'autonomie est structurée en niveaux : observer, organiser, préparer, exécuter avec confirmation et exécuter sous autorisation permanente limitée. Les paiements, engagements, annulations, réservations payantes, déclarations et envois sensibles restent soumis à confirmation explicite.

### Décision 024 — Connexions et autorisations

Un espace **Connexions et autorisations** remplacera l'idée d'un simple formulaire générique d'identifiants. OAuth, passkeys et API officielles sont prioritaires. L'enregistrement d'un mot de passe pour un service sans API constitue un dernier recours nécessitant coffre chiffré, authentification renforcée, journalisation, révocation et audit de sécurité dédié.

### Décision 025 — Premier lot connecté

La première intégration réelle commencera par Gmail en lecture limitée, la détection de quatre catégories utiles, la création proposée d'un dossier, le calendrier interne, l'ajout contrôlé au calendrier iPhone et la préparation d'un brouillon. Aucun envoi n'aura lieu sans validation explicite dans ce premier lot.
