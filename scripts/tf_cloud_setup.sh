# Variables
ENV=$1

PROJECT_ID=$(gcloud projects list --filter="name=$ENV" --format="value(projectId)")
PROJECT_NUMBER=$(gcloud projects list --filter="name=$ENV" --format="value(projectNumber)")
ORG_NAME="aviatar-challenge"
IDENTITY="tf-cloud"
SERVICE_ACCOUNT_NAME="terraform"
SERVICE_ACCOUNT_ID="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

ROLES=(
  "roles/servicenetworking.networksAdmin"
  "roles/pubsub.admin"
  "roles/run.admin"
  "roles/artifactregistry.admin"
  "roles/iam.serviceAccountUser"
  "roles/iam.serviceAccountCreator"
  "roles/secretmanager.admin"
  "roles/compute.admin"
  "roles/cloudscheduler.admin"
  "roles/dataflow.admin"
  "roles/storage.admin"
  "roles/bigquery.admin"
  "roles/bigquery.dataOwner"
  "roles/bigquery.dataEditor"
  "roles/bigquery.jobUser"
)

gcloud config set project $PROJECT_ID

if ! gcloud iam workload-identity-pools describe $IDENTITY --location="global" > /dev/null 2>&1; then
  gcloud iam workload-identity-pools create $IDENTITY \
    --location="global" \
    --description="Allow tf cloud to connect to GCP" \
    --display-name="$IDENTITY"
else
  echo ""
fi

if ! gcloud iam workload-identity-pools providers describe $IDENTITY \
    --location="global" \
    --workload-identity-pool="$IDENTITY" \
    --issuer-uri="https://app.terraform.io" > /dev/null 2>&1; then
  gcloud iam workload-identity-pools providers create-oidc $IDENTITY \
    --location="global" \
    --workload-identity-pool="$IDENTITY" \
    --issuer-uri="https://app.terraform.io" \
    --attribute-mapping="google.subject=assertion.sub,attribute.terraform_workspace_name=assertion.terraform_workspace_name" \
    --attribute-condition="assertion.terraform_organization_name==\"$ORG_NAME\""
else
  echo ""
fi

if ! gcloud iam service-accounts describe $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com > /dev/null 2>&1; then
  gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="$SERVICE_ACCOUNT_NAME"
else
  echo ""
fi

for ROLE in "${ROLES[@]}"; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member "$SERVICE_ACCOUNT_ID" \
    --role "$ROLE"
done

case "$ENV" in
  development) SHORT_ENV="dev" ;;
  staging) SHORT_ENV="stg" ;;
  production) SHORT_ENV="prd" ;;
  *) 
    echo "Error: Invalid ENV value '$ENV'. Expected development, staging, or production."
    exit 1
    ;;
esac

gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$IDENTITY/attribute.terraform_workspace_name/aviatar-$SHORT_ENV"
