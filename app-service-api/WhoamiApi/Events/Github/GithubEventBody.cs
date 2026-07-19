using System.Text.Json.Serialization;

namespace WhoamiApi.Events.Github;

public class GithubEventBody
{
    [JsonPropertyName("type")]
    public string EventType { get; set; }

    [JsonPropertyName("repo")]
    public GithubEventRepository Repository { get; set; }
}

public class GithubEventRepository
{
    [JsonPropertyName("id")]
    public int Id { get; set; }
    
    [JsonPropertyName("name")]
    public string Name { get; set; }
}