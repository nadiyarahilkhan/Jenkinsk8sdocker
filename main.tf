provider "google" {
  project     = "apt-memento-442605-f0"
  region      = "us-central1"
}

resource "google_container_cluster" "my-cluster" {
  name     = "my-cluster"
  location = "us-central1-a"
}
