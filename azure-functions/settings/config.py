import os

def GetEnvironmentVariable(key):
    value = os.getenv(key, None)
    if value is None:
        raise Exception(f"Environment variable with key '{key}' is missing or has not been populated. If you are developing locally, a local.settings.json file needs to be created which defines this.")
    return value
