# whoami API

# Requirements
Deploying the API to Azure requires [Terraform](https://developer.hashicorp.com/terraform/install) to be installed on your machine, along with an active Azure Subscription to deploy to.

## Initializing Terraform / `.config` File
Before initializing Terraform for the first time, an [Azure Storage Account](https://marketplace.microsoft.com/en-gb/product/Microsoft.StorageAccount) needs to be provisioned in your Azure Subscription to maintain state between machines. 

Once a Storage Account has been created, create a Blob Container inside of it where Terraform state files will be kept moving forward. 

Take note of the name of the Storage Account you created, and the name of the Blob Container you just created inside of it. Both should be written to a `.config` file under the following parameters:

```
storage_account_name = "[Your Storage Account's name]"
container_name = "[The Blob Container's name inside your Storage Account.]"
```

Once this is done, initialize Terraform as normal on your machine using the `.config` file you created:
```
terraform init -backend-config=[your_file].config
```

## Configuration / `.tfvars` File
A local `.tfvars` file needs to be created in your environment to pass through various options to a deployment. This file should define the following variables:

| Variable | Description |
|---|---|
| `github-username` | The GitHub username of the User whose events will be persisted by the API.
| `database-administrator-username` | The desired username of the Admin user for the SQL Server instance provisioned in Azure.
| `database-administrator-password` | The desired password of the Admin user for the SQL Server instance provisioned in Azure. This password must satisfy Azure's [password complexity rules](https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy#password-complexity).

When planning or applying changes, use the `--var-file` flag to pass your file:
```
terraform plan --var-file=[your_file].tfvars
```

```
terraform apply --var-file=[your_file].tfvars
```