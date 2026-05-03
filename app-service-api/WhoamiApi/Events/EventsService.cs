namespace WhoamiApi.Events;

public class EventsService
{
    public IResult GetEvents(){
        return TypedResults.Ok(new GetEventsResponse()
        {
            Events = new List<FeedItem>()
            {
                new FeedItem()
                {
                    Color = "#1173e0",
                    Label = "COMMIT",
                    Body = "Made a commit to a repository on GitHub.",
                    Time = DateTime.Now
                },
                new FeedItem()
                {
                    Color = "#f1ce12",
                    Label = "STAR",
                    Body = "Starred a repository on GitHub.",
                    Time = DateTime.Now.AddDays(-1)
                },
                new FeedItem()
                {
                    Color = "#e01142",
                    Label = "DELETED",
                    Body = "Deleted a repository on GitHub.",
                    Time = DateTime.Now.AddDays(-2)
                }
            }
        });
    }
}