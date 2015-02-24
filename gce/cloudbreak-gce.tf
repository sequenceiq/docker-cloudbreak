variable deploy_name {
    description = "The instance name of the deployment, prefix is 'cb-deploy'"
}

variable owner {
    description = "Who is respomsible for the instance"
    default = ""
}

variable gce_zone {
    description = "GCE zone to start the cbreak deployment, only a single char"
    default = "a"
}

variable gce_region {
    description = "GCE region to start the cbreak deployment"
    default = "us-central1"
}

variable ins_type {
    description = "cbreak deployment insance size"
    default = "n1-standard-1"
}

variable gce_acount_file {
    description = "service account json"
    default = "siq-haas.json"
}
provider "google" {
    account_file = "${var.gce_acount_file}"
    project = "siq-haas"
    region = "${var.gce_region}"
}

resource "google_compute_instance" "cb-deploy" {
    name = "cb-deploy-${var.deploy_name}"
    machine_type = "${var.ins_type}"
    zone = "${var.gce_region}-${var.gce_zone}"

    disk {
        image = "packer-cb-deploy-2015-02-20"
    }

    network {
        source = "default"
    }

    metadata {
        version = "0.9"
      role = "cb-deploy"
      owner = "${var.owner}"
    }
    connection {
        user = "ubuntu"
        key_file = "${var.ssh_key_file}"
    }

    provisioner "file" {
        source = "uaa.yml"
        destination = "/usr/local/cloudbreak/uaa.yml"
    }

    provisioner "file" {
        source = "siq-haas.p12"
        destination = "/usr/local/cloudbreak/siq-haas.p12"
    }

    provisioner "file" {
        source = ".profile"
        destination = "/usr/local/cloudbreak/.profile"
    }

    provisioner "file" {
        source = "konzul-cb.sh"
        destination = "/usr/local/cloudbreak/konzul-cb.sh"
    }
}

output "instance" {
    value = "${google_compute_instance.cb-deploy.name}"
}
