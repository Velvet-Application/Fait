# Architecture fonctionnelle

## Modules

### Identité et foyer

- compte ;
- membres du foyer ;
- rôles et délégations ;
- logements ;
- véhicules ;
- préférences.

### Documents

- import ;
- classement ;
- extraction ;
- version ;
- durée de conservation ;
- suppression.

### Dossiers

- demande ;
- plan d'action ;
- statut ;
- échéance ;
- événements ;
- pièces liées ;
- preuve de clôture.

### Moteur d'exécution

- modèles d'actions ;
- génération ;
- validation ;
- connecteurs ;
- relances ;
- contrôles.

### Notifications

- urgence ;
- échéance ;
- demande de validation ;
- réponse reçue ;
- dossier clôturé.

### Administration interne

- contrôle qualité ;
- traitement humain ;
- incidents ;
- audit ;
- gestion des modèles ;
- statistiques anonymisées.

## Architecture de démarrage recommandée

- web mobile installable en premier ;
- API séparée ;
- stockage documentaire chiffré ;
- base relationnelle ;
- service OCR/extraction ;
- couche IA interchangeable ;
- journal d'événements ;
- aucune dépendance technique ou donnée avec Velvet.
