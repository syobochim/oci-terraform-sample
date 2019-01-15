resource "oci_core_vcn" "uga_vcn" {
  compartment_id = "${var.compartment_ocid}"
  cidr_block = "172.16.0.0/16"
  display_name = "uga_vcn"
  dns_label      = "ugavcnsys"
}

resource "oci_core_internet_gateway" "uga_ig" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "uga_ig"
  vcn_id = "${oci_core_vcn.uga_vcn.id}"
}

resource "oci_core_subnet" "uga_subnet_ap" {
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  cidr_block = "172.16.1.0/24"
  security_list_ids = ["${oci_core_vcn.uga_vcn.default_security_list_id}"]
  route_table_id = "${oci_core_vcn.uga_vcn.default_route_table_id}"
  vcn_id = "${oci_core_vcn.uga_vcn.id}"
}

resource "oci_core_subnet" "uga_subnet_db" {
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  cidr_block = "172.16.2.0/24"
  security_list_ids = ["${oci_core_security_list.uga_db_security_list.id}"]
  route_table_id = "${oci_core_vcn.uga_vcn.default_route_table_id}"
  vcn_id = "${oci_core_vcn.uga_vcn.id}"
  dns_label = "ugasubdbsys"    // 指定しないとDB作成時にエラーが発生
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = "${oci_core_vcn.uga_vcn.default_route_table_id}"
  route_rules {
    network_entity_id = "${oci_core_internet_gateway.uga_ig.id}"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = "${oci_core_internet_gateway.uga_ig.id}"
    destination = "134.70.0.0/17"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "uga_db_security_list" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_vcn.uga_vcn.id}"
    display_name = "uga_db_security_list"
    ingress_security_rules {
      protocol = "6"  //TCP
      source = "0.0.0.0/0"
      tcp_options {
        max = 22
        min = 22
      }
    }
    ingress_security_rules {
      protocol = "6" //TCP
      source = "172.16.1.0/24"  // subnet ap
      tcp_options {
        max = 1521
        min = 1521
      }
    }
    egress_security_rules {
      protocol = "6" //TCP
      destination = "134.70.0.0/17"  // object storage
      tcp_options {
        max = 443
        min = 443
      }
    }
}

data "oci_core_services" "sg_services" {
  filter {
    name   = "name"
    values = [".*Object.*Storage"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "uga_service_gateway" {
  compartment_id = "${var.compartment_ocid}"
  services {
    service_id = "${lookup(data.oci_core_services.sg_services.services[0], "id")}"
  }
  vcn_id = "${oci_core_vcn.uga_vcn.id}"
}

resource "oci_core_route_table" "sg_route_table" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.uga_vcn.id}"
  display_name   = "sgRouteTable"
  route_rules {
    destination       = "${lookup(data.oci_core_services.sg_services.services[0], "cidr_block")}"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = "${oci_core_service_gateway.uga_service_gateway.id}"
  }
}