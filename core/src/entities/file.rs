use std::{collections::HashMap, fs::{self, read_to_string}, io::Result, path::PathBuf};

use crate::{entities::task::NTask, utils::tasks::add_task_to_file};

pub struct NFile {
    pub path: PathBuf,
    pub title: String,
    pub metadata: HashMap<String, String>,
    pub content: String,
}

impl NFile {
    pub fn new(mut dir_path: PathBuf, title: &str) -> Result<NFile> {
        dir_path.push(format!("{}.md", title));

        let mut file = NFile {
            path: dir_path,
            title: title.to_string(), 
            metadata: HashMap::from([
                ("created_at".to_owned(), chrono::Local::now().to_string())
            ]), 
            content: String::new()
        };

        file.save()?;

        Ok(file)
    }

    pub fn save(&mut self) -> Result<()> {
        self.metadata.insert("modified".to_owned(), chrono::Local::now().to_rfc3339());

        let mut data = String::new();

        if !self.metadata.is_empty() {
            data += "---\n";

            for (k, v) in &self.metadata {
                data += &format!("{}: {}\n", k, v);
            }

            data += "---\n"
        }

        data += self.content.as_str();

        fs::write(&self.path, data)?;

        Ok(())
    }

    pub fn read(path: PathBuf) -> Result<NFile> {
        let con = read_to_string(&path)?;

        let final_content: String;
        let mut final_metadata = HashMap::new();

        if con.starts_with("---") {
            match con.lines().enumerate()
            .filter(|(_, line)| *line == "---").nth(1)
            .map(|(line_number, _)| line_number) {
                Some(lin) => {
                    let lines: Vec<&str> = con.lines().collect();
                    final_content = lines[lin+1..].join("\n");

                    for s in lines.iter().skip(1).take(lin - 1) {
                        if let Some((key, value)) = s.split_once(": ") {
                            final_metadata.insert(key.to_owned(), value.to_owned());
                        }
                    }
                },
                None => final_content = con
            }
        } else {
            final_content = con
        }

        let name = path
            .file_prefix()
            .and_then(|d| d.to_str())
            .unwrap_or("Unknown File")
            .to_owned();

        Ok(NFile { path, title: name, metadata: final_metadata, content: final_content })
    }

    pub fn update_title(&mut self, title: &str) -> Result<()> {
        let old_path = self.path.clone();
        if self.path.pop() {
            self.title = title.to_string();
            self.path.push(format!("{}.md",self.title));
        }
        self.save()?;
        fs::remove_file(old_path)
    }

    pub fn add_task(&mut self, new_task_text: &str, due_date: Option<String>) -> Option<NTask> {
        let mut file = NFile::read(self.path.clone()).ok()?;
        let task = add_task_to_file(&mut file, new_task_text, due_date);

        self.save().ok()?;

        task
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_file_save_and_read() {
        let temp_dir = std::env::temp_dir().join("file_test_vault");
        let _ = fs::create_dir_all(&temp_dir);

        // Create a new file instance
        let file = NFile::new(temp_dir.clone(), "untitled");
        assert!(file.is_ok());
        
        let mut file = file.unwrap();
        file.content = "Some note content\n- [ ] A sample task".to_owned();
        
        // Save it to disk
        assert_eq!(file.title, "untitled");
        assert!(file.save().is_ok());

        // Update title
        let res = file.update_title("TestNote");
        assert!(res.is_ok());
        assert_eq!(file.title, "TestNote");
        

        // Read it back
        let read_path = temp_dir.join("TestNote.md");
        let loaded = NFile::read(read_path);
        assert!(loaded.is_ok());

        let loaded = loaded.unwrap();
        assert_eq!(loaded.title, "TestNote");
        assert_eq!(loaded.content, "Some note content\n- [ ] A sample task");
        assert!(loaded.metadata.contains_key("created_at"));
        assert!(loaded.metadata.contains_key("modified"));

        // Add task without a date
        let res = file.add_task("Another simple task", None);
        assert!(res.is_some());

        let task = res.unwrap();
        assert_eq!(task.text, "Another simple task");
        assert!(task.due_date.is_none());

        // Add task with a date
        let res = file.add_task("A third simple task with date", Some("2021-11-05".to_string()));
        assert!(res.is_some());

        let task = res.unwrap();
        assert_eq!(task.text, "A third simple task with date");
        assert!(task.due_date.is_some());
        assert_eq!(task.due_date, Some("2021-11-05".to_string()));

        // Clean up
        let _ = fs::remove_dir_all(temp_dir);
    }
}