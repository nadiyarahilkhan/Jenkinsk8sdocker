provider "google" {
  project     = "apt-memento-442605-f0"
  region      = "us-central1"
}

resource "google_container_cluster" "my-cluster" {
  name     = "my-cluster"
  location = "us-central1-a"

  initial_node_count = 3  # Set a valid number (e.g., 3)

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
