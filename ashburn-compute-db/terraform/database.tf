resource "oci_database_db_system" "uga_db" {
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  database_edition = "${var.db_edition}"
  shape = "VM.Standard2.2"
  ssh_public_keys = ["${file("${var.ssh_public_key_path}")}"]
  subnet_id = "${oci_core_subnet.uga_subnet_db.id}"
  hostname = "${var.hostname}"
  node_count = 1
  data_storage_size_in_gb = 512  // must be one of [256, 512, 1024, 2048, 4096, 6144, 8192, 10240, 12288, 14336, 16384, 18432, 20480, 22528, 24576, 26624, 28672, 30720, 32768, 34816, 36864, 38912, 40960]
  db_home {
      database {
          admin_password = "${var.db_admin_password}"
          db_name = "${var.db_name}"
          pdb_name = "${var.pdb_name}"
          db_backup_config {
              auto_backup_enabled = true
          }
      }
      db_version = "${var.db_version}"
      display_name = "uga_db"
  }
}