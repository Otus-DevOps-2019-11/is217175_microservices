variable "project" {
  type        = string
  description = "Project ID"
}

variable "region" {
  type        = string
  description = "Region"
  default     = "europe-west4"
}

variable "instance_count" {
  type        = number
  description = "Count of created compute instances"
  default     = 1
}

variable "machine_type" {
  type        = string
  description = "Type of creating machine"
  default     = "g1-small"
}

variable "zone" {
  type        = string
  description = "Zone"
}

variable "labels" {
  type        = map
  description = "Instance labels"
}

variable "disk_image" {
  type = string
  description = "Disk image"
}

variable "public_key_path" {
  type        = string
  description = "Path to the public key used for ssh access"
}
