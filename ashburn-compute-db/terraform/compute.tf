resource "oci_core_instance" "uga_instance" {
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  shape = "VM.Standard2.2"
  display_name = "uga_ap1"
  preserve_boot_volume = false
  create_vnic_details {
      subnet_id = "${oci_core_subnet.uga_subnet_ap.id}"
  }
  source_details {
      source_type = "image"
      source_id = "ocid1.image.oc1.iad.aaaaaaaarsu56scul4muz3sqbptvykipy2rn6re3wzdjvncgcpgqt5cp3wja" //CentOS7 https://docs.cloud.oracle.com/iaas/images/
  }
  metadata {
      ssh_authorized_keys = "${file("${var.ssh_public_key_path}")}"
  }
}

output "public_ip_of_ap" {
  value = "${oci_core_instance.uga_instance.public_ip}"
}
