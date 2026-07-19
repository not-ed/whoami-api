namespace WhoamiApi.Watchlist;

public class AniListWatchlistService
{
    public IResult GetLatestTitle()
    {
        return Results.Ok(new GetLatestAniListTitleResponse()
        {
            Title = "Umamusume: Pretty Derby Season 2",
            Type = "ANIME",
            Url = "https://anilist.co/anime/124223"
        });
    }
}