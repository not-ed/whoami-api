# whoami API (Azure Functions)

This directory houses code which can be deployed to an Azure Functions Application which is responsible for defining Python-based workflows related to data ingestion.

Once deployed, the following Functions are created inside of Azure:
- `github_events_import` - queries the GitHub Events API for a configured User, and persists the results in SQL Server.

# Requirements
## Local Development
[Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools) is required to test Functions locally. Inside the the root of this directory, run:

```
func start
```

A `local.settings.json` file is also required in the root of this directory to define local environment variables that each Function needs to run:

| Value | Description |
|---|---|
| `GitHubUsername` | The username of the GitHub user to capture events against.
| `DatabaseServerName` | The full name / URL of a SQL Server Database (e.g. `*.database.windows.net`) to persist events to.
| `DatabaseName` | The name of a SQL Server Database to persist events to.
| `DatabaseUsername` | A Username to authenticate to the SQL Server Database under.
| `DatabasePassword` | A Password to authenticate to the SQL Server Database under.