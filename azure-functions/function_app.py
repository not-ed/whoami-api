import logging
import azure.functions as func
import os
import requests
import json
from anilist.anilist import IngestCurrentCurrentAniListMediaList
from database.connection_factory import OpenDatabaseConnection


def IngestNewGithubEvents():
    github_username = os.getenv("GitHubUsername", None)
    if None in [github_username]:
        logging.info("Missing required configuration. Skipping run...")
        return

    logging.info(f"Fetching public GitHub events for {github_username}...")
    events_response = requests.get(f"https://api.github.com/users/{github_username}/events", headers={"X-GitHub-Api-Version": "2026-03-10"})
    if not events_response.ok:
        return

    events = events_response.json()
    if len(events) == 0:
        logging.info(f"No public events found for {github_username}. Skipping run...")

    pending_event_ids = []    
    for event in events:
        pending_event_ids.append(int(event["id"]))
    logging.info(f"{len(pending_event_ids)} events retrieved:")
    logging.info(f"Pending Event IDs: {pending_event_ids}")

    connection = OpenDatabaseConnection()

    logging.info(f"Checking if Pending Event IDs already exist...")
    fetch_existing_ids_query = connection.execute(f"SELECT id FROM github_events WHERE id IN {'('+','.join(str(i) for i in pending_event_ids)+')'};");
    for row in fetch_existing_ids_query.fetchall():
        if row[0] in pending_event_ids:
            logging.info(f"Event ID {row[0]} already exists. Removing from pending list...")
            pending_event_ids.remove(row[0])
    
    logging.info(f"Remaining Pending Event IDs: {pending_event_ids}")
    if len(pending_event_ids) > 0:
        insert_all_pending_events_query = "INSERT INTO github_events (id, body, created_at) VALUES "

        for event in events:
            if int(event["id"]) in pending_event_ids:
                insert_all_pending_events_query = insert_all_pending_events_query + f"({int(event['id'])}, '{json.dumps(event)}', '{event['created_at']}'),"
        insert_all_pending_events_query = (insert_all_pending_events_query + ";").replace(",;",";")

        connection.execute(insert_all_pending_events_query)
        connection.commit()
    else:
        logging.info("No new Events to save. Skipping writes to database...")

    connection.close()

app = func.FunctionApp()

@app.timer_trigger(schedule="0 0 * * * *", arg_name="myTimer", run_on_startup=False, use_monitor=False) 
def github_events_import(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logging.info('The timer is past due!')

    logging.info('GitHub Events Import Initiated.')
    IngestNewGithubEvents()

@app.timer_trigger(schedule="0 0 * * * *", arg_name="myTimer", run_on_startup=False, use_monitor=False)
def anilist_titles_import(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logging.info('The timer is past due!')

    logging.info('AniList Title Import Initiated.')
    IngestAniListTitles()


def IngestAniListTitles():
    # TODO: Duplicated configuration checking
    anilist_username = os.getenv("AniListUsername", None)
    if None in [anilist_username]:
        logging.info("Missing required configuration. Skipping run...")
        return
    
    current_titles = IngestCurrentCurrentAniListMediaList()
    if len(current_titles) == 0:
        logging.info(f"No titles found from AniList. Skipping run...")
        return
    logging.info(f"Retrieved {len(current_titles)} titles from AniList.")
    
    connection = OpenDatabaseConnection()

    fetch_existing_title_ids_query = connection.execute(f"SELECT id FROM anilist_titles WHERE id IN {'('+','.join(str(title.anilist_id) for title in current_titles)+')'};");
    existing_title_ids = [row[0] for row in fetch_existing_title_ids_query.fetchall()]

    new_titles = [title for title in current_titles if title.anilist_id not in existing_title_ids]
    existing_titles = [title for title in current_titles if title.anilist_id in existing_title_ids]
    for title in new_titles:
        connection.execute(f"INSERT INTO anilist_titles (id, name, url, title_type, updated_at) VALUES ({title.anilist_id},'{title.name}','{title.url}','{title.media_type}','{title.last_updated}');")
        connection.execute(f"INSERT INTO pending_anilist_approvals (anilist_id) VALUES ({title.anilist_id});")

    for title in existing_titles:
        connection.execute(f"UPDATE anilist_titles SET updated_at = '{title.last_updated}' WHERE id = {title.anilist_id};")

    connection.commit()
    connection.close()