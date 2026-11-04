use chrono::{DateTime, Utc};
use notecore::models::tasks::task::{Priority, Schedule, SubTask, TaskOptions, Type, Weekday};
use notecore::models::tasks::ui_task::UITask;

use super::tag::{map_tags, TagDto};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TaskTypeDto {
    Periodic,
    OneTime,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WeekdayDto {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday
}

impl From<Weekday> for WeekdayDto {
    fn from(s: Weekday) -> Self {
        match s {
            Weekday::Sunday => WeekdayDto::Sunday,
            Weekday::Monday => WeekdayDto::Monday,
            Weekday::Tuesday => WeekdayDto::Tuesday,
            Weekday::Wednesday => WeekdayDto::Wednesday,
            Weekday::Thursday => WeekdayDto::Thursday,
            Weekday::Friday => WeekdayDto::Friday,
            Weekday::Saturday => WeekdayDto::Saturday,
        }
    }
}

impl From<WeekdayDto> for Weekday {
    fn from(s: WeekdayDto) -> Self {
        match s {
            WeekdayDto::Sunday => Weekday::Sunday,
            WeekdayDto::Monday => Weekday::Monday,
            WeekdayDto::Tuesday => Weekday::Tuesday,
            WeekdayDto::Wednesday => Weekday::Wednesday,
            WeekdayDto::Thursday => Weekday::Thursday,
            WeekdayDto::Friday => Weekday::Friday,
            WeekdayDto::Saturday => Weekday::Saturday,
        }
    }
}

impl From<Type> for TaskTypeDto {
    fn from(t: Type) -> Self {
        match t {
            Type::Periodic => TaskTypeDto::Periodic,
            Type::OneTime => TaskTypeDto::OneTime,
        }
    }
}

impl From<TaskTypeDto> for Type {
    fn from(t: TaskTypeDto) -> Self {
        match t {
            TaskTypeDto::Periodic => Type::Periodic,
            TaskTypeDto::OneTime => Type::OneTime,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PriorityDto {
    Lowest,
    Low,
    Medium,
    High,
    Highest,
}

impl From<Priority> for PriorityDto {
    fn from(p: Priority) -> Self {
        match p {
            Priority::Lowest => PriorityDto::Lowest,
            Priority::Low => PriorityDto::Low,
            Priority::Medium => PriorityDto::Medium,
            Priority::High => PriorityDto::High,
            Priority::Highest => PriorityDto::Highest,
        }
    }
}

impl From<PriorityDto> for Priority {
    fn from(p: PriorityDto) -> Self {
        match p {
            PriorityDto::Lowest => Priority::Lowest,
            PriorityDto::Low => Priority::Low,
            PriorityDto::Medium => Priority::Medium,
            PriorityDto::High => Priority::High,
            PriorityDto::Highest => Priority::Highest,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ScheduleDto {
    Daily { hour: u8 },
    EveryNDays { days: u32, hour: u8 },
    Weekly { days_of_week: Vec<WeekdayDto>, hour: u8 }, 
    Monthly { day_of_month: u8, hour: u8 },
    Yearly { month: u8, day_of_month: u8, hour: u8 },
}

impl From<Schedule> for ScheduleDto {
    fn from(s: Schedule) -> Self {
        match s {
            Schedule::Daily { hour } => ScheduleDto::Daily { hour },
            Schedule::EveryNDays { days, hour } => ScheduleDto::EveryNDays { days, hour },
            Schedule::Weekly { days_of_week, hour } => 
                ScheduleDto::Weekly { 
                    days_of_week: days_of_week.into_iter().map(|w| w.into()).collect(), 
                    hour 
                },
            Schedule::Monthly { day_of_month, hour } => {
                ScheduleDto::Monthly { day_of_month, hour }
            }
            Schedule::Yearly { month, day_of_month, hour } => {
                ScheduleDto::Yearly { month, day_of_month, hour }
            }
        }
    }
}

impl From<ScheduleDto> for Schedule {
    fn from(s: ScheduleDto) -> Self {
        match s {
            ScheduleDto::Daily { hour } => Schedule::Daily { hour },
            ScheduleDto::EveryNDays { days, hour } => Schedule::EveryNDays { days, hour },
            ScheduleDto::Weekly { days_of_week, hour } => 
                Schedule::Weekly { 
                    days_of_week: days_of_week.into_iter().map(|w| w.into()).collect(), 
                    hour 
                },
            ScheduleDto::Monthly { day_of_month, hour } => {
                Schedule::Monthly { day_of_month, hour }
            }
            ScheduleDto::Yearly { month, day_of_month, hour } => {
                Schedule::Yearly { month, day_of_month, hour }
            }
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct TaskOptionsDto {
    pub priority: Option<PriorityDto>,
    pub due_date: Option<String>,
    pub schedule: Option<ScheduleDto>,
    pub check_list: Option<Vec<SubTaskDto>>,
}

impl From<TaskOptions> for TaskOptionsDto {
    fn from(o: TaskOptions) -> Self {
        TaskOptionsDto {
            priority: o.priority.map(PriorityDto::from),
            due_date: o.due_date,
            schedule: o.schedule.map(ScheduleDto::from),
            check_list: o.check_list.map(|s| s.into_iter().map(Into::into).collect()),
        }
    }
}

impl From<TaskOptionsDto> for TaskOptions {
    fn from(o: TaskOptionsDto) -> Self {
        TaskOptions {
            priority: o.priority.map(Priority::from),
            due_date: o.due_date,
            schedule: o.schedule.map(Schedule::from),
            check_list: o.check_list.map(|s| s.into_iter().map(Into::into).collect()),
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct SubTaskDto {
    pub text: String,
    pub checked: bool
}

impl From<SubTask> for SubTaskDto {
    fn from(s: SubTask) -> Self {
        SubTaskDto { text: s.text, checked: s.checked }
    }
}

impl From<SubTaskDto> for SubTask {
    fn from(s: SubTaskDto) -> Self {
        SubTask { text: s.text, checked: s.checked }
    }
}

#[derive(Debug, Clone, Default)]
pub struct TaskSearchParamsDto {
    pub text: Option<String>,
    pub tags: Option<Vec<i64>>,
    pub created_before: Option<DateTime<Utc>>,
    pub created_after: Option<DateTime<Utc>>,
    pub priority: Option<PriorityDto>,
    pub due_date_before: Option<DateTime<Utc>>,
    pub due_date_after: Option<DateTime<Utc>>,
}

impl From<TaskSearchParamsDto> for notecore::models::tasks::task::TaskSearchParams {
    fn from(p: TaskSearchParamsDto) -> Self {
        Self {
            text: p.text,
            tags: p.tags,
            created_before: p.created_before,
            created_after: p.created_after,
            priority: p.priority.map(Into::into),
            due_date_before: p.due_date_before,
            due_date_after: p.due_date_after,
        }
    }
}

#[derive(Debug, Clone)]
pub struct TaskDto {
    pub id: i64,
    pub title: String,
    pub description: String,
    pub task_type: TaskTypeDto,
    pub done: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub options: TaskOptionsDto,
    pub tags: Vec<TagDto>,
}

impl From<UITask> for TaskDto {
    fn from(t: UITask) -> Self {
        TaskDto {
            id: t.id,
            title: t.title,
            description: t.description,
            task_type: t.task_type.into(),
            done: t.done,
            created_at: t.created_at,
            updated_at: t.updated_at,
            options: t.options.into(),
            tags: map_tags(t.tags),
        }
    }
}
