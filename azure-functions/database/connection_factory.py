import logging
import mssql_python
import os
from settings import config

def OpenDatabaseConnection():
    database_server_name = config.GetEnvironmentVariable("DatabaseServerName")
    database_name = config.GetEnvironmentVariable("DatabaseName")
    database_username = config.GetEnvironmentVariable("DatabaseUsername")
    database_password = config.GetEnvironmentVariable("DatabasePassword")

    logging.info(f"Connecting to {database_name} ({database_server_name}) as {database_username}...")

    connection_string=f"Server={database_server_name};Database={database_name};Encrypt=yes;TrustServerCertificate=no;Authentication=SqlPassword;UID={database_username};PWD={database_password}"
    return mssql_python.connect(connection_string)