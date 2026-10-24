use std::path::PathBuf;
use sqlx::sqlite::{SqliteConnectOptions, SqlitePoolOptions};
use sqlx::{SqlitePool, Error};
use std::str::FromStr;

pub struct DatabaseManager;

impl DatabaseManager {
    pub async fn init(base_path: String) -> Result<SqlitePool, Error> {
        let mut db_path = PathBuf::from(base_path);
        db_path.push("notecore.db");

        let conn_options = SqliteConnectOptions::from_str(&format!("sqlite://{}", db_path.to_string_lossy()))?
            .create_if_missing(true)
            .foreign_keys(true);

        let pool = SqlitePoolOptions::new()
            .connect_with(conn_options)
            .await?;

        Self::init_tables(&pool).await?;

        Ok(pool)
    }

    async fn init_tables(pool: &SqlitePool) -> Result<(), Error> {
        let schema = "
            CREATE TABLE IF NOT EXISTS app_settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS tags (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                created_at DATETIME NOT NULL
            );

            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                task_type TEXT NOT NULL,
                done BOOLEAN NOT NULL,
                created_at DATETIME NOT NULL,
                updated_at DATETIME NOT NULL,
                options TEXT NOT NULL,
                tags TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS note_groups (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                placing INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS notes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                group_id INTEGER,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                tags TEXT NOT NULL,
                created_at DATETIME NOT NULL,
                updated_at DATETIME NOT NULL,
                FOREIGN KEY (group_id) REFERENCES note_groups(id) ON DELETE SET NULL
            );

            CREATE TABLE IF NOT EXISTS short_note_sections (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                tags TEXT NOT NULL,
                created_at DATETIME NOT NULL,
                updated_at DATETIME NOT NULL
            );

            CREATE TABLE IF NOT EXISTS short_note_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                section_id INTEGER NOT NULL,
                content TEXT NOT NULL,
                FOREIGN KEY (section_id) REFERENCES short_note_sections(id) ON DELETE CASCADE
            );

            CREATE TABLE IF NOT EXISTS short_task_sections (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                tags TEXT NOT NULL,
                created_at DATETIME NOT NULL,
                updated_at DATETIME NOT NULL
            );

            CREATE TABLE IF NOT EXISTS short_task_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                section_id INTEGER NOT NULL,
                text TEXT NOT NULL,
                done BOOLEAN NOT NULL,
                FOREIGN KEY (section_id) REFERENCES short_task_sections(id) ON DELETE CASCADE
            );
        ";

        sqlx::query(schema).execute(pool).await?;

        Ok(())
    }
}