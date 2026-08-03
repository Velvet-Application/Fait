# Spécification des écrans du MVP — version 0.1

## Objectif

Définir le premier prototype natif de FAIT. sans ajouter de fonctionnalités non indispensables.

## Navigation principale

Cinq entrées :

1. **Accueil**
2. **Dossiers**
3. **Confier**
4. **Notifications**
5. **Profil**

L’onglet **Confier** est visuellement prioritaire, sans casser les conventions natives.

# 1. Écran d’accueil

## But

Montrer uniquement ce qui mérite l’attention de l’utilisateur.

## Contenu

- salutation courte ;
- bouton **Confier quelque chose** ;
- bloc **Besoin de vous** ;
- bloc **Prochaines échéances** ;
- bloc **En cours** ;
- bloc **Récemment fait** ;
- résumé de valeur uniquement lorsque vérifiable.

## Règles

- aucun fil d’actualité ;
- aucune publicité ;
- pas plus de trois dossiers visibles par bloc ;
- chaque carte indique la prochaine action ;
- les urgences sont exprimées calmement et précisément.

## États

- premier usage ;
- aucun dossier ;
- dossier nécessitant une action ;
- chargement ;
- erreur de synchronisation ;
- mode hors ligne.

# 2. Écran Confier

## But

Permettre à l’utilisateur de transmettre un sujet en quelques secondes.

## Actions principales

- **Prendre une photo** ;
- **Importer un document** ;
- **Coller un e-mail ou un texte** ;
- **Écrire une demande** ;
- **Dicter une demande**.

## Informations complémentaires

Après l’entrée, FAIT. peut demander :

- qui est concerné ;
- la catégorie ;
- la date connue ;
- le résultat recherché.

Une seule question est posée à la fois. Les questions inutiles sont évitées lorsque le document contient déjà l’information.

## Confirmation

Avant analyse :

- aperçu ;
- ajout ou suppression de pages ;
- qualité de lecture ;
- personne concernée ;
- bouton **Analyser**.

# 3. Écran Analyse

## But

Montrer ce que FAIT. a compris et permettre la correction.

## Contenu

- titre proposé ;
- émetteur ou organisme ;
- résumé simple ;
- date limite ;
- montant éventuel ;
- niveau d’attention ;
- données incertaines ;
- accès aux sources dans le document.

## Action principale

**Continuer vers le plan d’action**.

## Règle

Aucune donnée incertaine ne doit être présentée comme certaine.

# 4. Écran Plan d’action

## But

Transformer l’analyse en étapes compréhensibles.

## Contenu

Chaque étape précise :

- ce qui doit être fait ;
- qui le fait : utilisateur, FAIT. ou assistance humaine ;
- la date cible ;
- les documents nécessaires ;
- si une validation est requise.

## Actions

- accepter le plan ;
- modifier une information ;
- retirer une étape ;
- demander une explication ;
- abandonner le dossier.

# 5. Liste des dossiers

## Vues

- **Tous** ;
- **En cours** ;
- **Terminés**.

## Recherche et filtres

Le MVP inclut :

- recherche par titre ou organisme ;
- filtre par statut ;
- filtre par personne du foyer.

## Carte dossier

- titre ;
- organisme ;
- personne ou bien concerné ;
- statut ;
- prochaine action ;
- date limite ;
- dernière mise à jour.

# 6. Détail d’un dossier

## En-tête

- titre ;
- statut ;
- personne concernée ;
- date limite ;
- menu d’actions.

## Sections

### Résumé

Ce que le dossier signifie actuellement.

### Prochaine action

Une seule action principale clairement mise en avant.

### Étapes

Chronologie du plan avec états : terminé, en cours, à venir, bloqué.

### Documents

Sources, pièces jointes, brouillons et preuves.

### Historique

Événements horodatés et compréhensibles.

### Aide

Explication, correction ou demande d’intervention humaine.

# 7. Écran de validation sensible

## Utilisation

Obligatoire avant :

- envoi d’un courrier ou e-mail ;
- résiliation ;
- réservation engageante ;
- transmission de données sensibles ;
- signature ;
- paiement futur.

## Contenu

- action exacte ;
- destinataire ;
- contenu transmis ;
- pièces jointes ;
- date d’effet ;
- coût ou conséquence connue ;
- caractère réversible ou non ;
- case ou geste de confirmation lorsque nécessaire.

## Boutons

- **Valider l’action** ;
- **Revenir au dossier**.

Le bouton principal reste désactivé tant que les éléments obligatoires n’ont pas été consultés ou complétés.

# 8. Notifications

## Liste

Regroupement par dossier et date.

## Catégories

- action requise ;
- échéance ;
- réponse ;
- document ;
- clôture.

## Règle

Une notification lue mais non résolue reste visible dans le dossier concerné.

# 9. Profil et foyer

## Sections MVP

- profil utilisateur ;
- membres du foyer ;
- logements ;
- véhicules ;
- documents réutilisables ;
- préférences de notification ;
- sécurité et biométrie ;
- appareils connectés ;
- export et suppression des données ;
- aide et confidentialité.

# 10. Onboarding

## Écrans

1. promesse : **Vous demandez. C’est fait.** ;
2. fonctionnement en trois étapes ;
3. contrôle et validations ;
4. création de compte ;
5. autorisations facultatives ;
6. premier sujet à confier.

## Règle

L’accès aux documents, à l’appareil photo, au micro et aux notifications est demandé au moment où la fonction est utilisée, jamais en bloc sans contexte.

# Accessibilité

Tous les écrans doivent :

- fonctionner avec une grande taille de texte ;
- avoir des zones tactiles confortables ;
- conserver une information textuelle en plus de la couleur ;
- être lisibles par VoiceOver et TalkBack ;
- gérer le contraste en mode clair et sombre ;
- éviter les animations indispensables à la compréhension.

# Périmètre exclu du prototype

- paiement ;
- appel vocal IA ;
- comparateur commercial complet ;
- accès bancaire ;
- marketplace de prestataires ;
- messagerie conversationnelle illimitée ;
- automatisation irréversible sans validation.
