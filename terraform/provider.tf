variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "ssh_public_key_path" {}


provider "oci" {
  region = "${var.region}"
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
}

variable "availability_domain" {
  default = 1
}

variable "db_edition" {
  default = "ENTERPRISE_EDITION"
}

variable "db_admin_password" {
  default = "BEstrO0ng_#12"
}

variable "db_name" {
  default = "ugadb"
}

variable "db_version" {
  default = "18.0.0.0"
}

variable "pdb_name" {
  default = "pdbName"
}

variable "hostname" {
  default = "myoracledb"
}
