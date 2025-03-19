# Terraform CI/CD Workflow

This document outlines the steps involved in our Terraform CI/CD workflow, designed to automate infrastructure changes using GitHub Actions.

**Workflow Trigger:**

* **PR Check:** Initiated upon the creation or update of a Pull Request (PR).
* **Push MAIN:** Triggered when changes are pushed directly to the `main` branch.

**Workflow Steps:**

1.  **REPO CHECKOUT:**
    * **Action:** `actions/checkout@v3`
    * **Description:** This step retrieves the latest code from the repository. It ensures the workflow has access to the Terraform configuration files and any associated scripts.
    * **Context:**  Check out code from `DEV`, `STAGING`, or `MAIN` branches, indicating the workflow supports multiple environments

2.  **GCLOUD SA AUTH:**
    * **Action:** `uses: google-github-actions/auth@v2`
    * **Description:** This step authenticates with Google Cloud Platform (GCP) using a service account. This allows Terraform to interact with GCP resources.
    * **Context:**  Workload Identity Pool," use of Google's recommended method for service account authentication in GitHub Actions.

3.  **TERRAFORM SET UP INIT:**
    * **Action:** `uses: hashicorp/setup-terraform@v3`
    * **Action:** `run: terraform init`
    * **Description:**
        * The `hashicorp/setup-terraform` action installs the Terraform CLI.
        * `terraform init` initializes the Terraform working directory. It downloads provider plugins and sets up the backend configuration.
    * **Context:** "TFC TOKEN"  uses Terraform Cloud for remote state management, requiring a token for authentication.

4.  **TERRAFORM FMT:**
    * **Action:** `run: terraform fmt -check`
    * **Description:** This step formats the Terraform code according to the HashiCorp style guide and checks if any files are not formatted correctly.
    * **Context:** The `-check` flag ensures the workflow fails if formatting issues are found, promoting code consistency.

5.  **TERRAFORM VALIDATION:**
    * **Action:** `run: terraform validate`
    * **Description:** This step validates the Terraform configuration files for syntax errors and internal consistency.
    * **Context:** It ensures the configuration is syntactically correct before proceeding with further steps.

6.  **TERRAFORM TEST:**
    * **Action:** `terraform test -verbose`
    * **Description:** Executes terraform tests. This step validates the functionality of the terraform code.
    * **Context:** The `-verbose` flag shows detailed test output.

7.  **TERRAFORM PLAN:**
    * **Action:** `terraform plan`
    * **Description:** This step generates an execution plan, showing the changes Terraform will make to the infrastructure.
    * **Context:** This step allows for a review of changes before they are applied, crucial for preventing unintended modifications.

8.  **TERRAFORM APPLY:**
    * **Action:** `terraform apply`
    * **Description:** This step applies the changes defined in the execution plan, provisioning or modifying the infrastructure.
    * **Context:** This step is typically executed only when pushing to the `main` branch or after a manual approval process in a PR.

**ERROR EXIT:**

* **Description:** Indicates that the workflow will terminate if any of the preceding steps fail.
* **Context:** This ensures that errors are caught early in the process, preventing further execution and potential damage.

**Important Note:**

While the diagram primarily depicts the workflow triggered by Pull Requests and pushes to the `main` branch, it's important to note that pushes to the `staging` or `dev` branches will trigger the PR CHECK, then when merged, auto apply workflow will be trigger. This workflow will execute all the steps outlined above, including the `terraform apply` step, without requiring manual approval. This allows for automated deployments to staging and development environments for rapid iteration and testing.

When PR is merged in MAIN, manual action is need running a workflow dispatch. This workflow dispatch will get the output file from the previous plan and apply the changes, this way we don't need to run all the steps again
And the prod deployment is faster.