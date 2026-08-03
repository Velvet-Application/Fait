# FAIT. — Vision de l’assistant quotidien connecté

## Statut

Cette vision devient la direction produit cible de FAIT. Elle complète le socle validé autour des dossiers, des validations explicites et de la preuve de résolution.

FAIT. ne doit pas seulement attendre qu’un utilisateur lui confie une démarche. À terme, il doit pouvoir détecter les sujets utiles dans les services autorisés, comprendre ce qu’ils impliquent, organiser les prochaines étapes, préparer les actions et exécuter celles qui ont été autorisées.

## Promesse cible

> FAIT. observe ce que l’utilisateur lui autorise à observer, transforme les informations utiles en actions claires, prépare le travail et termine les démarches avec le niveau de confirmation adapté.

L’objectif n’est pas de créer un assistant conversationnel supplémentaire, mais un orchestrateur du quotidien capable de relier les e-mails, les documents, les contrats, les factures, les calendriers, les rappels et les portails de services.

## Capacités structurantes

### 1. Boîtes e-mail connectées

FAIT. doit pouvoir connecter, avec consentement explicite :

- Gmail et Google Workspace ;
- Outlook, Hotmail et Microsoft 365 ;
- d’autres fournisseurs uniquement lorsqu’une API officielle ou un protocole sécurisé le permet.

Fonctions attendues :

- détecter les nouveaux messages utiles ;
- distinguer les factures, contrats, convocations, rendez-vous, relances, demandes de documents et échéances ;
- extraire les dates, montants, organismes, références, pièces jointes et actions demandées ;
- créer ou mettre à jour automatiquement un dossier FAIT. ;
- proposer un classement et un niveau d’urgence ;
- préparer un brouillon de réponse ;
- envoyer une réponse uniquement selon la politique de validation définie ;
- rattacher le message d’origine, le brouillon, l’envoi et la preuve au même dossier.

Le principe de moindre privilège s’applique : lecture seule lorsque suffisante, droit de composition uniquement lorsque nécessaire, droit d’envoi activé séparément.

### 2. Calendrier FAIT. et synchronisation

FAIT. possède un calendrier interne servant de couche d’orchestration. Ce calendrier ne remplace pas nécessairement les calendriers de l’utilisateur : il relie les événements aux dossiers, aux documents, aux rappels et aux actions.

Il doit pouvoir :

- créer des rendez-vous détectés dans les e-mails ou documents ;
- générer des rappels avant une échéance ;
- gérer les événements récurrents ;
- détecter les conflits ;
- associer un événement à un dossier ;
- synchroniser les événements autorisés avec Apple Calendar, Google Calendar et Outlook Calendar ;
- créer des notifications locales et serveur ;
- ouvrir directement le dossier ou l’action depuis une notification.

Chaque événement doit indiquer sa source, son état de synchronisation et le calendrier externe concerné afin d’éviter les doublons.

### 3. Préparation et réponse depuis FAIT.

Lorsqu’un e-mail exige une réponse, FAIT. peut :

1. comprendre la demande ;
2. rechercher les informations déjà connues dans le profil et le dossier ;
3. préparer le texte ;
4. proposer les pièces jointes ;
5. afficher le destinataire, le contenu et les conséquences ;
6. demander une validation si la politique l’exige ;
7. créer le brouillon dans la boîte d’origine ou envoyer depuis celle-ci ;
8. suivre la réponse et relancer si nécessaire.

Une modification du destinataire, du contenu substantiel, des pièces jointes ou de la conséquence invalide l’autorisation précédente.

### 4. Portails et services du quotidien

Exemples :

- réservation d’un centre aéré ;
- inscription à la cantine ou à une activité municipale ;
- prise de rendez-vous ;
- dépôt d’un justificatif ;
- renouvellement d’une carte ;
- déclaration ou mise à jour d’une situation ;
- réservation d’un service déjà connu de l’utilisateur.

Ordre de préférence technique :

1. API officielle et OAuth ;
2. intégration partenaire ou lien profond authentifié ;
3. session web autorisée par l’utilisateur ;
4. automatisation navigateur contrôlée, uniquement en dernier recours et après vérification des conditions d’utilisation du service.

FAIT. doit pouvoir préparer une réservation complète, puis demander l’accord avant la dernière étape lorsqu’elle crée un engagement, une dépense, une annulation, une inscription ou une déclaration.

## Niveaux d’autonomie

### Niveau 0 — Observer

FAIT. détecte, classe et explique sans modifier de service externe.

Exemples : identifier une facture, extraire une date de rendez-vous, signaler une échéance.

### Niveau 1 — Organiser

FAIT. crée un dossier, une tâche, un rappel ou un événement interne.

Ces actions sont réversibles et sans conséquence externe significative.

### Niveau 2 — Préparer

FAIT. prépare un brouillon, un formulaire, une réservation, une liste de pièces ou un plan d’action.

Aucune action finale n’est encore exécutée.

### Niveau 3 — Exécuter avec confirmation

FAIT. affiche un écran de validation figé puis exécute l’action autorisée : envoi d’un e-mail, réservation, dépôt, résiliation, inscription ou modification de compte.

### Niveau 4 — Exécuter selon une autorisation permanente limitée

L’utilisateur peut autoriser à l’avance certaines actions à faible risque et précisément bornées.

Exemples possibles :

- classer un e-mail ;
- créer un rappel ;
- ajouter un rendez-vous détecté dans un calendrier choisi ;
- préparer systématiquement les brouillons sans les envoyer ;
- télécharger et rattacher une facture à un dossier.

Les paiements, engagements contractuels, annulations, réservations payantes, déclarations administratives et envois sensibles restent soumis à une confirmation explicite, sauf décision produit et juridique ultérieure très encadrée.

## Espace « Connexions et autorisations »

Le terme « Paramètres » reste disponible, mais les comptes externes sont regroupés dans un espace explicite :

> Connexions et autorisations

Pour chaque connexion, l’utilisateur voit :

- le service connecté ;
- le compte concerné ;
- les permissions accordées ;
- la date de dernière utilisation ;
- les automatisations actives ;
- les actions nécessitant toujours une confirmation ;
- un bouton de suspension ;
- un bouton de révocation ;
- l’historique des accès et actions.

## Politique d’identifiants et secrets

### Règle principale

FAIT. ne demande pas le mot de passe d’un service lorsqu’une connexion OAuth, une passkey, un lien d’autorisation ou une API officielle existe.

### Services sans OAuth ni API

L’enregistrement d’un identifiant et d’un mot de passe constitue une solution de dernier recours. Dans ce cas :

- le secret n’est jamais enregistré en clair ;
- les clés de chiffrement sont séparées des données ;
- l’accès au secret peut exiger Face ID, Touch ID, code de l’appareil ou authentification équivalente ;
- le secret n’est déchiffré que pour l’action autorisée ;
- chaque usage est journalisé ;
- l’utilisateur peut supprimer immédiatement la connexion ;
- les copies dans les logs, outils d’analyse et sauvegardes sont interdites ;
- une fuite d’un composant ne doit pas suffire à révéler les identifiants.

Le coffre de secrets ne doit pas être construit dans la première version publique. Il nécessite une revue de sécurité dédiée, des tests d’intrusion et un modèle de menace formel.

## Moteur de décisions et confirmations

Chaque action reçoit un niveau de risque calculé à partir de :

- la possibilité d’annulation ;
- l’existence d’un coût ;
- la portée juridique ou contractuelle ;
- la sensibilité des données ;
- le destinataire ;
- le caractère public ou privé ;
- l’impact sur un enfant ou un autre membre du foyer ;
- la nouveauté du service ou du bénéficiaire ;
- le niveau d’autorisation déjà accordé.

Le moteur décide alors si FAIT. peut :

- agir silencieusement ;
- agir puis notifier ;
- préparer seulement ;
- demander une confirmation simple ;
- demander une confirmation renforcée avec biométrie ;
- refuser l’automatisation et guider l’utilisateur.

## Architecture fonctionnelle cible

### Couche 1 — Connecteurs

- Gmail / Google Workspace ;
- Outlook / Microsoft 365 ;
- Google Calendar ;
- Microsoft Graph Calendar ;
- calendriers locaux iOS et Android ;
- notifications mobiles ;
- portails partenaires ;
- automatisation navigateur contrôlée en dernier recours.

### Couche 2 — Ingestion

- e-mails ;
- pièces jointes ;
- événements ;
- notifications de changement ;
- documents téléchargés ;
- formulaires et confirmations.

### Couche 3 — Compréhension

- classification ;
- extraction structurée ;
- détection des échéances ;
- rapprochement avec une personne, un bien ou un contrat ;
- détection de doublons ;
- estimation de confiance ;
- identification de l’action attendue.

### Couche 4 — Orchestration

- création et mise à jour des dossiers ;
- calendrier interne ;
- règles d’autonomie ;
- moteur de confirmations ;
- planification ;
- relances ;
- gestion des dépendances.

### Couche 5 — Exécution

- création de brouillons ;
- envoi d’e-mails ;
- création d’événements ;
- dépôt de documents ;
- réservation ;
- remplissage de formulaires ;
- récupération des confirmations.

### Couche 6 — Preuve et audit

- source d’origine ;
- contenu préparé ;
- version validée ;
- identité ayant validé ;
- heure d’exécution ;
- réponse du service ;
- preuve finale ;
- historique complet.

## Premier lot réaliste

La vision cible est large. La première livraison connectée doit rester maîtrisée :

1. connexion Gmail en lecture limitée ;
2. détection des factures, rendez-vous, contrats et demandes de documents ;
3. proposition de création d’un dossier ;
4. calendrier FAIT. interne ;
5. création d’un événement dans le calendrier iPhone avec accord ;
6. préparation d’un brouillon Gmail ;
7. envoi uniquement après validation explicite ;
8. journal des actions et révocation de la connexion.

Outlook/Microsoft 365 vient ensuite sur le même modèle. Les portails municipaux et automatisations navigateur ne commencent qu’après stabilisation de la sécurité, des autorisations et des preuves.

## Principe produit non négociable

> FAIT. doit réduire la charge mentale sans retirer à l’utilisateur la maîtrise de ses décisions.

L’autonomie se gagne progressivement, connexion par connexion et action par action. Elle doit être compréhensible, réversible, auditable et révocable à tout moment.
