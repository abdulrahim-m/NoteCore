use std::path::PathBuf;

use chrono::NaiveDate;
use regex::Regex;

pub struct NTask {
    text: String,
    completed: bool,
    due_date: Option<String>,
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