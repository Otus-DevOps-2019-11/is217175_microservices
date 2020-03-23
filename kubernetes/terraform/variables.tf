variable project {
  type        = string
  description = "Project ID"
}

variable region {
  type        = string
  description = "Region"
  default     = "europe-west4"
}

variable zone {
  type        = string
  description = "Zone"
}

variable nodes-tag {
  type        = list(string)
  description = "List of nodes tags"
}

variable port-list {
  type        = list(string)
  description = "Allowed application ports"
}
