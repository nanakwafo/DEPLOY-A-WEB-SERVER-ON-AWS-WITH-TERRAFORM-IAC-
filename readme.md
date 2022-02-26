
# DEPLOY A WEB SERVER ON AWS WITH TERRAFORM(IAC)

This terraform file provision the below resources a web server on AWS

- VPC
- Create Internet Gateway
- Create Custom Route Table
- Create a Subnet
- Associate subnet with Route Table
- Create Security Group to allow port 22,80,443
- Create a network Interface with an ip in the subnet that was created in step4
- Assign an elastic IP to the network interface created in step 7
- Create Ubuntu Server and install/enable apache2


## Pre-requisites
- Install Terraform on mac
 ```
 brew install terraform
 ```

- Verify Terraform
```
terraform -v
```