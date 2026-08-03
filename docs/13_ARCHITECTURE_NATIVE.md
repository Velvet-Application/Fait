# Architecture native — version 0.1

## Décision

FAIT. sera construit comme deux applications natives partageant la même logique métier, les mêmes API et les mêmes règles produit :

- **iPhone : Swift + SwiftUI** ;
- **Android : Kotlin + Jetpack Compose**.

Le produit ne doit pas utiliser une interface web encapsulée. Les conventions d’usage propres à chaque plateforme doivent être respectées sans créer deux produits différents.

## Principes d’architecture

1. Une API unique et versionnée.
2. Une base de données centrale séparée des applications.
3. Un moteur d’analyse documentaire indépendant des interfaces.
4. Une couche IA interchangeable et contrôlée.
5. Un journal d’événements immuable pour les actions importantes.
6. Un stockage documentaire chiffré et isolé.
7. Une validation explicite avant toute action engageante.
8. Un fonctionnement dégradé clair en cas d’absence de réseau.

## Découpage fonctionnel

### Applications mobiles

Responsabilités :

- authentification ;
- capture et import de documents ;
- affichage des dossiers ;
- validation des actions ;
- notifications ;
- gestion du foyer ;
- cache local limité ;
- biométrie locale.

### API métier

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

### Moteur documentaire

Responsabilités :

- conversion et nettoyage ;
- OCR lorsque nécessaire ;
- classification ;
- extraction structurée ;
- score de confiance ;
- lien entre chaque donnée extraite et sa source ;
- détection des informations manquantes.

### Moteur d’exécution

Responsabilités :

- génération de brouillons ;
- préparation de formulaires ;
- planification des relances ;
- création des demandes de validation ;
- exécution après accord ;
- contrôle des réponses ;
- clôture et preuve.

## Navigation native

### iPhone

- `TabView` pour Accueil, Dossiers, Confier, Notifications et Profil ;
- `NavigationStack` pour les parcours ;
- feuilles modales pour les validations sensibles ;
- partage, appareil photo, fichiers et biométrie via les API système ;
- Dynamic Type, VoiceOver, mode sombre et tailles d’écran supportés dès le socle.

### Android

- navigation Compose avec barre inférieure adaptative ;
- écrans et feuilles modales cohérents avec Material ;
- partage Android, sélecteur de documents, appareil photo et biométrie système ;
- prise en charge des différentes densités, tailles, thèmes et modes de navigation.

## Authentification

### MVP

- adresse e-mail et mot de passe ;
- vérification de l’adresse ;
- récupération de compte ;
- verrouillage biométrique facultatif après connexion ;
- sessions révocables depuis le profil.

### Plus tard

- Sign in with Apple ;
- connexion Google ;
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

Chaque notification doit ouvrir directement le bon dossier et la bonne action.

## Données locales

Peuvent être conservés localement :

- session chiffrée ;
- préférences ;
- résumés de dossiers ;
- miniatures temporaires ;
- brouillons non sensibles.

Ne doivent pas rester durablement sans protection :

- documents complets ;
- données d’identité sensibles ;
- justificatifs ;
- secrets d’API ;
- contenus de validation.

## Mode hors ligne

Le MVP autorise :

- consultation limitée des dossiers déjà synchronisés ;
- préparation d’un import ;
- rédaction d’une demande ;
- reprise automatique lors du retour du réseau.

Aucun envoi, paiement, validation irréversible ou modification critique ne peut être confirmé hors ligne.

## Environnements

- développement ;
- test interne ;
- bêta fermée ;
- production.

Les données, clés, notifications et comptes doivent être séparés entre chaque environnement.

## Règle de livraison

Aucune fonctionnalité n’est considérée comme terminée tant qu’elle n’est pas testée sur :

- au moins deux tailles d’iPhone ;
- un appareil Android compact ;
- un appareil Android grand écran ;
- mode clair ;
- mode sombre ;
- grande taille de texte ;
- connexion lente ou interrompue.
