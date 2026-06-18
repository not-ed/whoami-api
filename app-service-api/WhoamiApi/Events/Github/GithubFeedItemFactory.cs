namespace WhoamiApi.Events.Github;

public class GithubFeedItemFactory
{
    private const string GITHUB_BASE_URL = "https://github.com/";
    
    public static FeedItem FromGithubEvent(GithubEvent @event)
    {
        switch (@event.Body.EventType)
        {
            case "WatchEvent":
                return MapWatchEvent(@event);
        }
        return MapUnknownEvent(@event);
    }

    private static FeedItem MapUnknownEvent(GithubEvent @event)
    {
        return new FeedItem()
        {
            Color = "#cc11e0",
            Body = $"Performed an {@event.Body.EventType} on Github.",
            Label = "MISSINGNO",
            Time = @event.CreatedAt
        };
    }
    
    private static FeedItem MapWatchEvent(GithubEvent @event)
    {
        return new FeedItem()
        {
            Color = "#f1ce12",
            Body = $"Starred [{@event.Body.Repository.Name}]({GITHUB_BASE_URL}{@event.Body.Repository.Name}) on Github.",
            Label = "STAR",
            Time = @event.CreatedAt
        };
    }
}