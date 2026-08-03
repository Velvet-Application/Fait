# Modèle de données du dossier — version 0.1

## Principe

Le **dossier** est l’objet central de FAIT. Tous les documents, actions, validations, messages et preuves doivent lui être rattachés.

Le modèle présenté ici est fonctionnel. Il devra être traduit ensuite en schéma technique et migrations de base de données.

# Entités principales

## User

- `id`
- `email`
- `email_verified_at`
- `first_name`
- `last_name`
- `preferred_language`
- `timezone`
- `status`
- `created_at`
- `updated_at`
- `deleted_at`

## Household

- `id`
- `name`
- `owner_user_id`
- `created_at`
- `updated_at`

## HouseholdMember

- `id`
- `household_id`
- `user_id` facultatif
- `display_name`
- `relationship`
- `date_of_birth` facultative
- `status`
- `consent_scope`
- `created_at`
- `updated_at`

## Asset

Représente un bien du foyer.

- `id`
- `household_id`
- `type` : logement, véhicule, autre
- `name`
- `metadata`
- `created_at`
- `updated_at`

## Case

- `id`
- `household_id`
- `created_by_user_id`
- `assigned_member_id` facultatif
- `asset_id` facultatif
- `title`
- `category`
- `subcategory`
- `organization_name`
- `reference`
- `summary`
- `visible_status`
- `internal_stage`
- `attention_level`
- `deadline_at`
- `next_action_at`
- `closed_at`
- `closure_reason`
- `created_at`
- `updated_at`
- `deleted_at`

## CaseStatus

### Statuts visibles

- `to_process` — À traiter
- `in_progress` — En cours
- `needs_user` — Besoin de vous
- `done` — Fait

### Étapes internes

- `received`
- `analyzing`
- `analysis_failed`
- `plan_ready`
- `waiting_validation`
- `executing`
- `waiting_external_response`
- `waiting_user_information`
- `resolved`
- `cancelled`

Le statut visible est dérivé de l’étape interne, mais peut être figé temporairement pour éviter des changements incompréhensibles dans l’interface.

## Document

- `id`
- `case_id`
- `uploaded_by_user_id`
- `type`
- `role` : source, pièce jointe, brouillon, réponse, preuve
- `original_filename`
- `mime_type`
- `size_bytes`
- `storage_key`
- `checksum`
- `encryption_key_reference`
- `page_count`
- `processing_status`
- `retention_until`
- `created_at`
- `deleted_at`

## ExtractedField

Chaque donnée extraite doit pouvoir être reliée à sa source.

- `id`
- `document_id`
- `case_id`
- `field_name`
- `raw_value`
- `normalized_value`
- `confidence_score`
- `source_page`
- `source_area`
- `confirmed_by_user_id` facultatif
- `confirmed_at` facultatif
- `created_at`
- `updated_at`

## ActionPlan

- `id`
- `case_id`
- `version`
- `summary`
- `accepted_by_user_id` facultatif
- `accepted_at` facultatif
- `created_at`
- `superseded_at` facultatif

## ActionStep

- `id`
- `action_plan_id`
- `position`
- `title`
- `description`
- `actor_type` : user, fait, human_support, external
- `status`
- `due_at`
- `requires_validation`
- `reversible`
- `cost_amount` facultatif
- `cost_currency` facultatif
- `completed_at` facultatif

## ValidationRequest

- `id`
- `case_id`
- `action_step_id`
- `requested_from_user_id`
- `type`
- `summary`
- `payload_snapshot`
- `risk_level`
- `expires_at`
- `status` : pending, approved, rejected, expired, revoked
- `approved_at` facultatif
- `rejected_at` facultatif
- `created_at`

Le `payload_snapshot` fige exactement ce qui a été validé. Toute modification substantielle impose une nouvelle validation.

## Execution

- `id`
- `case_id`
- `action_step_id`
- `validation_request_id` facultatif
- `channel`
- `recipient`
- `payload_snapshot`
- `status`
- `external_reference`
- `executed_at`
- `failed_at`
- `failure_reason`
- `created_at`

## CaseEvent

Journal chronologique visible ou interne.

- `id`
- `case_id`
- `actor_type`
- `actor_id` facultatif
- `event_type`
- `visibility` : user, support, system
- `title`
- `details`
- `metadata`
- `created_at`

Les événements importants ne doivent pas être modifiés après création. Une correction crée un nouvel événement.

## Evidence

- `id`
- `case_id`
- `document_id` facultatif
- `type`
- `title`
- `description`
- `external_reference` facultatif
- `verified_at` facultatif
- `created_at`

## Notification

- `id`
- `user_id`
- `case_id` facultatif
- `type`
- `title`
- `body`
- `deep_link`
- `scheduled_at`
- `sent_at`
- `read_at`
- `resolved_at`
- `created_at`

## Delegation

- `id`
- `household_id`
- `grantor_user_id`
- `grantee_user_id`
- `scope`
- `starts_at`
- `ends_at`
- `revoked_at`
- `created_at`

La délégation n’appartient pas au premier prototype, mais le modèle doit éviter de la rendre impossible.

# Règles d’intégrité

1. Un dossier appartient à un seul foyer.
2. Un document appartient à un dossier, sauf documents réutilisables explicitement gérés à part.
3. Toute action engageante référence une validation valide.
4. Une validation porte sur un contenu figé.
5. Une exécution ne peut pas être marquée réussie sans date ni référence lorsque le canal en fournit une.
6. Un dossier marqué **Fait** doit avoir au moins une preuve ou une confirmation utilisateur explicite.
7. La suppression logique précède la suppression physique lorsque des obligations de preuve existent.
8. Les données d’analyse et les documents sources ont des durées de conservation distinctes.
9. Aucun secret technique n’est stocké dans les champs métier.
10. Toute modification d’une donnée sensible crée un événement d’audit.

# Catégories initiales

- courrier administratif ;
- contrat et abonnement ;
- assurance ;
- logement ;
- véhicule ;
- identité et documents officiels ;
- énergie et télécoms ;
- remboursement et réclamation ;
- autre.

# Données minimales pour créer un dossier

- utilisateur créateur ;
- foyer ;
- titre ou demande brute ;
- au moins un document ou un texte ;
- date de création ;
- étape interne.

Toutes les autres informations peuvent être enrichies progressivement.
