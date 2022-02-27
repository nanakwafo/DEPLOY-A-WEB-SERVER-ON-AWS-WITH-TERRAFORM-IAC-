
# DEPLOY A WEB SERVER ON AWS WITH TERRAFORM(IAC)

This terraform file provision the below resources a web server on AWS.it helps to safely deploy infrastructure

- VPC
- Create Internet Gateway
- Create Custom Route Table
- Create a Subnet
- Associate subnet with Route Table
- Create Security Group to allow port 22,80,443
- Create a network Interface with an ip in the subnet that was created in step4
- Assign an elastic IP to the network interface created in step 7
- Create Ubuntu Server and install/enable apache2


## SetUp
- Install Terraform on mac
 ```
 brew install terraform
 ```

- Verify Terraform
```
terraform -v
```
- Setup your AWS access keys with the command Below
```
aws configure
```
- Create a Key-Pair from aws console.The key-pair used for this project is main-key with the .pem extension.Ensure this key is downloaded

## Resources
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
## Deployment

To deploy this project run

```bash
  terraform plan  
```
```bash
  terraform apply
```

