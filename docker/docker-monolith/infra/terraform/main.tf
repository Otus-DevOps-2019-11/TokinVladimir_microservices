provider "google" {
  # Версия провайдера
  version = "~> 2.15"

  # ID проекта
  project = var.project
  region  = var.region
}

module "app" {
  source          = "./modules/app"
  public_key_path = var.public_key_path
  zone            = var.zone
  app_disk_image  = var.app_disk_image
  private_key = var.private_key
}

module "vpc" {
  source        = "./modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}
