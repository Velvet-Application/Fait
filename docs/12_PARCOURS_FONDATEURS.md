# Parcours fondateurs — version 0.1

## Objectif

Définir la première structure fonctionnelle de FAIT. autour de trois démarches suffisamment concrètes pour être testées dans une application native iPhone et Android.

## Navigation principale

### 1. Accueil

L'accueil présente uniquement ce qui mérite l'attention de l'utilisateur :

- bouton principal **Confier quelque chose** ;
- dossiers en statut **Besoin de vous** ;
- prochaines échéances ;
- dossiers récemment terminés ;
- résumé du temps ou de l'argent économisé lorsque la donnée est fiable.

### 2. Dossiers

Trois vues :

- **Tous** ;
- **En cours** ;
- **Terminés**.

Chaque dossier affiche son statut, sa prochaine action, sa date limite et sa dernière mise à jour.

### 3. Confier

Point d'entrée universel :

- prendre une photo ;
- importer un PDF ou une image ;
- transférer ou coller un e-mail ;
- écrire une demande ;
- dicter une demande.

### 4. Notifications

Uniquement les alertes utiles :

- validation requise ;
- date limite proche ;
- réponse reçue ;
- document manquant ;
- dossier terminé.

### 5. Profil et foyer

- identité ;
- membres du foyer ;
- logements ;
- véhicules ;
- documents réutilisables ;
- délégations ;
- préférences de notification ;
- confidentialité et suppression.

## Objet central : le dossier

Tout sujet confié à FAIT. devient un dossier contenant :

- titre ;
- catégorie ;
- personne ou bien concerné ;
- organisme ou entreprise ;
- documents sources ;
- résumé ;
- date de création ;
- date limite ;
- statut ;
- prochaine action ;
- niveau de risque ;
- validations requises ;
- événements horodatés ;
- messages et réponses ;
- preuve de clôture.

## Cycle de vie

1. **Reçu** — le contenu est importé.
2. **Analyse** — les données sont extraites et vérifiées.
3. **À traiter** — un plan d'action est disponible.
4. **En cours** — une ou plusieurs actions sont engagées.
5. **Besoin de vous** — une information ou une validation est indispensable.
6. **Fait** — le résultat et sa preuve sont disponibles.

Les étapes techniques **Reçu** et **Analyse** peuvent être affichées dans le détail, mais les quatre statuts visibles dans les listes restent : **À traiter**, **En cours**, **Besoin de vous**, **Fait**.

# Parcours 1 — Comprendre et traiter un courrier

## Entrée

L'utilisateur photographie ou importe un courrier.

## Écrans

### Écran 1 — Import

- aperçu du document ;
- recadrage éventuel ;
- confirmation de la lisibilité ;
- choix de la personne concernée.

### Écran 2 — Compréhension

FAIT. présente :

- l'émetteur ;
- l'objet ;
- ce que le courrier signifie ;
- la date limite ;
- le montant éventuel ;
- le niveau d'urgence ;
- les conséquences possibles en cas d'inaction.

Toute donnée extraite reste modifiable par l'utilisateur.

### Écran 3 — Plan proposé

Exemple :

1. vérifier l'information demandée ;
2. joindre un justificatif ;
3. préparer une réponse ;
4. envoyer avant la date limite ;
5. conserver la preuve.

### Écran 4 — Action

Selon le dossier :

- checklist ;
- brouillon de courrier ;
- brouillon d'e-mail ;
- formulaire préparé ;
- rappel ;
- transfert à l'assistance humaine.

### Écran 5 — Validation

Avant tout envoi :

- destinataire ;
- contenu ;
- pièces jointes ;
- canal ;
- conséquence de l'action ;
- bouton **Valider et envoyer**.

### Écran 6 — Suivi

- preuve d'envoi ;
- délai attendu ;
- date de relance ;
- réponse reçue ;
- clôture.

## Preuve de résolution

Un accusé, une réponse, un document accepté ou une confirmation explicite de l'utilisateur.

# Parcours 2 — Résilier ou renégocier un contrat

## Entrée

L'utilisateur importe un contrat, une facture ou un e-mail d'augmentation, ou décrit le service à résilier.

## Écrans

### Écran 1 — Contrat identifié

- fournisseur ;
- service ;
- titulaire ;
- prix ;
- fréquence de paiement ;
- engagement ;
- échéance ;
- moyen de contact connu.

### Écran 2 — Options

FAIT. distingue clairement :

- conserver ;
- négocier ;
- changer d'offre ;
- résilier ;
- demander des informations.

Aucune économie n'est annoncée sans source vérifiable.

### Écran 3 — Conditions

- préavis ;
- frais éventuels ;
- matériel à restituer ;
- justificatifs ;
- date d'effet estimée ;
- conséquences prévisibles.

### Écran 4 — Préparation

- courrier ou e-mail ;
- pièces jointes ;
- adresse ou canal ;
- calendrier des actions ;
- relance prévue.

### Écran 5 — Validation explicite

L'utilisateur confirme :

- le choix ;
- la date d'effet ;
- le contenu ;
- les frais connus ;
- l'envoi.

### Écran 6 — Suivi

- demande envoyée ;
- réponse attendue ;
- relance ;
- confirmation de résiliation ou nouvelle proposition ;
- contrôle de la dernière facture.

## Preuve de résolution

Confirmation écrite, date de fin effective et contrôle de l'absence de prélèvement indu lorsque cette information est disponible.

# Parcours 3 — Anticiper une échéance obligatoire

## Entrée

L'utilisateur importe un document ou crée une obligation : pièce d'identité, contrôle technique, entretien, assurance ou autre échéance.

## Écrans

### Écran 1 — Échéance reconnue

- sujet ;
- personne ou bien concerné ;
- date d'expiration ;
- organisme ;
- référence du document.

### Écran 2 — Calendrier recommandé

FAIT. propose :

- date idéale de démarrage ;
- date limite de sécurité ;
- date d'expiration ;
- rappels utiles.

### Écran 3 — Préparation

- pièces nécessaires ;
- photos ou justificatifs manquants ;
- coût connu ou fourchette sourcée ;
- procédure ;
- lien ou rendez-vous éventuel.

### Écran 4 — Action

- créer un rappel ;
- préparer un dossier ;
- proposer un rendez-vous ;
- enregistrer une action réalisée ailleurs.

### Écran 5 — Clôture

- nouveau document ou facture ;
- date de réalisation ;
- prochaine échéance calculée ;
- archivage de la preuve.

## Preuve de résolution

Nouveau document, attestation, facture, rendez-vous réalisé ou confirmation utilisateur accompagnée d'une date.

# Règles communes de confiance

1. Chaque information extraite affiche sa source documentaire.
2. Une donnée incertaine est signalée et demandée à l'utilisateur.
3. Une action irréversible n'est jamais exécutée sans validation.
4. Une intervention humaine est annoncée avant l'accès au dossier.
5. L'utilisateur peut interrompre ou reprendre un dossier.
6. Toutes les actions sont horodatées.
7. Les erreurs peuvent être corrigées sans recréer le dossier.
8. Les documents sont supprimables indépendamment du dossier lorsque la loi et la preuve de service le permettent.

# Différences natives attendues

## iPhone

- navigation et gestes cohérents avec iOS ;
- transitions discrètes ;
- feuilles modales pour les validations ;
- intégration du partage, de l'appareil photo et des documents ;
- composants aérés et priorité à la lisibilité.

## Android

- navigation système et gestes respectés ;
- composants adaptatifs ;
- intégration du partage Android et des sélecteurs de documents ;
- comportement cohérent sur différentes tailles d'écran ;
- retours d'état plus explicites lorsque nécessaire.

# Indicateurs du prototype

- taux de documents correctement compris ;
- taux de plans d'action acceptés ;
- nombre de corrections utilisateur ;
- taux de dossiers menés jusqu'à **Fait** ;
- délai moyen de résolution ;
- taux de réutilisation sous trente jours ;
- confiance déclarée avant et après la démarche ;
- disposition à payer pour une résolution complète.
