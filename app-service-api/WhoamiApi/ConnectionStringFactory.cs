using Microsoft.IdentityModel.Tokens;

namespace WhoamiApi;

public class ConnectionStringFactory
{
    public static string GetConnectionString(IConfigurationManager config)
    {
        var databaseName = config.GetSection("DatabaseName").Value;
        var databaseServerName = config.GetSection("DatabaseServerName").Value;
        var databaseUsername = config.GetSection("DatabaseUsername").Value;
        var databasePassword = config.GetSection("DatabasePassword").Value;

        if (databaseName.IsNullOrEmpty() || databaseServerName.IsNullOrEmpty() || databaseUsername.IsNullOrEmpty() || databasePassword.IsNullOrEmpty())
        {
            throw new Exception("One of more environment variables are missing for creating a connection string to SQL Server. " +
                                "If you are seeing this error when developing locally, you need to configure these variables on your machine using an appsettings.Development.json file (see README.md).");
        }
        
        return $"Server={databaseServerName};Database={databaseName};Encrypt=yes;TrustServerCertificate=no;Authentication=SqlPassword;UID={databaseUsername};PWD={databasePassword}";
    }
}