# whoami API (App Service)

# Requirements
## Local Development / Environment Variables.
When the API as a whole is deployed to production using Terraform, any required Environment Variables should be populated into Azure Key Vault automatically, which will automatically be used by this Application.

If you are performing local development, these variables will need to be defined within a local `appsettings.Development.json` at the root of `WhoamiApi/`:

| Value | Description |
|---|---|
| `DatabaseServerName` | The full name / URL of a SQL Server Database (e.g. `*.database.windows.net`) to persist events to.
| `DatabaseName` | The name of a SQL Server Database to persist events to.
| `DatabaseUsername` | A Username to authenticate to the SQL Server Database under.
| `DatabasePassword` | A Password to authenticate to the SQL Server Database under.