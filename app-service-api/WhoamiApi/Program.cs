var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => TypedResults.Ok(new EventFeedResponse{ 
    Events = new List<FeedEvent>
    {
        new FeedEvent()
        {
            Color = "#1173e0",
            Label = "COMMIT",
            Content = "Made a commit to a repository on GitHub.",
            Time = DateTime.Now
        },
        new FeedEvent()
        {
            Color = "#f1ce12",
            Label = "STAR",
            Content = "Starred a repository on GitHub.",
            Time = DateTime.Now.AddDays(-1)
        },
        new FeedEvent()
        {
            Color = "#e01142",
            Label = "DELETED",
            Content = "Deleted a repository on GitHub.",
            Time = DateTime.Now.AddDays(-2)
        },
    }
}));

app.Run();

class EventFeedResponse
{
    public List<FeedEvent> Events { get; set; }
}

class FeedEvent
{
    public string Color { get; set; }
    public string Label { get; set; }
    public string Content { get; set; }
    public DateTime Time { get; set; }
}