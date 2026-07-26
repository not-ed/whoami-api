import logging
import mssql_python
import os

def OpenDatabaseConnection():
    database_server_name = os.getenv("DatabaseServerName", None)
    database_name = os.getenv("DatabaseName", None)
    database_username = os.getenv("DatabaseUsername", None)
    database_password = os.getenv("DatabasePassword", None)

    if None in [database_server_name, database_name, database_username, database_password]:
        logging.error("One or more environment variables for database connectivity are missing. This will likely fail.")

    logging.info(f"Connecting to {database_name} ({database_server_name}) as {database_username}...")

    connection_string=f"Server={database_server_name};Database={database_name};Encrypt=yes;TrustServerCertificate=no;Authentication=SqlPassword;UID={database_username};PWD={database_password}"
    return mssql_python.connect(connection_string)