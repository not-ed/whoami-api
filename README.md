# whoami API

# Deployment
## Requirements
Deploying the API to Azure requires [Terraform](https://developer.hashicorp.com/terraform/install) to be installed on your machine, along with an active Azure Subscription to deploy to.

## .tfvars File
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