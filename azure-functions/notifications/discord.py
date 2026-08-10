import requests
from settings.config import GetEnvironmentVariable

def SendAniListTitleApprovalPrompt(title_type, title_name, title_url, approval_id):
    webhook_url = GetEnvironmentVariable("DiscordNotificationWebhookUrl")

    prompt_body = {
        "content": f"""@here A new AniList title is pending approval.

        {title_type}: {title_name} ({title_url})

        **APROVE**: TODO: call approval/{approval_id}/allow

        **DENY**: TODO: call approval/{approval_id}/deny
        """
    }

    requests.post(webhook_url, data=prompt_body)