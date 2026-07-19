CREATE TABLE github_events(
    id bigint PRIMARY KEY NOT NULL,
    body json NOT NULL,
    created_at datetime2 NOT NULL
);

CREATE TABLE anilist_titles
(
    id bigint PRIMARY KEY NOT NULL,
    name nvarchar(200) NOT NULL,
    title_type varchar(5) NOT NULL,
    url nvarchar(100) NOT NULL,
    updated_at datetime2 NOT NULL,
    approved bit DEFAULT 'FALSE'
);

CREATE TABLE pending_anilist_approvals(
    id uniqueidentifier PRIMARY KEY NOT NULL DEFAULT NEWID(),
    anilist_id bigint NOT NULL UNIQUE,
    approval_prompt_sent bit DEFAULT 'FALSE',

    CONSTRAINT fk_pending_anilist_approvals_anilist_titles FOREIGN KEY (anilist_id) REFERENCES anilist_titles(id) ON DELETE CASCADE
);