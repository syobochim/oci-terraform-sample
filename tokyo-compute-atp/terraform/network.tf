resource "oci_core_vcn" "demo_vcn" {
  compartment_id = "${var.compartment_ocid}"
  cidr_block = "172.16.0.0/16"
  display_name = "demo_vcn"
  dns_label      = "demovcnsys"
}

resource "oci_core_internet_gateway" "demo_ig" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "demo_ig"
  vcn_id = "${oci_core_vcn.demo_vcn.id}"
}

resource "oci_core_subnet" "demo_subnet_ap" {
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  cidr_block = "172.16.1.0/24"
  security_list_ids = ["${oci_core_vcn.demo_vcn.default_security_list_id}"]
  route_table_id = "${oci_core_vcn.demo_vcn.default_route_table_id}"
  vcn_id = "${oci_core_vcn.demo_vcn.id}"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = "${oci_core_vcn.demo_vcn.default_route_table_id}"
  route_rules {
    network_entity_id = "${oci_core_internet_gateway.demo_ig.id}"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = "${oci_core_internet_gateway.demo_ig.id}"
    destination = "134.70.0.0/17"
    destination_type = "CIDR_BLOCK"
  }
}
