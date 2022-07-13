variable "environment" {
  description = "Name of the environment."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "n/a"
}

variable "release_version" {
  description = "Version of the infrastructure automation"
  type        = string
  default     = "latest"
}

variable "location_hub" {
  description = "Azure location of the hub"
  type        = string
  default     = "northeurope"
}
variable "location_spoke1" {
  description = "Azure location of the spoke1"
  type        = string
  default     = "swedencentral"
}
variable "location_spoke2" {
  description = "Azure location of the spoke2"
  type        = string
  default     = "switzerlandnorth"
}

variable "location_acr" {
  description = "Azure long naame of the acr location"
  type        = string
  default     = "swedencentral"
}

# Todo could be a list (for multiple replicas)
variable "location_acr_replica" {
  description = "Azure long naame of the acr replica location"
  type        = string
  default     = "switzerlandnorth"
}

variable "acr_name_prefix" {
  description = "Change this otherwise it conflicts with other users (globally unique)"
  type        = string
  default     = "xyzdfd"
}

