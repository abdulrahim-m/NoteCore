use chrono::{DateTime, Utc};
use sqlx::{Error, FromRow, SqlitePool, sqlite::SqliteRow};

pub struct ListRequest {
    pub current_page: i64,
    pub pages_count: i64,
    pub limit: i64,
}

pub struct SearchParams {
    pub text: Option<String>,
    pub tags: Option<Vec<i64>>,
    pub created_before: Option<DateTime<Utc>>,
    pub created_after: Option<DateTime<Utc>>
}

#[allow(async_fn_in_trait)]
pub trait Model: Sized + for<'r> FromRow<'r, SqliteRow> {
    async fn get_count(pool: &SqlitePool) -> Result<i64, Error>;
    async fn get_all(pool: &SqlitePool, list: Option<ListRequest>) -> Result<Vec<Self>, Error>;
    async fn get_by_id(pool: &SqlitePool, id: i64) -> Result<Self, Error>;

    async fn search(pool: &SqlitePool, params: SearchParams) -> Result<Vec<Self>, Error>;

    async fn create(&mut self, pool: &SqlitePool) -> Result<(), Error>;
    async fn update(&mut self, pool: &SqlitePool) -> Result<(), Error>;
    async fn delete(pool: &SqlitePool, id: i64) -> Result<(), Error>;
}