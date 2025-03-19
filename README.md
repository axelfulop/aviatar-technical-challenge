# Terraform Infrastructure Repository

## Repository Structure
This repository is organized to manage infrastructure using Terraform Cloud. It follows a modular approach to ensure reusability and maintainability.

```
terraform/
  environments/
    dev/        # Development environment configuration
    stg/        # Staging environment configuration
    prd/        # Production environment configuration
  modules/
    artifact/        # Terraform module for managing artifacts
    bucket/          # Terraform module for cloud storage buckets
    cloudrun/        # Terraform module for Cloud Run services
    dataflow/        # Terraform module for Dataflow jobs
    networking/      # Terraform module for networking components (VPC, Subnets, etc.)
    secretsmanager/  # Terraform module for managing secrets
    topic/           # Terraform module for Pub/Sub topics
```
## Set UP
 We need to allow TF Cloud to create the GCP resources, so for security reasons, i decided to use a Workload identity pool. This cfg could be done manually or with /scripts/tf_cloud_setup.sh
 
 Then we will save ENV VARS in TF CLOUD that will allow us create resources based in the roles assgined to the Service Account created
```
TFC_GCP_PROVIDER_AUTH
TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL
TFC_GCP_WORKLOAD_PROVIDER_NAME
```

## CI/CD
Terraform Cloud allow speculative plans based on workdirs and paths. For non prod envs we can set auto apply and for prod manual intervention needs.

All the env vars are saved in each workspaces, they could be sensitive or nor


## Environments
Each environment (`dev`, `stg`, `prd`) contains its own Terraform configuration to maintain separation between development, staging, and production infrastructure.

## Modules
Modules encapsulate reusable Terraform configurations, making it easier to manage infrastructure components across different environments.

### Artifact Module
This module is used to create an Artifact Registry repository in Google Cloud.

#### Variables
- `location` (string, optional): The location of the repository.
- `repository_id` (string, required): The ID of the repository.
- `description` (string, optional): A description of the repository.
- `format` (string, required): The format of the repository (e.g., `DOCKER`, `MAVEN`, etc.).

#### Outputs
- `name`: The name of the created artifact repository.

#### Example Usage
```hcl
module "sensors_artifact" {
  source        = "../../modules/artifact"
  location      = "us-central1"
  repository_id = "sensors"
  description   = "Artifact repository for sensor data"
  format        = "DOCKER"
}
```

---

### Bucket Module
This module is used to create a Cloud Storage bucket in Google Cloud.

#### Variables
- `location` (string, required): The location of the storage bucket.
- `bucket_name` (string, required): The name of the storage bucket.
- `force_destroy` (bool, required): Whether to allow the bucket to be forcefully deleted.

#### Outputs
- `bucket_url`: The URL of the created bucket.

#### Example Usage
```hcl
module "storage_bucket" {
  source        = "../../modules/bucket"
  location      = "us-central1"
  bucket_name   = "my-storage-bucket"
  force_destroy = true
}
```

---

### Cloud Run Module
This module is used to deploy Cloud Run services and associated resources in Google Cloud.

#### Variables
- `services` (map): A map defining Cloud Run services, including region, cron schedules, and container specifications.
- `sa_name` (string): The name of the service account.
- `create_sa` (bool, optional): Whether to create a new service account.
- `project_id` (string): The Google Cloud project ID.
- `topic_id` (string, optional): The Pub/Sub topic ID for messaging.
- `sa_member` (string, optional): The service account member string.
- `secrets_map` (map, optional): A mapping of secrets to be used by Cloud Run services.

#### Outputs
- `cloud_run_service_urls`: A map of deployed Cloud Run service names to their URLs.

#### Example Usage
```hcl
module "cloudrun_service" {
  source     = "../../modules/cloudrun"
  services   = {
    "my-service" = {
      region             = "us-central1"
      cron_expression    = "*/5 * * * *"
      time_zone          = "UTC"
      scheduler_endpoint = "trigger"
      api_key            = "my-api-key"
      containers = [{
        image = "gcr.io/my-project/my-service:latest"
        env = [{
          name  = "MY_ENV_VAR"
          value = "some-value"
        }]
      }]
    }
  }
  sa_name      = "cloudrun-sa"
  create_sa    = true
  project_id   = "my-gcp-project"
  topic_id     = "my-topic"
}
```

---

### Dataflow Module
This module is used to deploy Dataflow jobs in Google Cloud, along with necessary service accounts and permissions.

#### Variables
- `project_id` (string, required): The Google Cloud project ID.
- `dataset_id` (string, required): The BigQuery dataset ID for Dataflow output.
- `dataflow_job_name` (string, required): The name of the Dataflow job.
- `region` (string, required): The region where the Dataflow job will be deployed.
- `gcs_path` (string, required): The GCS path to the Dataflow template.
- `gcs_temp` (string, required): The GCS temporary location for Dataflow.
- `parameters` (map, required): A map of parameters to pass to the Dataflow job.
- `network` (string, required): The network to use for the Dataflow job.
- `subnetwork` (string, required): The subnetwork to use for the Dataflow job.
- `machine_type` (string, optional): The machine type to use for Dataflow workers (defaults to null).
- `topic_id` (string, required): The Pub/Sub topic ID for Dataflow subscription.

#### Example Usage
```hcl
module "sensor_dataflow" {
  source             = "../../modules/dataflow"
  project_id         = "my-gcp-project"
  dataset_id         = "sensor_data"
  dataflow_job_name  = "sensor-streaming-job"
  region             = "us-central1"
  gcs_path           = "gs://my-templates/my-template.json"
  gcs_temp           = "gs://my-temp-bucket/temp"
  parameters         = {
    inputSubscription = "projects/my-gcp-project/subscriptions/input-subscription"
    outputTable       = "my-gcp-project:sensor_data.sensor_table"
  }
  network            = "default"
  subnetwork         = "regions/us-central1/subnetworks/default"
  machine_type       = "n1-standard-1"
  topic_id           = "sensor_data_topic"
}

---

### Networking Module
This module is used to create and configure networking components in Google Cloud, including VPC networks, subnetworks, and firewall rules.

#### Variables
- `name` (string, required): The name of the VPC network.
- `auto_create_subnetworks` (bool, optional): Whether to automatically create subnetworks in the VPC (defaults to `false`).
- `cidr_range` (string, required): The CIDR range for the subnetwork.
- `subnet_name` (string, required): The name of the subnetwork.
- `region` (string, optional): The region for the subnetwork (defaults to null).
- `private_ip_google_access` (bool, optional): Whether to enable private IP Google access for the subnetwork (defaults to `true`).
- `firewall_name` (string, required): The name of the firewall rule.
- `firewall_rules` (list(object), required): A list of firewall rules, each with `protocol` and optional `ports`.
- `source_ranges` (list(string), required): A list of source CIDR ranges for the firewall rule.
- `project_id` (string, required): The Google Cloud project ID.

#### Outputs
- `vpc_id`: The ID of the created VPC network.
- `subnet_id`: The ID of the created subnetwork.

#### Example Usage
```hcl
module "my_network" {
  source                     = "../../modules/networking"
  name                       = "my-vpc"
  auto_create_subnetworks    = false
  cidr_range                 = "10.10.0.0/16"
  subnet_name                = "my-subnet"
  region                     = "us-central1"
  private_ip_google_access   = true
  firewall_name              = "allow-internal"
  firewall_rules             = [
    {
      protocol = "tcp"
      ports    = ["80", "443"]
    },
    {
      protocol = "icmp"
    }
  ]
  source_ranges              = ["10.0.0.0/8"]
  project_id                 = "my-gcp-project"
}

---

### Secrets Manager Module
This module is used to create and manage secrets in Google Cloud Secret Manager.

#### Variables
- `labels` (map(string), optional): A map of labels to apply to the secrets (defaults to `{}`).
- `secrets` (map(string), required): A map of secret names to their corresponding secret data.

#### Outputs
- `secrets`: A map of secret names to their corresponding secret IDs.

#### Example Usage
```hcl
module "my_secrets" {
  source = "../../modules/secretsmanager"
  labels = {
    environment = "dev"
    owner       = "team-a"
  }
  secrets = {
    "api-key"    = "my-secret-api-key"
    "database-password" = "my-secret-database-password"
  }
}