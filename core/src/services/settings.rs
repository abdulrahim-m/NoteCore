use std::sync::Arc;

use sqlx::SqlitePool;

use crate::utils::app_error::Result;

pub struct Settings {
    pool: Arc<SqlitePool>
}

impl Settings {
    pub fn init(pool: Arc<SqlitePool>) -> Self { Settings{ pool } }

    pub async fn set(&self, key: &str, value: &str) -> Result<()> {
        sqlx::query(
            "INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)"
        )
        .bind(key)
        .bind(value)
        .execute(self.pool.as_ref())
        .await?;
        
        Ok(())
    }

    pub async fn get_setting(&self, key: &str) -> Result<Option<String>> {
        let result: Option<(String,)> = sqlx::query_as(
            "SELECT value FROM app_settings WHERE key = ?"
        )
        .bind(key)
        .fetch_optional(self.pool.as_ref())
        .await?;

        Ok(result.map(|row| row.0))
    }
}