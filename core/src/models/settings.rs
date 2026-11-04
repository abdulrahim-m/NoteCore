use std::collections::HashMap;

use sqlx::{Row, SqlitePool};

use crate::utils::app_error::Result;

pub struct Settings;

impl Settings {
    pub async fn get_all(pool: &SqlitePool) -> Result<HashMap<String, String>> {
        Ok(sqlx::query(
            "SELECT key, value FROM app_settings"
        ).fetch_all(pool).await?.into_iter().map(|r| (r.get("key"), r.get("value"))).collect())
    }

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

    pub async fn get(pool: &SqlitePool, key: &str) -> Result<Option<String>> {
        let result: Option<(String,)> = sqlx::query_as(
            "SELECT value FROM app_settings WHERE key = ?"
        )
        .bind(key)
        .fetch_optional(pool)
        .await?;

        Ok(result.map(|row| row.0))
    }

    pub async fn setup_defaults(pool: &SqlitePool) -> Result<()> {
        let data = [
            ("language", "default"),
            ("theme", "default"),
            ("reset_time", "0"),
            ("font_size", "14")
        ];

        let mut query_builder = sqlx::QueryBuilder::new(
            "INSERT OR IGNORE INTO app_settings (key, value) "
        );

        query_builder.push_values(data, |mut b, (key, value)| {
            b.push_bind(key).push_bind(value);
        });

        query_builder.build().execute(pool).await?;
        
        Ok(())
    }
}