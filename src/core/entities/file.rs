use std::{collections::HashMap, fs::{self, read_to_string}, io::Result, path::PathBuf};

use crate::core::{entities::task::NTask, utils::tasks::add_task_to_file};

pub struct NFile {
    pub path: PathBuf,
    pub title: String,
    pub metadata: HashMap<String, String>,
    pub content: String,
}

impl NFile {
    pub fn new(mut dir_path: PathBuf) -> NFile {
        let title = "New Note File".to_owned();
        dir_path.push(format!("{}.md", title));

        NFile { 
            path: dir_path,
            title: title, 
            metadata: HashMap::from([
                ("created_at".to_owned(), chrono::Local::now().to_string())
            ]), 
            content: String::new()
        }
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

        let mut final_content = String::new();
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
        }

        let name = path
            .file_prefix()
            .and_then(|d| d.to_str())
            .unwrap_or("Unknown File")
            .to_owned();

        Ok(NFile { path, title: name, metadata: final_metadata, content: final_content })
    }

    pub fn add_task(&mut self, new_task_text: &str, due_date: Option<String>) -> Result<NTask> {
        let mut file = NFile::read(self.path.clone())?;
        let task = add_task_to_file(&mut file, new_task_text, due_date);

        self.save()?;

        Ok(task)
    }
}
