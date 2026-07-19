import requests
from datetime import datetime

class AniListMedia:
    def __init__(self, anilist_id, media_type, name, url, last_updated):
        self.anilist_id = anilist_id
        self.media_type = media_type
        self.name = name
        self.url = url
        self.last_updated = last_updated

def IngestCurrentCurrentAniListMediaList():
    anilist_url = "https://graphql.anilist.co"

    query_body = """
    query ($userName: String, $type: MediaType) {
        MediaListCollection(
            type: $type
            userName: $userName
            status: CURRENT
            sort: UPDATED_TIME_DESC
        ) {
            lists {
                entries {
                    updatedAt
                    media {
                        id
                        type
                        siteUrl
                        title {
                            english
                        }
                    }
                }
            }
        }
    }
    """

    query_variables = {
        "userName": os.getenv("AniListUsername", None),
    }

    current_titles = []

    for media_type in ["ANIME", "MANGA"]:
        query_variables["type"] = media_type
        anilist_response = requests.post(url=anilist_url, json={"query":query_body, "variables":query_variables})
        if not anilist_response.ok:
            return current_titles
        for title in anilist_response.json()["data"]["MediaListCollection"]["lists"][0]["entries"]:
            media = AniListMedia(title["media"]["id"],title["media"]["type"],title["media"]["title"]["english"],title["media"]["siteUrl"],datetime.fromtimestamp(title["updatedAt"]))
            current_titles.append(media)
    
    current_titles.sort(key=lambda x: x.last_updated, reverse=True)
    return current_titles