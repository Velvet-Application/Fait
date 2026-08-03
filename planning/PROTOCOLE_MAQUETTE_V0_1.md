# Protocole de maquette native — version 0.1

## Objectif

Créer une maquette basse fidélité cliquable permettant de vérifier la compréhension du produit avant le développement des applications natives.

## Écrans obligatoires

1. Onboarding — promesse et contrôle utilisateur
2. Accueil — état avec trois dossiers
3. Confier — choix du canal d’entrée
4. Import d’un courrier — aperçu et confirmation
5. Analyse — compréhension et données extraites
6. Plan d’action — étapes et acteurs
7. Dossiers — tous, en cours, terminés
8. Détail d’un dossier — résumé, prochaine action, étapes, documents, historique
9. Validation sensible — contenu figé et conséquence
10. Confirmation — preuve d’envoi ou action planifiée
11. Notifications — action requise et dossier terminé
12. Profil — foyer, sécurité et préférences

## Scénarios de test

### Scénario A — Courrier administratif

L’utilisateur importe un courrier demandant un justificatif avant une date limite. Il doit comprendre la demande, corriger une date mal extraite, accepter le plan, joindre un document et valider un brouillon.

### Scénario B — Résiliation

L’utilisateur importe une facture annonçant une augmentation. Il doit consulter les options, choisir la résiliation, comprendre le préavis et valider le courrier préparé.

### Scénario C — Échéance

L’utilisateur importe un contrôle technique. Il doit visualiser la date idéale d’action, créer un rappel, enregistrer un rendez-vous fictif et clôturer le dossier avec une preuve.

## Données fictives

Aucune donnée personnelle réelle ne doit apparaître dans la maquette.

Profils fictifs autorisés :

- Camille Martin — titulaire du compte ;
- Alex Martin — membre du foyer ;
- véhicule fictif ;
- logement fictif ;
- organismes génériques ou explicitement présentés comme exemples.

## Questions à tester

1. L’utilisateur comprend-il immédiatement ce que signifie **Confier quelque chose** ?
2. Sait-il distinguer **À traiter**, **En cours**, **Besoin de vous** et **Fait** ?
3. Identifie-t-il la prochaine action sans ouvrir tous les détails ?
4. Comprend-il ce que FAIT. va faire et ce qui reste sous son contrôle ?
5. La validation sensible lui paraît-elle rassurante plutôt que contraignante ?
6. Sait-il retrouver la preuve qu’une démarche est terminée ?
7. Accepterait-il de transmettre un document comparable au service ?

## Critères de réussite

- 80 % des testeurs identifient l’action principale de chaque écran sans aide ;
- 80 % comprennent les quatre statuts ;
- aucun testeur ne croit qu’une résiliation peut être envoyée sans validation ;
- au moins 60 % déclarent qu’ils transmettraient un courrier réel après lecture des garanties ;
- le parcours complet est réalisable sans impasse ;
- les termes incompris sont recensés et corrigés avant développement.

## Différences à représenter

### iPhone

- barre d’onglets et navigation iOS ;
- feuilles modales pour analyse et validation ;
- interface plus aérée ;
- gestes et retour conformes aux habitudes iPhone.

### Android

- navigation et composants Compose/Material ;
- icône adaptative ;
- feuilles inférieures ou dialogues adaptés ;
- mise en page robuste sur différentes largeurs.

La logique et les contenus restent identiques. Seule la manière native de les présenter varie.

## Sortie attendue

- maquette iPhone complète ;
- déclinaison Android des écrans structurants ;
- liste des composants communs ;
- liste des différences natives ;
- compte rendu de tests ;
- décisions intégrées au journal du dépôt.
