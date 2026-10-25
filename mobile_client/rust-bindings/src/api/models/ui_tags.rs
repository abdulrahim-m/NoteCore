use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;

#[frb(non_final)]
pub struct RTag {
    pub id: i64,
    pub name: String,
    pub created_at: DateTime<Utc>,
}
