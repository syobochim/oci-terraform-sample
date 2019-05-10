resource "oci_database_autonomous_database" "demo_autonomous_database" {
  compartment_id = "${var.compartment_ocid}"
  db_name = "mugajin" // max : 14 character
  cpu_core_count = 2
  data_storage_size_in_tbs = 1
  admin_password = "${var.atp_admin_password}"
}