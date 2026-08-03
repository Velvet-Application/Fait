# Pilote réel Gmail OAuth

## Statut

Le pilote est développé sur la branche `agent/gmail-oauth-pilot`. Il transforme la maquette connectée en premier circuit réel, tout en conservant l’architecture web V2 verrouillée.

## Circuit livré

1. connexion Google OAuth côté serveur ;
2. autorisation Gmail en lecture seule ;
3. synchronisation complète initiale puis synchronisation incrémentale à partir du `historyId` ;
4. détection initiale de quatre catégories : facture, rendez-vous, contrat et démarche administrative ;
5. proposition de dossier FAIT. conservée localement dans le navigateur pour le pilote ;
6. ajout contrôlé dans l’agenda interne FAIT. ;
7. autorisation séparée pour la création de brouillons Gmail ;
8. création d’un brouillon dans Gmail après vérification du destinataire, de l’objet et du contenu ;
9. aucune route ni action d’envoi d’e-mail.

## Permissions Google

### Connexion initiale

- `openid`
- `email`
- `profile`
- `https://www.googleapis.com/auth/gmail.readonly`

### Autorisation incrémentielle au premier brouillon

- `https://www.googleapis.com/auth/gmail.compose`

Google ne propose pas de champ d’application autonome limité à la seule création de brouillons pour une application web classique. Le champ `gmail.compose` permet techniquement de gérer les brouillons et d’envoyer des messages. FAIT. compense cette portée par une règle d’architecture vérifiable : aucun endpoint d’envoi n’est implémenté dans le pilote.

## Sécurité du pilote

- flux OAuth serveur avec `state` aléatoire ;
- jetons conservés dans un cookie `HttpOnly`, `SameSite=Lax` et chiffré en AES-256-GCM ;
- secret de chiffrement fourni uniquement par variable d’environnement ;
- révocation Google et suppression locale immédiates ;
- aucune clé ou jeton dans GitHub ;
- aucune persistance serveur des contenus Gmail ;
- dossiers et agenda du pilote conservés uniquement dans le stockage local du navigateur ;
- aucune analyse automatique en arrière-plan : l’utilisateur déclenche la synchronisation.

## Variables Vercel requises

- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_OAUTH_REDIRECT_URI`
- `FAIT_SESSION_SECRET`

L’URI de redirection doit être déclarée à l’identique dans Google Cloud :

```text
https://<domaine-vercel>/api/google/oauth/callback
```

## Configuration Google Cloud

1. créer ou sélectionner un projet Google Cloud ;
2. activer Gmail API ;
3. configurer l’écran de consentement OAuth en mode test ;
4. ajouter les adresses Gmail autorisées comme utilisateurs de test ;
5. créer un ID client OAuth de type Application Web ;
6. ajouter l’URI de redirection Vercel exacte ;
7. reporter l’ID client et le secret dans Vercel ;
8. redéployer la branche.

## Limites volontaires

- classification déterministe par mots-clés, sans modèle externe ;
- maximum de 25 messages détaillés par synchronisation ;
- pas de pièces jointes téléchargées ;
- pas de calendrier iPhone ou Google Calendar dans ce lot ;
- pas de base de données multi-appareils ;
- pas de notifications push Gmail ;
- pas d’envoi automatique ou manuel depuis FAIT.

## Étapes suivantes après validation

1. persistance sécurisée des dossiers et événements ;
2. écran de correction des informations extraites ;
3. pièces jointes et rapprochement avec les dossiers existants ;
4. notifications Gmail push et synchronisation serveur ;
5. EventKit iPhone ;
6. audit sécurité et préparation de la procédure de vérification Google.
