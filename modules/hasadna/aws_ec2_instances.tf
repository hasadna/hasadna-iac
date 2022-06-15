resource "aws_instance" "postgres1_db" {
    ami = "ami-e1e8d395"
    instance_type = "m1.small"
    key_name = "hasadna_amir_1"
    availability_zone = "eu-west-1c"
    tenancy = "default"
    ebs_optimized = false
    tags = {
        Name = "Postgres1"
        role = "db"
    }
}

resource "aws_instance" "small2" {
    ami = "ami-e1a8d796"
    instance_type = "t2.small"
    key_name = "hasadna_amir_1"
    availability_zone = "eu-west-1b"
    tenancy = "default"
    subnet_id = "subnet-3941e04e"
    ebs_optimized = false
    vpc_security_group_ids = [
        "sg-59d0e73c"
    ]
    source_dest_check = true
    tags = {
        Name = "Small2"
    }
}

resource "aws_instance" "postgres2_db" {
    ami = "ami-47a23a30"
    instance_type = "t2.small"
    key_name = "hasadna_amir_1"
    availability_zone = "eu-west-1a"
    tenancy = "default"
    subnet_id = "subnet-c572caa0"
    ebs_optimized = false
    vpc_security_group_ids = [
        "sg-c7ae5ea3"
    ]
    source_dest_check = true
    tags = {
        role = "db"
        Name = "Postgres2"
    }
}

resource "aws_instance" "small1" {
    ami = "ami-e1a8d796"
    instance_type = "t2.small"
    key_name = "hasadna_amir_1"
    availability_zone = "eu-west-1b"
    tenancy = "default"
    subnet_id = "subnet-3941e04e"
    ebs_optimized = false
    vpc_security_group_ids = [
        "sg-59d0e73c"
    ]
    source_dest_check = true
    tags = {
        Name = "Small1"
    }
}

resource "aws_instance" "xbus_db" {
    ami = "ami-ffc1af86"
    instance_type = "t2.micro"
    key_name = "hasadna_hostmaster"
    availability_zone = "eu-west-1b"
    tenancy = "default"
    subnet_id = "subnet-3941e04e"
    ebs_optimized = false
    vpc_security_group_ids = [
        "sg-6dcb1d17",
        "sg-6dcb1d17"
    ]
    source_dest_check = true
    ebs_block_device {
        device_name = "/dev/sdf"
        encrypted = false
        volume_size = 30
        snapshot_id = "snap-02a8f8fbdc4712ac5"
        volume_type = "gp2"
        delete_on_termination = false
    }
    root_block_device {
        volume_size = 8
        volume_type = "gp2"
        delete_on_termination = true
        tags = {
            "Name" = "xbus-db"
        }
    }
    tags = {
        Name = "xbus-db"
    }
}
