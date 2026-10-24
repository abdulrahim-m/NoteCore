use sqlx::SqlitePool;

use crate::utils::app_error::Result;

pub struct Settings;

impl Settings {
    pub async fn set(pool: &SqlitePool, key: &str, value: &str) -> Result<()> {
        sqlx::query(
            "INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)"
        )
        .bind(key)
        .bind(value)
        .execute(pool)
        .await?;
        
        Ok(())
    }

    pub async fn get_setting(pool: &SqlitePool, key: &str) -> Result<Option<String>> {
        let result: Option<(String,)> = sqlx::query_as(
            "SELECT value FROM app_settings WHERE key = ?"
        )
        .bind(key)
        .fetch_optional(pool)
        .await?;

        Ok(result.map(|row| row.0))
    }
}