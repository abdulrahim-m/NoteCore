use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;
use notecore::models::tasks::task::{Priority, Schedule, TaskOptions, Type};

use crate::api::models::ui_tags::RTag;

#[frb]
pub enum RSchedule {
    Daily { hour: u8 },
    EveryNDays { days: u32, hour: u8 },
    Weekly { day_of_week: u8, hour: u8 },
    Monthly { day_of_month: u8, hour: u8 },
    Yearly { month: u8, day_of_month: u8, hour: u8 },
}

impl From<Schedule> for RSchedule {
    fn from(v: Schedule) -> Self {
        match v {
            Schedule::Daily { hour } => RSchedule::Daily { hour },
            Schedule::EveryNDays { days, hour } => RSchedule::EveryNDays { days, hour },
            Schedule::Weekly { day_of_week, hour } => RSchedule::Weekly { day_of_week, hour },
            Schedule::Monthly { day_of_month, hour } => RSchedule::Monthly { day_of_month, hour },
            Schedule::Yearly { month, day_of_month, hour } => RSchedule::Yearly { month, day_of_month, hour },
        }
    } 
}

impl From<RSchedule> for Schedule {
    fn from(v: RSchedule) -> Self {
        match v {
            RSchedule::Daily { hour } => Schedule::Daily { hour },
            RSchedule::EveryNDays { days, hour } => Schedule::EveryNDays { days, hour },
            RSchedule::Weekly { day_of_week, hour } => Schedule::Weekly { day_of_week, hour },
            RSchedule::Monthly { day_of_month, hour } => Schedule::Monthly { day_of_month, hour },
            RSchedule::Yearly { month, day_of_month, hour } => Schedule::Yearly { month, day_of_month, hour },
        }
    } 
}

#[frb]
pub enum RPriority {
    Lowest,
    Low,
    Medium,
    High,
    Highest
}

impl From<Priority> for RPriority {
    fn from(v: Priority) -> Self {
        match v {
            Priority::Lowest => RPriority::Lowest,
            Priority::Low => RPriority::Low,
            Priority::Medium => RPriority::Medium,
            Priority::High => RPriority::High,
            Priority::Highest => RPriority::Highest,
        }
    } 
}

impl From<RPriority> for Priority {
    fn from(v: RPriority) -> Self {
        match v {
            RPriority::Lowest => Priority::Lowest,
            RPriority::Low => Priority::Low,
            RPriority::Medium => Priority::Medium,
            RPriority::High => Priority::High,
            RPriority::Highest => Priority::Highest,
        }
    } 
}

#[frb]
pub enum RType {
    Periodic,
    OneTime,
}

impl From<Type> for RType {
    fn from(v: Type) -> Self {
        match v {
            Type::OneTime => RType::OneTime,
            Type::Periodic => RType::Periodic
        }
    } 
}

impl From<RType> for Type {
    fn from(v: RType) -> Self {
        match v {
            RType::OneTime => Type::OneTime,
            RType::Periodic => Type::Periodic
        }
    } 
}

#[frb(non_final)]
pub struct RTaskOptions {
    pub priority: Option<RPriority>,
    pub due_date: Option<String>,
    pub schedule: Option<RSchedule>,
    pub check_list: Option<Vec<String>>,
}

impl From<TaskOptions> for RTaskOptions {
    fn from(v: TaskOptions) -> Self {
        let p = if let Some(p) = v.priority { Some(p.into()) } else { None }; 
        let s = if let Some(s) = v.schedule { Some(s.into()) } else { None };
        Self {
            check_list: v.check_list,
            due_date: v.due_date,
            priority: p,
            schedule: s
        }
    } 
}

impl From<RTaskOptions> for TaskOptions {
    fn from(v: RTaskOptions) -> Self {
        let p = if let Some(p) = v.priority { Some(p.into()) } else { None }; 
        let s = if let Some(s) = v.schedule { Some(s.into()) } else { None };
        Self {
            check_list: v.check_list,
            due_date: v.due_date,
            priority: p,
            schedule: s
        }
    } 
}

#[frb(non_final)]
pub struct RTask {
    pub id: i64,
    pub title: String,
    pub description: String,
    pub task_type: RType,
    pub done: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub options: RTaskOptions,
    pub tags: Vec<RTag>
}