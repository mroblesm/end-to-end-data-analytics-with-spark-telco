/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/******************************************
Local variables declaration
 *****************************************/

locals {
project_id                  = "${var.gcp_project_id}"
admin_upn_fqn               = "${var.gcp_user_id}"
location                    = "${var.gcp_region}"
zone                        = "${var.gcp_zone}"
location_multi              = upper(substr("${local.location}",0,2))
umsa                        = "s8s-lab-sa"
umsa_fqn                    = "${local.umsa}@${local.project_id}.iam.gserviceaccount.com"
s8s_spark_bucket            = "s8s-spark-bucket-${local.project_id}"
s8s_spark_bucket_fqn        = "gs://s8s-spark-${local.project_id}"
s8s_spark_sphs_nm           = "s8s-sphs-${local.project_id}"
s8s_spark_sphs_bucket       = "s8s-sphs-${local.project_id}"
s8s_spark_sphs_bucket_fqn   = "gs://s8s-sphs-${local.project_id}"
vpc_nm                      = "s8s-vpc-${local.project_id}"
spark_subnet_nm             = "spark-snet"
spark_subnet_cidr           = "10.0.0.0/16"
psa_ip_length               = 16
s8s_data_bucket             = "s8s_data_bucket-${local.project_id}"
s8s_code_bucket             = "s8s_code_bucket-${local.project_id}"
s8s_model_bucket            = "s8s_model_bucket-${local.project_id}"
s8s_artifact_repository_nm  = "s8s-spark-${local.project_id}"
bq_datamart_ds              = "customer_churn_ds"
mnb_server_machine_type     = "n1-standard-4"
mnb_server_nm               = "s8s-spark-ml-interactive-nb-server"
CLOUD_COMPOSER2_IMG_VERSION = "composer-2.0.11-airflow-2.2.3"
SPARK_CONTAINER_IMG_TAG     = "1.0.0"
dpms_nm                     = "s8s-dpms-${local.project_id}"
bq_connector_jar_gcs_uri    = "gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.22.2.jar"
cloud_scheduler_timezone    = "America/Chicago"
is_out_qwiklabs             = true
}



/******************************************
 Enable Google APIs in parallel
 *****************************************/

resource "google_project_service" "enable_orgpolicy_google_apis" {
  project = local.project_id
  service = "orgpolicy.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_compute_google_apis" {
  project = local.project_id
  service = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_container_google_apis" {
  project = local.project_id
  service = "container.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_containerregistry_google_apis" {
  project = local.project_id
  service = "containerregistry.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_dataproc_google_apis" {
  project = local.project_id
  service = "dataproc.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_bigquery_google_apis" {
  project = local.project_id
  service = "bigquery.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_storage_google_apis" {
  project = local.project_id
  service = "storage.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_notebooks_google_apis" {
  project = local.project_id
  service = "notebooks.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_aiplatform_google_apis" {
  project = local.project_id
  service = "aiplatform.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_logging_google_apis" {
  project = local.project_id
  service = "logging.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_monitoring_google_apis" {
  project = local.project_id
  service = "monitoring.googleapis.com"
  disable_dependent_services = true
  
}
resource "google_project_service" "enable_servicenetworking_google_apis" {
  project = local.project_id
  service = "servicenetworking.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_cloudbuild_google_apis" {
  project = local.project_id
  service = "cloudbuild.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_artifactregistry_google_apis" {
  project = local.project_id
  service = "artifactregistry.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_cloudresourcemanager_google_apis" {
  project = local.project_id
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
  
}

resource "google_project_service" "enable_composer_google_apis" {
  project = local.project_id
  service = "composer.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_functions_google_apis" {
  project = local.project_id
  service = "cloudfunctions.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_pubsub_google_apis" {
  project = local.project_id
  service = "pubsub.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_dpms_google_apis" {
  project = local.project_id
  service = "metastore.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_cloudrun_admin_google_apis" {
  project = local.project_id
  service = "run.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "enable_cloudscheduler_google_apis" {
  project = local.project_id
  service = "cloudscheduler.googleapis.com"
  disable_dependent_services = true
}



/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_api_enabling" {
  create_duration = "300s"
  depends_on = [
    google_project_service.enable_orgpolicy_google_apis,
    google_project_service.enable_compute_google_apis,
    google_project_service.enable_container_google_apis,
    google_project_service.enable_containerregistry_google_apis,
    google_project_service.enable_dataproc_google_apis,
    google_project_service.enable_bigquery_google_apis,
    google_project_service.enable_storage_google_apis,
    google_project_service.enable_servicenetworking_google_apis,
    google_project_service.enable_aiplatform_google_apis,
    google_project_service.enable_notebooks_google_apis,
    google_project_service.enable_cloudbuild_google_apis,
    google_project_service.enable_artifactregistry_google_apis,
    google_project_service.enable_cloudresourcemanager_google_apis,
    google_project_service.enable_composer_google_apis,
    google_project_service.enable_functions_google_apis,
    google_project_service.enable_pubsub_google_apis,
    google_project_service.enable_cloudrun_admin_google_apis,
    google_project_service.enable_dpms_google_apis,
    google_project_service.enable_cloudscheduler_google_apis
  ]
}


/******************************************
 Prepare environment (only Qwiklabs)
 *****************************************/

resource "null_resource" "install_gcloud" {
  count = local.is_out_qwiklabs ? 0 : 1
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "rm -rf /root/google-cloud-sdk; curl https://sdk.cloud.google.com > install.sh; bash install.sh --disable-prompts; source /root/google-cloud-sdk/path.bash.inc"
  }
  depends_on = [time_sleep.sleep_after_api_enabling]
}



resource "null_resource" "install_docker" {
  count = local.is_out_qwiklabs ? 0 : 1
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh"
  }
  depends_on = [time_sleep.sleep_after_api_enabling,null_resource.install_gcloud]
}


resource "null_resource" "install_wget" {
  count = local.is_out_qwiklabs ? 0 : 1
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "apt-get update &&  apt-get install wget"
  }
  depends_on = [time_sleep.sleep_after_api_enabling,null_resource.install_wget]
}





/******************************************
Create User Managed Service Account (UMSA)
 *****************************************/
module "umsa_creation" {
  source     = "terraform-google-modules/service-accounts/google"
  project_id = local.project_id
  names      = ["${local.umsa}"]
  display_name = "User Managed Service Account"
  description  = "User Managed Service Account for Serverless Spark"
  depends_on = [time_sleep.sleep_after_api_enabling,null_resource.install_gcloud,null_resource.install_docker,null_resource.install_wget]
}



/******************************************
Grant IAM roles to User Managed Service Account
 *****************************************/

module "umsa_role_grants" {
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${local.umsa_fqn}"
  prefix                  = "serviceAccount"
  project_id              = local.project_id
  project_roles = [
    
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/storage.objectAdmin",
    "roles/storage.admin",
    "roles/metastore.admin",
    "roles/metastore.editor",
    "roles/dataproc.worker",
    "roles/bigquery.dataEditor",
    "roles/bigquery.admin",
    "roles/dataproc.editor",
    "roles/artifactregistry.writer",
    "roles/logging.logWriter",
    "roles/cloudbuild.builds.editor",
    "roles/aiplatform.admin",
    "roles/aiplatform.viewer",
    "roles/aiplatform.user",
    "roles/viewer",
    "roles/composer.worker",
    "roles/composer.admin",
    "roles/cloudfunctions.admin",
    "roles/cloudfunctions.serviceAgent",
    "roles/cloudscheduler.serviceAgent"


  ]
  depends_on = [
    module.umsa_creation
  ]
}






/******************************************************
Grant Service Account Impersonation privilege to yourself/Admin User
 ******************************************************/

module "umsa_impersonate_privs_to_admin" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam/"
  service_accounts = ["${local.umsa_fqn}"]
  project          = local.project_id
  mode             = "additive"
  bindings = {
    "roles/iam.serviceAccountUser" = [
      "user:${local.admin_upn_fqn}"
    ],
    "roles/iam.serviceAccountTokenCreator" = [
      "user:${local.admin_upn_fqn}"
    ]

  }
  depends_on = [
    module.umsa_creation
  ]
}

/******************************************************
Grant IAM roles to Admin User/yourself
 ******************************************************/

module "administrator_role_grants" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = ["${local.project_id}"]
  mode     = "additive"

  bindings = {
    "roles/storage.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/metastore.admin" = [

      "user:${local.admin_upn_fqn}",
    ]
    "roles/dataproc.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.user" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.dataEditor" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.jobUser" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/composer.environmentAndStorageObjectViewer" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/iam.serviceAccountUser" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/iam.serviceAccountTokenCreator" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/composer.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/aiplatform.user" = [
      "user:${local.admin_upn_fqn}",
    ]
     "roles/aiplatform.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
     "roles/compute.networkAdmin" = [
      "user:${local.admin_upn_fqn}",
    ]
  }
  depends_on = [
    module.umsa_role_grants,
    module.umsa_impersonate_privs_to_admin
  ]
  }

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_identities_permissions" {
  create_duration = "120s"
  depends_on = [
    module.umsa_creation,
    module.umsa_role_grants,
    module.umsa_impersonate_privs_to_admin,
    module.administrator_role_grants,
    #module.gmsa_role_grants_cc,
    #google_project_iam_member.grant_saagent_default_composer,
    #google_project_iam_member.grant_editor_default_compute
  ]
}

/************************************************************************
Create VPC network, subnet & reserved static IP creation
 ***********************************************************************/
module "vpc_creation" {
  source                                 = "terraform-google-modules/network/google"
  project_id                             = local.project_id
  network_name                           = local.vpc_nm
  routing_mode                           = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.spark_subnet_nm}"
      subnet_ip             = "${local.spark_subnet_cidr}"
      subnet_region         = "${local.location}"
      subnet_range          = local.spark_subnet_cidr
      subnet_private_access = true
    }
  ]
  depends_on = [
    time_sleep.sleep_after_identities_permissions
  ]
}

resource "google_compute_global_address" "reserved_ip_for_psa_creation" { 
  provider      = google
  name          = "private-service-access-ip"
  purpose       = "VPC_PEERING"
  network       =  "projects/${local.project_id}/global/networks/s8s-vpc-${local.project_id}"
  address_type  = "INTERNAL"
  prefix_length = local.psa_ip_length
  
  depends_on = [
    module.vpc_creation
  ]
}

resource "google_service_networking_connection" "private_connection_with_service_networking" {
  network                 =  "projects/${local.project_id}/global/networks/s8s-vpc-${local.project_id}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.reserved_ip_for_psa_creation.name]

  depends_on = [
    module.vpc_creation,
    google_compute_global_address.reserved_ip_for_psa_creation
  ]
}

/******************************************
Create Firewall rules 
 *****************************************/

resource "google_compute_firewall" "allow_intra_snet_ingress_to_any" {
  project   = local.project_id 
  name      = "allow-intra-snet-ingress-to-any"
  network   = local.vpc_nm
  direction = "INGRESS"
  source_ranges = [local.spark_subnet_cidr]
  allow {
    protocol = "all"
  }
  description        = "Creates firewall rule to allow ingress from within Spark subnet on all ports, all protocols"
  depends_on = [
    module.vpc_creation, 
    module.administrator_role_grants
  ]
}

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_network_and_firewall_creation" {
  create_duration = "120s"
  depends_on = [
    module.vpc_creation,
    google_compute_firewall.allow_intra_snet_ingress_to_any
  ]
}

/******************************************
Create Storage bucket 
 *****************************************/

resource "google_storage_bucket" "s8s_spark_bucket_creation" {
  project                           = local.project_id 
  name                              = local.s8s_spark_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation
  ]
}

resource "google_storage_bucket" "s8s_spark_sphs_bucket_creation" {
  project                           = local.project_id 
  name                              = local.s8s_spark_sphs_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation
  ]
}

resource "google_storage_bucket" "s8s_data_bucket_creation" {
  project                           = local.project_id 
  name                              = local.s8s_data_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation
  ]
}

resource "google_storage_bucket" "s8s_code_bucket_creation" {
  project                           = local.project_id 
  name                              = local.s8s_code_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation
  ]
}

resource "google_storage_bucket" "s8s_model_bucket_creation" {
  project                           = local.project_id 
  name                              = local.s8s_model_bucket
  location                          = local.location
  uniform_bucket_level_access       = true
  force_destroy                     = true
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation
  ]
}



/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_bucket_creation" {
  create_duration = "60s"
  depends_on = [
    google_storage_bucket.s8s_data_bucket_creation,
    google_storage_bucket.s8s_code_bucket_creation,
    google_storage_bucket.s8s_spark_sphs_bucket_creation,
    google_storage_bucket.s8s_spark_bucket_creation
  ]
}



/******************************************
Copy of datasets, scripts and notebooks to buckets
 ******************************************/

resource "google_storage_bucket_object" "datasets_upload_to_gcs" {
  for_each = fileset("${path.module}/datasets/", "*")
  source = "${path.module}/datasets/${each.value}"
  name = "${each.value}"
  bucket = "${local.s8s_data_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation
  ]
}

resource "google_storage_bucket_object" "scripts_dir_upload_to_gcs" {
  for_each = fileset("${path.module}/scripts-hydrated/", "*")
  source = "${path.module}/scripts-hydrated/${each.value}"
  name = "${each.value}"
  bucket = "${local.s8s_code_bucket}"
  depends_on = [
    time_sleep.sleep_after_bucket_creation
  ]
}



/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/

resource "time_sleep" "sleep_after_network_and_storage_steps" {
  create_duration = "120s"
  depends_on = [
      time_sleep.sleep_after_network_and_firewall_creation,
      time_sleep.sleep_after_bucket_creation,
      google_project_service.enable_notebooks_google_apis,
      google_storage_bucket_object.datasets_upload_to_gcs,
      google_storage_bucket_object.scripts_dir_upload_to_gcs
  ]
}

/******************************************
PHS creation
******************************************/

resource "google_dataproc_cluster" "sphs_creation" {
  project  = local.project_id 
  provider = google
  name     = local.s8s_spark_sphs_nm
  region   = local.location

  cluster_config {
    
    endpoint_config {
        enable_http_port_access = true
    }

    staging_bucket = local.s8s_spark_bucket
    
    # Override or set some custom properties
    software_config {
      image_version = "2.0"
      override_properties = {
        "dataproc:dataproc.allow.zero.workers"=true
        "dataproc:job.history.to-gcs.enabled"=true
        "spark:spark.history.fs.logDirectory"="${local.s8s_spark_sphs_bucket_fqn}/*/spark-job-history"
        "mapred:mapreduce.jobhistory.read-only.dir-pattern"="${local.s8s_spark_sphs_bucket_fqn}/*/mapreduce-job-history/done"
      }      
    }
    gce_cluster_config {
      subnetwork =  "projects/${local.project_id}/regions/${local.location}/subnetworks/${local.spark_subnet_nm}" 
      service_account = local.umsa_fqn
      service_account_scopes = [
        "cloud-platform"
      ]
    }
  }
  depends_on = [
    module.administrator_role_grants,
    module.vpc_creation,
    time_sleep.sleep_after_api_enabling,
    time_sleep.sleep_after_network_and_storage_steps
  ]  
}

/******************************************
BigQuery dataset creation and table creation
******************************************/

resource "google_bigquery_dataset" "bq_dataset_creation" {
  dataset_id                  = local.bq_datamart_ds
  location                    = local.location_multi
  depends_on = [
    module.administrator_role_grants,
    module.vpc_creation,
    time_sleep.sleep_after_api_enabling,
    time_sleep.sleep_after_network_and_storage_steps
  ]  
}


resource "google_bigquery_table"  "train_data" {
  dataset_id = google_bigquery_dataset.bq_dataset_creation.dataset_id
  table_id   = "training_data_step_3_external"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"

    csv_options {
      quote = ""
      skip_leading_rows = 1
    }

    source_uris = [
      "gs://${local.s8s_data_bucket}/telco_customer_refined_data.csv"
    ]
  }
  depends_on = [google_bigquery_dataset.bq_dataset_creation]  

}


resource "random_id" "bq_job_id" {
  byte_length = 8
}

resource "google_bigquery_job" "materialize_table" {
  job_id     = "materialize_table_job_query-${random_id.bq_job_id.id}"
  query {
    query = "SELECT cast (customer_id	as STRING)	customer_id,cast (gender	as STRING)	gender,cast (senior_citizen	as INT64)	senior_citizen,cast (partner	as STRING)	partner	,cast (dependents	as STRING)	dependents,cast (tenure as STRING) tenure,cast (tenure_group	as STRING)	tenure_group	,cast (phone_service	as STRING)	phone_service	,cast (multiple_lines	as STRING)	multiple_lines	,cast (internet_service	as STRING)	internet_service	,cast (online_security	as STRING)	online_security	,cast (online_backup	as STRING)	online_backup	,cast (device_protection	as STRING)	device_protection	,cast (tech_support	as STRING)	tech_support,cast (streaming_tv	as STRING)	streaming_tv,cast (streaming_movies	as STRING)	streaming_movies,cast (contract	as STRING)	contract,cast (paperless_billing	as STRING)	paperless_billing	,cast (payment_method	as STRING)	payment_method,cast (monthly_charges	as FLOAT64 )	monthly_charges,cast (total_charges	as FLOAT64)	total_charges,cast (churn	as STRING) churn FROM customer_churn_ds.training_data_step_3_external"
    destination_table {
      project_id = local.project_id
      dataset_id = google_bigquery_dataset.bq_dataset_creation.dataset_id
      table_id   = "training_data_step_3"
    }

    allow_large_results = true
    

  }
  depends_on = [google_bigquery_table.train_data]  
}





/********************************************************
Artifact registry for Serverless Spark custom container images
********************************************************/

resource "google_artifact_registry_repository" "artifact_registry_creation" {
    location          = local.location
    repository_id     = local.s8s_artifact_repository_nm
    description       = "Artifact repository"
    format            = "DOCKER"
    depends_on = [
        module.administrator_role_grants,
        module.vpc_creation,
        google_project_service.enable_artifactregistry_google_apis,
        time_sleep.sleep_after_network_and_storage_steps
    ]  
}

/********************************************************
Create Docker Container image for Serverless Spark
********************************************************/


resource "null_resource" "custom_container_image_creation" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "source /root/google-cloud-sdk/path.bash.inc; chmod +x ${path.module}/scripts-hydrated/build-container-image.sh; ${path.module}/scripts-hydrated/build-container-image.sh ${local.SPARK_CONTAINER_IMG_TAG} ${local.bq_connector_jar_gcs_uri} ${local.location}"
  
  }
  triggers = {
    build_number = "${timestamp()}"
    script_sha1  = sha1(file("${path.module}/scripts-hydrated/build-container-image.sh")),
  }
  depends_on = [
        module.administrator_role_grants,
        module.vpc_creation,
        google_project_service.enable_artifactregistry_google_apis,
        time_sleep.sleep_after_network_and_storage_steps,
        google_artifact_registry_repository.artifact_registry_creation
    ]  
}


resource "null_resource" "serving_container_image_creation" {
    provisioner "local-exec" {
      interpreter = ["bash", "-exc"]
        command     = "source /root/google-cloud-sdk/path.bash.inc; chmod +x ${path.module}/scripts-hydrated/build-serving-image.sh; ${path.module}/scripts-hydrated/build-serving-image.sh  ${local.location}"
  
    }
    triggers = {
    build_number = "${timestamp()}"
    script_sha1  = sha1(file("${path.module}/scripts-hydrated/build-serving-image.sh")),
  }
    depends_on = [
        module.administrator_role_grants,
        module.vpc_creation,
        google_project_service.enable_artifactregistry_google_apis,
        time_sleep.sleep_after_network_and_storage_steps,
        google_artifact_registry_repository.artifact_registry_creation
    ]  
}



/******************************************
Output important variables needed for the lab
******************************************/

output "PROJECT_ID" {
  value = local.project_id
}

output "PROJECT_NBR" {
  value = local.project_id
}

output "LOCATION" {
  value = local.location
}

output "VPC_NM" {
  value = local.vpc_nm
}

output "SPARK_SERVERLESS_SUBNET" {
  value = local.spark_subnet_nm
}

output "PERSISTENT_HISTORY_SERVER_NM" {
  value = local.s8s_spark_sphs_nm
}

output "DPMS_NM" {
  value = local.dpms_nm
}

output "UMSA_FQN" {
  value = local.umsa_fqn
}

output "DATA_BUCKET" {
  value = local.s8s_data_bucket
}

output "CODE_BUCKET" {
  value = local.s8s_code_bucket
}


/******************************************
DONE
******************************************/
