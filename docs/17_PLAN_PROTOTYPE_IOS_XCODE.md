# Plan du prototype iOS sous Xcode — version 0.1

## Décision

Le premier prototype de **FAIT.** sera réalisé exclusivement pour iPhone dans **Xcode**, en **Swift** et **SwiftUI**.

Android reste dans la vision du produit, mais sa conception et son développement sont différés jusqu’à validation du parcours iOS par les premiers tests utilisateurs.

## Objectif du prototype

Construire une application iPhone exécutable dans le simulateur Xcode et installable sur un appareil de test, permettant de démontrer un parcours complet :

> Photographier ou importer un courrier → comprendre la demande → corriger une donnée → accepter le plan → valider l’action → retrouver la preuve.

Le prototype utilise uniquement des données fictives et des services simulés. Il ne réalise aucun envoi réel et ne traite aucun document personnel.

## Technologie

- Swift ;
- SwiftUI ;
- architecture fonctionnelle modulaire ;
- données de démonstration locales ;
- services simulés derrière des protocoles ;
- Swift Concurrency pour les états de chargement simulés ;
- tests unitaires sur le cycle de vie d’un dossier ;
- tests d’interface sur le parcours principal lorsque le socle est stable.

## Structure Xcode recommandée

```text
FAIT/
├── App/
│   ├── FAITApp.swift
│   ├── AppEnvironment.swift
│   └── RootTabView.swift
├── Core/
│   ├── Models/
│   ├── Services/
│   ├── Repositories/
│   ├── Navigation/
│   └── Utilities/
├── DesignSystem/
│   ├── Colors/
│   ├── Typography/
│   ├── Components/
│   ├── Status/
│   └── Assets/
├── Features/
│   ├── Onboarding/
│   ├── Home/
│   ├── Cases/
│   ├── Intake/
│   ├── Analysis/
│   ├── ActionPlan/
│   ├── Validation/
│   ├── Notifications/
│   └── Profile/
├── PreviewData/
│   ├── Fixtures/
│   └── MockServices/
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.xcstrings
│   └── SampleDocuments/
├── FAITTests/
└── FAITUITests/
```

## Navigation iOS

### Onglets principaux

Une `TabView` contient :

1. **Accueil** ;
2. **Dossiers** ;
3. **Confier** ;
4. **Notifications** ;
5. **Profil**.

L’onglet **Confier** est visuellement prioritaire, sans créer un comportement non standard pour iOS.

### Navigation interne

- `NavigationStack` pour les parcours ;
- `sheet` pour les sélections ou explications non critiques ;
- présentation modale dédiée pour une validation sensible ;
- confirmation explicite avant de quitter un brouillon important ;
- liens profonds internes préparés pour les futures notifications.

## Écrans de la première itération

### Lot 1 — Coquille navigable

- lancement et écran de marque ;
- onboarding court ;
- barre d’onglets ;
- accueil vide ;
- liste des dossiers fictifs ;
- profil simplifié.

### Lot 2 — Parcours « courrier »

- écran **Confier** ;
- import depuis les fichiers ;
- capture simulée ou appareil photo ;
- aperçu et confirmation ;
- analyse simulée ;
- correction des données ;
- plan d’action ;
- détail du dossier.

### Lot 3 — Confiance et résolution

- écran de validation sensible ;
- confirmation simulée ;
- preuve de résolution ;
- historique ;
- notification fictive ouvrant le dossier concerné.

## Données et services simulés

Le prototype doit utiliser des protocoles afin de remplacer facilement les simulations par l’API future.

### Protocoles initiaux

- `CaseRepository` ;
- `DocumentImporting` ;
- `DocumentAnalyzing` ;
- `ActionPlanProviding` ;
- `SensitiveActionValidating` ;
- `NotificationProviding`.

### Implémentations du prototype

- `MockCaseRepository` ;
- `MockDocumentAnalyzer` ;
- `MockActionPlanProvider` ;
- `MockValidationService`.

Les écrans ne doivent jamais dépendre directement de fichiers JSON ou de délais artificiels : ils utilisent les protocoles afin de préserver une architecture remplaçable.

## Design system iOS

Le prototype intègre dès le départ :

- les couleurs officielles de FAIT. ;
- les quatre statuts ;
- les composants de carte dossier ;
- les boutons principal et secondaire ;
- les espacements et rayons définis ;
- le mode clair ;
- une préparation compatible avec le mode sombre ;
- Dynamic Type ;
- VoiceOver ;
- réduction des animations ;
- zones tactiles confortables.

Pour éviter un blocage lié aux licences de police pendant le prototype, une police système peut être utilisée temporairement avec des métriques proches. Les actifs définitifs seront intégrés uniquement lorsque leurs droits d’usage seront vérifiés.

## Appareil photo et documents

### Prototype

- sélection d’un PDF ou d’une image via les interfaces système ;
- appareil photo accessible uniquement après action de l’utilisateur ;
- autorisation demandée au moment de l’usage ;
- aucune conservation durable d’un document réel ;
- documents de démonstration fournis dans le projet.

### Sécurité

- aucune clé secrète dans l’application ;
- aucune donnée personnelle dans le dépôt ;
- aucun appel vers une API de production ;
- aucune fonctionnalité d’envoi réel ;
- indication claire que le traitement est simulé.

## États à démontrer

Chaque écran structurant doit prévoir :

- contenu normal ;
- chargement ;
- erreur ;
- donnée incertaine ;
- document illisible ;
- absence de réseau simulée ;
- dossier nécessitant une validation ;
- dossier terminé avec preuve.

## Validation sur appareils

Avant de considérer la maquette iOS comme validée :

- test sur un petit écran d’iPhone ;
- test sur un grand écran d’iPhone ;
- test en portrait ;
- test avec grande taille de texte ;
- test VoiceOver sur le parcours principal ;
- test du mode sombre dès que les composants principaux sont stabilisés ;
- installation sur un iPhone physique via Xcode.

## Critères de sortie de la phase iOS

Android ne démarre qu’après obtention des résultats suivants :

1. le parcours courrier est réalisable sans explication extérieure ;
2. les quatre statuts sont compris ;
3. l’utilisateur distingue ce que FAIT. analyse, prépare et exécute ;
4. la validation sensible est comprise et jugée rassurante ;
5. la preuve de résolution est identifiable ;
6. les principaux problèmes d’accessibilité sont corrigés ;
7. le modèle de navigation est suffisamment stable pour être décliné.

## Hors périmètre

- backend réel ;
- comptes réels ;
- paiement ;
- envoi d’e-mail ou de courrier ;
- stockage cloud de documents ;
- OCR de production ;
- connexion bancaire ;
- application Android ;
- publication App Store.
