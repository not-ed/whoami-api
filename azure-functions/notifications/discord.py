import requests
from settings.config import GetEnvironmentVariable

def SendAniListTitleApprovalPrompt(title_type, title_name, title_url, approval_id):
    webhook_url = GetEnvironmentVariable("DiscordNotificationWebhookUrl")
    functions_app_base_url = GetEnvironmentVariable("WEBSITE_HOSTNAME")

    prompt_body = {
        "content": f"""@here A new AniList title is pending approval.

        {title_type}: [{title_name}]({title_url}) : https://{functions_app_base_url}/api/approval/{approval_id}
        """
    }

    requests.post(webhook_url, data=prompt_body)