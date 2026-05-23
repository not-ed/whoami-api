using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;

namespace WhoamiApi;

public class GithubEventsContext(DbContextOptions<GithubEventsContext> options) : DbContext(options)
{
    public DbSet<GithubEvent> Events { get; set; }
}

[Table("github_events")]
public class GithubEvent{
    [Column("id")]
    public long Id { get; set; }
    
    [Column("body")]
    public string Body { get; set; }
    
    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}