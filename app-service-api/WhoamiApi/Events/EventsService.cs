using WhoamiApi.Events.Github;

namespace WhoamiApi.Events;

public class EventsService
{
    private GithubEventsDatabaseContext _github;
    public EventsService(GithubEventsDatabaseContext githubEventsDatabaseContext)
    {
        _github = githubEventsDatabaseContext;
    }
    
    public IResult GetEvents()
    {
        var githubEvents = _github.Events.Take(5).OrderByDescending(x => x.CreatedAt).ToList();
        
        return TypedResults.Ok(new GetEventsResponse()
        {
            Events = githubEvents.Select(x => new FeedItem()
            {
                Color = "#e01142",
                Body = "test",
                Label = x.Body.EventType,
                Time = x.CreatedAt
            }).ToList()
        });
    }
}