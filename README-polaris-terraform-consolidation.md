# Polaris GCP Terraform Consolidation Plan

## Objective

Bring all Polaris GCP resources under Terraform management by:

1. Reconciling drift for existing IaC-managed services.
2. Adding Terraform resources for manually created services and secrets.
3. Standardizing configuration for reproducible deployments.

---

## Scope

### Cloud Run services in scope (7)

1. `atos-ai-marketplace` *(new/manual)*
2. `admin-management-dev` *(new/manual)*
3. `agents-dev` *(new/manual)*
4. `keycloak-dev` *(existing, drift updates needed)*
5. `knowledge-mgmt-api-dev` *(existing, drift updates needed)*
6. `opensearch-vector-dev` *(existing, drift updates needed)*
7. `polaris-portal-dev` *(existing, drift updates needed)*

---

## Terraform changes required

## 1) Cloud Run services

### A. Create new Terraform resources/modules

Add Terraform definitions for:

- `atos-ai-marketplace`
- `admin-management-dev`
- `agents-dev`

Include:

- service name, region (`us-central1`)
- image URL
- service account
- CPU/memory
- container port
- timeout (`300s`)
- concurrency (`80`)
- min/max instances
- startup CPU boost
- ingress (`all`/public)
- VPC connector/network routing settings (as per existing landing zone pattern)
- env vars + secret references

### B. Update existing Terraform resources (drift reconciliation)

Update Terraform for:

- `keycloak-dev`
- `knowledge-mgmt-api-dev`
- `opensearch-vector-dev`
- `polaris-portal-dev`

Align code with deployed runtime values (image, scaling, cpu/memory, ports, timeout, startup boost, ingress, revision-affecting settings).

---

## 2) Secrets (Secret Manager)

Create Terraform `google_secret_manager_secret` resources for the following keys (if not already managed):

- `OPENSEARCH_INITIAL_ADMIN_PASSWORD`
- `admin-client-secret`
- `agent_db_url`
- `app_insights_con_str`
- `appinsights_conn_str`
- `bing-search-agent-id`
- `client_secret`
- `google-api-key`
- `knowledge_db_url`
- `marketp_url`
- `marketplace_SESSION_SECRET_KEY`
- `marketplace_client_secret`
- `openweather-api-key`
- `portal-auth-secret`
- `portal-client-secret`
- `postgres-admin-password-dev`
- `snow-pass`
- `snowflake-cortex-secret`
- `snowflake-password`

Also add:

- `google_secret_manager_secret_iam_member` bindings for each runtime service account needing access.
- Secret version handling pattern as per repo standard (manual value injection via pipeline/secure process).

---

## 3) IAM updates

Ensure least-privilege IAM for Cloud Run service accounts:

- Secret accessor roles on required secrets
- Artifact Registry read access
- Cloud SQL connectivity roles (where applicable)
- Any existing project-level bindings currently done manually to be codified

---

## 4) Storage buckets

Ensure Terraform coverage (create or reference existing):

- `bkt-prj-d-bu1-sample-base-marketplace-dev`
- `bkt-prj-d-bu1-sample-base-qopg-keycloak-providers-dev`
- `bkt-prj-d-bu1-sample-base-qopg-knowledge-data-dev`
- `bkt-prj-d-bu1-sample-base-qopg-opensearch-data-dev`

For services marked `NA`/blank bucket, no bucket resource needed unless app requires one.

---

## 5) Service-by-service target configuration (to reflect in Terraform)

### atos-ai-marketplace

- Image: `us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/ghcr-remote/in-atos-aara/atos-ai-marketplace:1.0.5`
- SA: `atos-ai-marketplace@prj-d-bu1-sample-base-qopg.iam.gserviceaccount.com`
- CPU/Memory: `2 / 4Gi`
- Port: `8000`
- Min/Max: `1/5`
- Startup CPU boost: enabled
- Ingress: public

### admin-management-dev

- Image: `us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/ghcr-remote/in-atos-aara/atos-ai-admin:1.0.10`
- SA: `admin-management-api@prj-d-bu1-sample-base-qopg.iam.gserviceaccount.com`
- CPU/Memory: `2 / 4Gi`
- Port: `8000`
- Min/Max: `1/5`
- Startup CPU boost: enabled
- Ingress: public

### agents-dev

- Image: `us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/ghcr-remote/in-atos-aara/atos-ai-agents:1.0.75`
- SA: `agents-dev@prj-d-bu1-sample-base-qopg.iam.gserviceaccount.com`
- CPU/Memory: `2 / 4Gi`
- Port: `8000`
- Min/Max: `1/5`
- Startup CPU boost: enabled
- Ingress: public

### keycloak-dev

- Image: `us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/quay-remote/keycloak/keycloak:26.4.0`
- SA: `keycloak-dev@prj-d-bu1-sample-base-qopg.iam.gserviceaccount.com`
- CPU/Memory: `2 / 4Gi`
- Port: `8080`
- Min/Max: `1/5`
- Startup CPU boost: disabled
- Ingress: public

### knowledge-mgmt-api-dev

- Image: `us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/ghcr-remote/in-atos-aara/atos-ai-knowledge-gemini:1.0.76`
- SA: `knowledge-mgmt-api-dev@prj-d-bu1-sample-base-qopg.iam.gserviceaccount.com`
- CPU/Memory: `4 / 8Gi`
- Port: `8000`
- Min/Max: `1/3`
- Startup CPU boost: disabled
- Ingress: public

### opensearch-vector-dev

- Image: `docker.io/opensearchproject/opensearch:2`
- SA: `opensearch-vector-dev@prj-d-bu1-sample-base-qopg.iam.gserviceaccount.com`
- CPU/Memory: `4 / 16Gi`
- Port: `9200`
- Min/Max: `1/1`
- Startup CPU boost: disabled
- Ingress: public

### polaris-portal-dev

- Image: `us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/ghcr-remote/in-atos-aara/atos-polaris-ai-portal:1.0.87`
- SA: `polaris-portal-dev@prj-d-bu1-sample-base-qopg.iam.gserviceaccount.com`
- CPU/Memory: `2 / 4Gi`
- Port: `3000`
- Min/Max: `1/3`
- Startup CPU boost: disabled
- Ingress: public

---

## 6) Artifact Registry / Remote repositories

Terraform must ensure both remote Artifact Registry repositories are managed and correctly referenced by Cloud Run services:

### Repositories

- `ghcr-remote`
- `quay-remote`

### Images currently used from `ghcr-remote`

- `in-atos-aara/atos-ai-admin`
- `in-atos-aara/atos-ai-agents`
- `in-atos-aara/atos-ai-knowledge`
- `in-atos-aara/atos-ai-knowledge-gemini`
- `in-atos-aara/atos-ai-marketplace`
- `in-atos-aara/atos-polaris-ai-portal`

### Images currently used from `quay-remote`

- `keycloak/keycloak` (used by `keycloak-dev`)

### Required Terraform actions

1. Ensure `google_artifact_registry_repository` (remote) resources exist for:
   - `ghcr-remote`
   - `quay-remote`
2. Ensure upstream credentials secret is configured for GHCR access:
   - Secret: `ghcr-pull-token`
3. Ensure IAM permissions allow runtime/service accounts to pull images from Artifact Registry.
4. Validate all Cloud Run image URLs point to the correct repository:
   - Polaris services → `ghcr-remote`
   - Keycloak → `quay-remote`

## Execution plan

1. **Create branch** for Terraform consolidation.
2. **Add new services** (`marketplace`, `admin-management`, `agents`) in modules/services layout.
3. **Update existing 4 services** to match deployed config.
4. **Add missing secrets + IAM bindings**.
5. **Import manually created resources** into Terraform state (`terraform import`).
6. Run `terraform fmt`, `validate`, `plan`.
7. Ensure plan is clean (or expected deltas only), then apply through pipeline.

---

## Definition of Done

- All 7 Cloud Run services represented in Terraform.
- All required secrets represented in Terraform metadata/resources.
- Required IAM bindings codified.
- `terraform plan` is clean against current environment.
- Code reviewed and merged with documentation updated.

---

## Notes / open confirmations

- Confirm whether both `app_insights_con_str` and `appinsights_conn_str` are needed (possible duplicate naming).
- Confirm whether secret values are rotated/provided via CI/CD secret injection process.
- Confirm VPC connector resource name to be referenced by all Cloud Run services.
- `ghcr-pull-token` is already present and should remain Terraform-managed.
- If repository resources already exist in Terraform, reconcile configuration and import state for drift-free plan.
