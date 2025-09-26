PROJECT TITLE

Overview
Configure a private cloud VPC with associated transit gateway and a site-to-site VPN to connect to an 'on-prem' VPC via the IPSEC tunnel.

We are creating an virtual 'on-prem' site using the second VPC with an EC2 in a public subnet using strongswan to act as a customer premise router, and another EC2 in a private subnet to act as a local workstation.

Honestly this one was pretty difficult and took a lot of tshooting. Mostly with getting strongswan config working for IPSEC and routing traffic correctly. The biggest pain points were the strongswan config and getting it to forward packets correctly.

Architecture
Services used: VPC, Subnets, EC2, S2S VPN, Transit Gateway, IGW, Route Tables and propagation
Tools: Terraform, AWS CLI, Git

Diagram:
In the project folder

Setup Instructions

AWS account
CLI configured with AWS CLI credentials
Terraform installed

Steps

Initialize Terraform:
terraform init

Review plan:
terraform plan

Apply changes:
terraform apply

Capture outputs (we'll use these in a sec below)
terraform output strongswan_eip
terraform output onprem_private
terraform output vpn_configuration
Copy these into a notepad or something.
Honestly I chose to download the AWS VPN config from the console to have access to all the information regarding the VPN and suggest doing the same.

SSH into the strongswan instance
ssh -i ec2_private_key.pem ubuntu@<public_ip>

Refer to strongswan-config.txt for remaining steps on strongswan instance!!
I suggest using notepad to prepare commands to copy paste as you will need to replace many values with the ones you get from terraform output and the vpn configuration file.

If you follow the steps correctly the terraform template will build the full AWS infrastructure, and the strongswan configuration you do will bring the VPN up and route traffic across the tunnel.

Testing/Verification
Confirm ping from VPC1 EC2 -> VPC2 EC2s (and vice versa).

If tunnels fail to come up, double-check:
Since we used terraform the AWS deployment should be good, so the issues are very likely to do with having misconfigured the strongswan server.

Teardown
terraform destroy

Project Structure
List the file tree so it’s easy to understand. Example:

main.tf
aws-vpc.tf
onprem-vpc_2.tf
README.txt

Key Learnings

I used AI to generate a base template and then went through and resolved issues to get this deployment to work correctly. Honestly the AI was great to get a basic setup but very bad for having it work correctly, so it required a lot of investigation to get it working.
For the strongswan config I used the strongswan config that is included with the VPN config download (if you select strongswan as the vendor type) and edited it. This config from AWS had some weird things and things that seemed deprecated. After a great deal of tshooting it's good to go now.

Also the AWS blog post suggested putting the other 'onprem' EC2 instances in the same public subnet as the strongswan VPN but I opted to put them in a private subnet in the same VPC for best practices; isolating the inside devices from the internet and having security and routing be more explicit this way.

References
AWS VPN Terraform Config file
Terraform documentation
ChatGPT & Gemini
This blog post from aws: https://aws.amazon.com/blogs/networking-and-content-delivery/simulating-site-to-site-vpn-customer-gateways-strongswan/
