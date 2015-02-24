variable deploy_name {
    description = "The instance name of the deployment"
}

variable aws_access_key {
    description = "AWS access key"
}

variable aws_secret_key {
    description = "AWS secret key"
}

variable aws_key_name {
    description = "AWS key to SSH"
}

variable aws_ssh_key_file {
    description = "AWS file to SSH"
}

variable aws_vpc_cidr {
    description = "VPC CIDR block"
    default = "10.0.0.0/24"
}

variable aws_security_cidr {
    description = "Allowed subnets"
    default = "0.0.0.0/0"
}

variable aws_ami {
    default = {
        eu-west-1 = "ami-ed63f49a"
    }
    description = "AMI to launch the instance from"
}

variable aws_availability_zone {
    description = "AWS availability zone to start the Cloudbreak deployment in, single char"
    default = "a"
}

variable aws_region {
    description = "AWS region to start the Cloudbreak deployment"
}

variable aws_inst_type {
    description = "Cloudbreak deployment instance type"
    default = "m3.xlarge"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_vpc" "cb_vpc" {
    cidr_block = "${var.aws_vpc_cidr}"

    tags {
        Name = "cloudbreak-vpc"
    }
}

resource "aws_internet_gateway" "cb_gw" {
    vpc_id = "${aws_vpc.cb_vpc.id}"
}

resource "aws_security_group" "cb_security_group" {
  name = "cb_security_group"
    description = "Ports exposed for Cloudbreak"

  ingress {
      from_port = 0
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["${var.aws_security_cidr}"]
  }

  vpc_id = "${aws_vpc.cb_vpc.id}"

}

resource "aws_subnet" "cb_subnet" {
    vpc_id = "${aws_vpc.cb_vpc.id}"

    cidr_block = "${var.aws_vpc_cidr}"
    availability_zone = "${var.aws_region}${var.aws_availability_zone}"
}

resource "aws_route_table" "cb_route" {
    vpc_id = "${aws_vpc.cb_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.cb_gw.id}"
    }
}

resource "aws_route_table_association" "cb_route_subnet" {
    subnet_id = "${aws_subnet.cb_subnet.id}"
    route_table_id = "${aws_route_table.cb_route.id}"
}

resource "aws_instance" "cb-deploy" {
    ami = "${lookup(var.aws_ami, var.aws_region)}"
    instance_type = "${var.aws_inst_type}"
    availability_zone = "${var.aws_region}${var.aws_availability_zone}"
    associate_public_ip_address = true
    source_dest_check = false
    key_name = "${var.aws_key_name}"
    security_groups = ["${aws_security_group.cb_security_group.id}"]
    subnet_id = "${aws_subnet.cb_subnet.id}"

    tags {
        Name = "${var.deploy_name}"
    }

    connection {
        user = "ubuntu"
        key_file = "${var.aws_ssh_key_file}"
    }

    provisioner "file" {
        source = "env_props.sh"
        destination = "/usr/local/cloudbreak/env_props.sh"
    }

    provisioner "remote-exec" {
        script = "./deploy.sh"
    }

}

output "instance" {
    value = "${var.deploy_name}"
}
