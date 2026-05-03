using WhoamiApi.Events;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/activity", () => new EventsService().GetEvents());

app.Run();