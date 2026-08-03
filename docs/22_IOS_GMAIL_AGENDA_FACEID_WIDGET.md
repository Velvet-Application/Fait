# FAIT. — Gmail, agenda iPhone, Face ID et widget

## Branche

`agent/ios-mail-calendar-faceid-widget`

## Fonctionnalités livrées

- connexion Google Sign-In native ;
- permission Gmail lecture seule demandée en premier ;
- permission `gmail.compose` demandée séparément pour créer des brouillons ;
- aucun endpoint d’envoi d’e-mail ;
- jeton de session mobile opaque conservé dans le Trousseau iPhone ;
- synchronisation des messages utiles avec la vue **Détecté** ;
- ajout confirmé d’un rendez-vous via EventKit ;
- verrouillage de l’application via Face ID ;
- widget petit et moyen avec décisions en attente et prochain rendez-vous ;
- App Group partagé sans contenu brut des e-mails.

## Configuration Google dans `ios/FAIT/Info.plist`

Remplacer :

- `REPLACE_WITH_IOS_CLIENT_ID.apps.googleusercontent.com` par le Client ID OAuth de type iOS ;
- `REPLACE_WITH_WEB_SERVER_CLIENT_ID.apps.googleusercontent.com` par le Client ID OAuth Web utilisé par le backend ;
- `com.googleusercontent.apps.REPLACE_WITH_REVERSED_CLIENT_ID` par le schéma inversé du Client ID iOS.

Le Bundle Identifier du client iOS Google doit correspondre au Bundle Identifier de la cible FAIT.

## Backend

URL du pilote :

`https://fait-git-agent-mobile-google-session-backend-cyril16.vercel.app`

Variables Vercel requises :

- `GOOGLE_CLIENT_ID` : Client ID OAuth Web/serveur ;
- `GOOGLE_CLIENT_SECRET` : secret OAuth Web/serveur ;
- `FAIT_SESSION_SECRET` : secret aléatoire de 32 caractères minimum.

Les secrets ne doivent jamais être copiés dans Xcode.

## Signature et App Group

Dans **Signing & Capabilities**, les cibles `FAIT` et `FAITWidget` doivent utiliser la même équipe Apple et partager :

`group.com.velvetapplication.fait`

Si ce groupe n’existe pas dans le compte Apple, Xcode peut demander de le créer ou de l’enregistrer.

## Tests

### Face ID

- activer Face ID dans **Profil → Centre iPhone** ;
- mettre l’application en arrière-plan ;
- revenir dans FAIT. ;
- vérifier que l’écran de verrouillage apparaît.

Sur simulateur : **Features → Face ID → Enrolled**, puis tester **Matching Face** et **Non-matching Face**.

### Agenda

- ouvrir **Profil → Centre iPhone** ;
- vérifier le rendez-vous proposé ;
- cocher la confirmation ;
- toucher **Ajouter au calendrier** ;
- accepter l’autorisation d’écriture ;
- vérifier l’événement et le rappel dans Calendrier.

### Gmail

- toucher **Connecter Gmail** ;
- accepter la lecture des messages utiles ;
- lancer la synchronisation ;
- vérifier les nouveaux éléments dans **Détecté** ;
- autoriser les brouillons seulement au premier besoin ;
- vérifier le brouillon dans Gmail ;
- vérifier qu’aucun message n’a été envoyé.

### Widget

- lancer FAIT. au moins une fois ;
- maintenir le doigt sur l’écran d’accueil ;
- toucher `+` ;
- rechercher **FAIT. quotidien** ;
- ajouter le format petit ou moyen ;
- toucher le widget pour ouvrir l’espace **Détecté**.

## Limites du pilote

- la synchronisation Gmail est manuelle ;
- aucune pièce jointe n’est téléchargée ;
- les dates écrites en langage libre dans les e-mails doivent encore être vérifiées avant ajout au calendrier ;
- le widget expose uniquement un résumé non sensible ;
- les données métier restent locales dans cette version ;
- le build final doit être validé sur Xcode/macOS et sur un iPhone physique avant fusion.
