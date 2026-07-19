using Microsoft.EntityFrameworkCore;
using WhoamiApi;
using WhoamiApi.Events;
using WhoamiApi.Events.Github;
using WhoamiApi.Watchlist;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<GithubEventsDatabaseContext>(options => options.UseSqlServer(ConnectionStringFactory.GetConnectionString(builder.Configuration)));
builder.Services.AddTransient<EventsService>();
builder.Services.AddTransient<AniListWatchlistService>();
var app = builder.Build();

app.MapGet("/activity", (EventsService e) => e.GetEvents());
app.MapGet("/watchlist/current", (AniListWatchlistService e) => e.GetLatestTitle());

app.Run();