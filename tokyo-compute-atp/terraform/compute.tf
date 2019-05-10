resource "oci_core_instance" "demo_instance" {
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  shape = "VM.Standard2.2"
  display_name = "demo_ap1"
  preserve_boot_volume = false
  create_vnic_details {
      subnet_id = "${oci_core_subnet.demo_subnet_ap.id}"
  }
  source_details {
      source_type = "image"
      source_id = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaairi7u3txkamxlw3kmw3dosbesrlm22vsh7yybhygzafd3awhlr5q" //Oracle Linux 7.X https://docs.cloud.oracle.com/iaas/images/
  }
  metadata {
      ssh_authorized_keys = "${file("${var.ssh_public_key_path}")}"
  }
}

output "public_ip_of_ap" {
  value = "${oci_core_instance.demo_instance.public_ip}"
}
