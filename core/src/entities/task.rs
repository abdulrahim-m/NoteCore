use std::path::PathBuf;

use chrono::NaiveDate;
use regex::Regex;

pub struct NTask {
    pub text: String,
    pub completed: bool,
    pub due_date: Option<String>,
    pub source_file: PathBuf,
    pub line_number: usize,
}

impl NTask {
    pub fn new(source: &PathBuf, line: usize) -> NTask {
        NTask { 
            text: String::new(),
            completed: false,
            due_date: None,
            source_file: source.clone(),
            line_number: line
        }
    }

    pub fn from_line(line: &str, source: &PathBuf, line_number: usize) -> Option<NTask> {
        let re = Regex::new(r"^\s*[-*+]\s+\[([ xX])\]\s+(.*?)(?:\s+@(\d{4}-\d{2}-\d{2}))?$").ok()?;
        let caps = re.captures(line)?;
        
        let status = caps.get(1)?.as_str();
        let completed = status == "x" || status == "X";

        let text = caps.get(2)?.as_str().to_string();

        let due_date = caps.get(3).map(|m| m.as_str().to_string());
        
        Some(NTask{
            text,
            completed,
            due_date,
            source_file: source.clone(),
            line_number
        })
    }

    pub fn to_line(&self) -> String {
        let status = if self.completed { "x" } else { " " };

        let date_str = match &self.due_date {
            Some(date) => format!(" @{}", date),
            None => "".to_string(),
        };

        format!("- [{}] {}{}", status, self.text, date_str)
    }

    pub fn check_uncheck(&mut self) {
        self.completed = !self.completed
    }

    pub fn update(&mut self, text: String) {
        self.text = text
    }

    pub fn set_date(&mut self, date: NaiveDate) {
        self.due_date = Some(date.format("%Y-%m-%d").to_string())
    }

    pub fn read_date(&self) -> Option<NaiveDate> {
        self.due_date.as_ref().and_then(|d| NaiveDate::parse_from_str(&d, "%Y-%m-%d").ok())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;
    use chrono::NaiveDate;

    #[test]
    fn test_task_parsing_and_formatting() {
        let line = "- [ ] Buy groceries @2026-10-25";
        let path = PathBuf::from("test.md");
        
        let task = NTask::from_line(line, &path, 0);
        assert!(task.is_some());

        let mut task = task.unwrap();
        assert_eq!(task.text, "Buy groceries");
        assert_eq!(task.completed, false);
        assert_eq!(task.due_date, Some("2026-10-25".to_string()));

        task.check_uncheck();
        assert_eq!(task.completed, true);
        task.check_uncheck();
        assert_eq!(task.completed, false);

        assert_eq!(task.to_line(), line);
    }

    #[test]
    fn test_task_dates() {
        let path = PathBuf::from("test.md");
        let mut task = NTask::new(&path, 0);

        let date = NaiveDate::from_ymd_opt(2026, 12, 31).unwrap();
        task.set_date(date);

        assert_eq!(task.read_date(), Some(date));
        assert_eq!(task.to_line(), "- [ ]  @2026-12-31");
    }
}