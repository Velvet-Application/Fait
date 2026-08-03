# Architecture native — version 0.2

## Décision

FAIT. reste destiné à devenir deux applications natives partageant la même logique métier, les mêmes API et les mêmes règles produit :

- **iPhone : Swift + SwiftUI** ;
- **Android : Kotlin + Jetpack Compose**.

Cependant, le développement est désormais séquencé :

1. prototype iPhone réalisé dans **Xcode** ;
2. validation du parcours, de la confiance et de l’ergonomie iOS ;
3. stabilisation de l’API et du modèle métier ;
4. déclinaison Android dans une phase ultérieure.

Le produit ne doit pas utiliser une interface web encapsulée. Android ne doit pas être développé en parallèle du prototype iOS tant que les parcours fondateurs ne sont pas validés.

## Priorité actuelle

La phase active concerne exclusivement :

- Xcode ;
- Swift ;
- SwiftUI ;
- simulateur iPhone ;
- installation sur iPhone physique ;
- données fictives et services simulés.

Android reste documenté comme cible future, mais il est hors périmètre d’exécution immédiat.

## Principes d’architecture

1. Une API unique et versionnée à terme.
2. Une base de données centrale séparée des applications.
3. Un moteur d’analyse documentaire indépendant des interfaces.
4. Une couche IA interchangeable et contrôlée.
5. Un journal d’événements immuable pour les actions importantes.
6. Un stockage documentaire chiffré et isolé.
7. Une validation explicite avant toute action engageante.
8. Un fonctionnement dégradé clair en cas d’absence de réseau.
9. Des protocoles Swift séparant les interfaces des services simulés.
10. Aucun backend de production requis pour la première maquette Xcode.

## Découpage fonctionnel

### Application iPhone — phase active

Responsabilités :

- authentification simulée ;
- capture et import de documents fictifs ;
- affichage des dossiers ;
- correction des informations extraites ;
- validation simulée des actions ;
- notifications fictives ;
- gestion simplifiée du foyer ;
- cache local de démonstration ;
- biométrie locale facultative dans une phase ultérieure du prototype.

### Application Android — phase différée

L’application Android sera conçue après validation du modèle iOS. Elle reprendra la logique métier commune sans copier mécaniquement l’interface iPhone.

### API métier future

Responsabilités :

- comptes et autorisations ;
- dossiers ;
- documents ;
- plans d’action ;
- validations ;
- statuts ;
- événements ;
- preuves de clôture ;
- notifications ;
- orchestration des connecteurs.

### Moteur documentaire futur

Responsabilités :

- conversion et nettoyage ;
- OCR lorsque nécessaire ;
- classification ;
- extraction structurée ;
- score de confiance ;
- lien entre chaque donnée extraite et sa source ;
- détection des informations manquantes.

### Moteur d’exécution futur

Responsabilités :

- génération de brouillons ;
- préparation de formulaires ;
- planification des relances ;
- création des demandes de validation ;
- exécution après accord ;
- contrôle des réponses ;
- clôture et preuve.

## Navigation iPhone

- `TabView` pour Accueil, Dossiers, Confier, Notifications et Profil ;
- `NavigationStack` pour les parcours ;
- feuilles modales pour les sélections secondaires ;
- présentation modale explicite pour les validations sensibles ;
- partage, appareil photo et fichiers via les API système ;
- Dynamic Type, VoiceOver, mode sombre et tailles d’écran supportés dès le socle ;
- liens internes préparés pour ouvrir directement un dossier depuis une notification future.

## Navigation Android future

- navigation Compose avec barre inférieure adaptative ;
- écrans et feuilles modales cohérents avec Material ;
- partage Android, sélecteur de documents, appareil photo et biométrie système ;
- prise en charge des différentes densités, tailles, thèmes et modes de navigation.

## Authentification

### Prototype Xcode

- compte fictif ou session locale ;
- aucune donnée réelle ;
- aucun serveur d’authentification requis ;
- possibilité de simuler les états connecté, déconnecté et session expirée.

### MVP connecté futur

- adresse e-mail et mot de passe ;
- vérification de l’adresse ;
- récupération de compte ;
- verrouillage biométrique facultatif après connexion ;
- sessions révocables depuis le profil.

### Plus tard

- Sign in with Apple ;
- connexion Google pour Android ;
- délégation sécurisée à un proche ;
- authentification renforcée pour les actions sensibles.

## Notifications

Les notifications ne doivent jamais devenir anxiogènes.

Types autorisés :

- validation requise ;
- échéance proche ;
- réponse reçue ;
- document manquant ;
- dossier terminé.

Dans le prototype, les notifications sont simulées localement. Chaque notification doit ouvrir directement le bon dossier et la bonne action.

## Données locales

Peuvent être conservés localement pendant le prototype :

- session fictive ;
- préférences ;
- dossiers de démonstration ;
- miniatures temporaires ;
- brouillons non sensibles ;
- documents d’exemple inclus dans le projet.

Ne doivent jamais être ajoutés au dépôt ou conservés sans protection :

- documents personnels réels ;
- données d’identité sensibles ;
- justificatifs réels ;
- secrets d’API ;
- contenus de validation réels.

## Mode hors ligne

Le prototype permet de simuler :

- consultation des dossiers ;
- préparation d’un import ;
- rédaction d’une demande ;
- erreur de synchronisation ;
- reprise après retour du réseau.

Aucun envoi, paiement, validation irréversible ou modification critique ne peut être confirmé hors ligne dans le futur produit connecté.

## Environnements

À terme :

- développement ;
- test interne ;
- bêta fermée ;
- production.

Pendant le prototype Xcode, seul un environnement local de démonstration est utilisé.

## Règle de livraison de la phase iOS

Aucune fonctionnalité iOS n’est considérée comme terminée tant qu’elle n’est pas testée sur :

- au moins deux tailles d’iPhone dans le simulateur ;
- un iPhone physique ;
- mode clair ;
- grande taille de texte ;
- VoiceOver sur le parcours principal ;
- connexion lente ou interrompue simulée ;
- mode sombre lorsque les composants structurants sont stabilisés.

Les critères Android seront définis au démarrage de sa phase, après validation du prototype iOS.
