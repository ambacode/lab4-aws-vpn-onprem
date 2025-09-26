# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

/*
  VARIABLES
*/
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "az1" {
  type    = string
  default = "us-east-1a"
}

/*
  DATA: Ubuntu AMI (generic filter)
*/
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

/*
  OUTPUTS: we want the user to use these values to configure StrongSwan's ipsec.conf/secrets
*/
output "strongswan_eip" {
  value = aws_eip.strongswan_eip.public_ip
}

output "onprem_private" {
      description = "Onprem device public IP"
      value       = aws_instance.onprem_device.private_ip
    }

# this info could be misused so you'd want to make sure where you output this is secure
# you can also get this from the aws console in the vpn section by downloading the config
output "vpn_configuration" {
  description = "AWS VPN connection info (tunnel addresses, PSKs) - use these to configure StrongSwan."
  value = {
    vpn_id                = aws_vpn_connection.tgw_to_strongswan.id
    tunnel1_address       = aws_vpn_connection.tgw_to_strongswan.tunnel1_address
    tunnel2_address       = aws_vpn_connection.tgw_to_strongswan.tunnel2_address
    tunnel1_preshared_key = aws_vpn_connection.tgw_to_strongswan.tunnel1_preshared_key
    tunnel2_preshared_key = aws_vpn_connection.tgw_to_strongswan.tunnel2_preshared_key
    tunnel1_inside_cidr   = aws_vpn_connection.tgw_to_strongswan.tunnel1_inside_cidr
    tunnel2_inside_cidr   = aws_vpn_connection.tgw_to_strongswan.tunnel2_inside_cidr
  }
  sensitive = true
}
