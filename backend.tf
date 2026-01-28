terraform {
  # Explicitly using local backend for file locking
  backend "local" {
    path = "terraform.tfstate"
  }
}
