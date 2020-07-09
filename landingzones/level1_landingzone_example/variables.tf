# Map of the remote data state filled by the rover at runtime
variable "lowerlevel_storage_account_name" {}
variable "lowerlevel_container_name" {}
variable "lowerlevel_key" {} # Keeping the key for the lower level0 access
variable "lowerlevel_resource_group_name" {}
# Set of variables for the CAF foundations landing zone
variable "tags" {
  type    = map
  default = {}
}
# Couple of settings for demonstration
variable "policy" {
  type    = map
  default = {}
}

variable prefix {
  description = "(Optional) By default CAF Foundation gets the prefix from the launchpad. You can overwride it by setting a value."
  default     = null
}

variable "location" {
  description = "The Azure location for the example landing zone."
}