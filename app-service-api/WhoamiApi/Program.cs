using Microsoft.EntityFrameworkCore;
using WhoamiApi;
using WhoamiApi.Events;
using WhoamiApi.Events.Github;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<GithubEventsDatabaseContext>(options => options.UseSqlServer(ConnectionStringFactory.GetConnectionString(builder.Configuration)));
builder.Services.AddTransient<EventsService>();
var app = builder.Build();

app.MapGet("/activity", (EventsService e) => e.GetEvents());

app.Run();