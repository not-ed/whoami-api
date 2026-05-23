using Microsoft.EntityFrameworkCore;
using WhoamiApi;
using WhoamiApi.Events;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<GithubEventsContext>(options => options.UseSqlServer(ConnectionStringFactory.GetConnectionString(builder.Configuration)));
builder.Services.AddTransient<EventsService>();
var app = builder.Build();

app.MapGet("/activity", (EventsService e) => e.GetEvents());

app.Run();