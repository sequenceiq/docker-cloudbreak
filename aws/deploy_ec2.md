## Deploy Cloudbreak on AWS

### Required variables to launch the instance
In order to launch the EC2 instance fill the `terraform.tfvars` with the appropriate values:
  * deploy_name - instance name on AWS EC2 console
  * aws_access_key - your aws access key
  * aws_secret_key - your aws secret key
  * aws_region - the region in which you'd like to launch the instance
  * aws_availability_zone - which zone to use in the region, single char: a, b..
  * aws_security_cidr - allowed subnet in cidr format to reach the exposed ports, 0.0.0.0/0 means it's allowed for everyone
  * aws_key_name - name of the keypair (add a new keypair on AWS EC2 page, and use that keyname)
  * aws_ssh_key_file - path to the private key (it's the specified keypair name you have just created on AWS EC2 and downloaded)

### Required variables for Cloudbreak
Fill the `env_props.sh` file with the appropriate values:

  * CB_SMTP_SENDER_USERNAME - the username to the used SMTP server
  * CB_SMTP_SENDER_PASSWORD - the password to the used SMTP server
  * CB_SMTP_SENDER_HOST - the SMTP server host
  * CB_SMTP_SENDER_PORT - the SMTP server port
  * CB_SMTP_SENDER_FROM - The value of the from field in emails sent by the system
  * AWS_ACCESS_KEY_ID - your aws access key
  * AWS_SECRET_KEY - your aws secret key

### Deploy Cloudbreak
If all the required variables are set you can validate the instance metadata: `terraform plan`.

In order to see more in the logs set the following ENV variable: `export TF_LOG=1`

If everything is allright then you can execute the plan: `terraform apply`.

It will launch the instance and it will deploy Cloudbreak. After a short time you will be able to log in on the `public IP address` of the instance, on port 3000.

In something went wrong please apply `terraform destroy` **twice**.  That will do all the cleanup on AWS.
