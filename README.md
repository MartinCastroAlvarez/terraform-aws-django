# terraform-aws-django
Using Terraform to create AWS resources to run a Django application

![wallpaper.avif](wallpaper.avif)

## Terraform

Terraform is an open-source infrastructure-as-code (IaC) tool developed by HashiCorp. It allows you to define and manage your infrastructure as code, making it easier to provision and manage resources in cloud providers like AWS, Azure, and Google Cloud Platform.

## References

- [Installing Terraform](https://developer.hashicorp.com/terraform/downloads)

## Installation

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

```bash
export AWS_ACCESS_KEY_ID="AKIA335HOYDC4CPV7XQL"
export AWS_SECRET_ACCESS_KEY="GAu44UYZXwbAM0Jf5kM8qVL0eMqMLleGv+q9didf"
```

## Deployment

Run the following command to initialize your Terraform project:

```bash
terraform init
```

Run the following command to see a summary of the changes Terraform will make to your infrastructure:

```bash
terraform plan
```

Apply the changes and create the resources, run the following command:

```bash
terraform apply
```

When you applied your configuration, Terraform wrote data into a file called terraform.tfstate. Terraform stores the IDs and properties of the resources it manages in this file, so that it can update or destroy those resources going forward.

The Terraform state file is the only way Terraform can track which resources it manages, and often contains sensitive information, so you must store your state file securely and restrict access to only trusted team members who need to manage your infrastructure.

Inspect the current state using the following command:

```bash
 terraform show
```

## Termination

If you want to tear down the resources created by Terraform, you can run the following command:

```bash
terraform destroy
```

## Development

Automaticaly format your configuration:

```bash
terraform fmt
```

Validate your configuration:

```bash
terraform validate
```