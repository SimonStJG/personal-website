provider "google" {
  project = "data-dragon-291407"
  region  = "eu-west2"
  zone    = "eu-west2a"
  version = "3.41.0"
}

terraform {
  required_version = "0.13.3"
  backend "gcs" {
    bucket = "data-dragon-291407-tfstate"
    prefix = "tfstate"
  }
}

locals {
  # Google has given me this silly name automatically, because I wasn't paying attention.  It's cute though, so why
  #  change it :)
  project = "data-dragon-291407"
  region  = "europe-west2"
}

resource "google_project_service" "storage" {
  project                    = local.project
  service                    = "storage.googleapis.com"
  disable_dependent_services = true
}

resource "google_storage_bucket" "website" {
  name                        = "www.simonstjg.org"
  location                    = local.region
  uniform_bucket_level_access = true
  website {
    main_page_suffix = "index.html"
  }
  depends_on = [google_project_service.storage]
}

resource "google_storage_bucket_object" "index" {
  bucket           = google_storage_bucket.website.name
  name             = "index.html"
  source           = "../public/index.html"
  content_type     = "text/html"
  content_encoding = "utf-8"
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
