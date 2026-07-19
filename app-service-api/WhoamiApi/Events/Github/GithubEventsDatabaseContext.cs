using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;

namespace WhoamiApi.Events.Github;

public class GithubEventsDatabaseContext(DbContextOptions<GithubEventsDatabaseContext> options) : DbContext(options)
{
    public DbSet<GithubEvent> Events { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<GithubEvent>()
            .Property(e => e.Body)
            .HasConversion(
                appValue => JsonSerializer.Serialize(appValue, JsonSerializerOptions.Default),
                databaseValue => JsonSerializer.Deserialize<GithubEventBody>(databaseValue, JsonSerializerOptions.Default));
    }
}

[Table("github_events")]
public class GithubEvent{
    [Column("id")]
    public long Id { get; set; }
    
    [Column("body")]
    public GithubEventBody Body { get; set; }
    
    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}