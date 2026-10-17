use std::{fs, io::Result, path::PathBuf};

use crate::core::{entities::{file::NFile, task::NTask}, utils::tasks::extract_tasks_from_file};

pub struct NDir {
    pub path: PathBuf,
    pub sub_dirs: Vec<NDir>,
    pub files: Vec<PathBuf>
}

impl NDir {
    pub fn new(pth: PathBuf) -> NDir {
        NDir{
            path: pth,
            files: Vec::new(),
            sub_dirs: Vec::new()
        }
    }

    pub fn refresh(&mut self) -> Result<()> {
        let entries = fs::read_dir(&self.path)?;

        for entry in entries {
            let entry = entry?;
            let path_buf = entry.path();
            let path_str = path_buf.to_string_lossy().into_owned();

            if path_buf.is_dir() {
                // Skip hidden folders
                if let Some(folder_name) = path_buf.file_name().and_then(|n| n.to_str()) {
                    if folder_name.starts_with('.') {
                        continue;
                    }
                }

                let mut sub_dir = NDir::new(path_buf);
                if let Err(e) = sub_dir.refresh() {
                    println!("Error refreshing {}: {}", path_str, e)
                };

                self.sub_dirs.push(sub_dir);
            } else if path_buf.is_file() {
                // Only collect Markdown files
                if path_buf.extension().and_then(|s| s.to_str()) == Some("md") {
                    self.files.push(path_buf);
                }
            }
        }

        Ok(())
    }

    pub fn new_file(&self, name: &str) -> Result<NFile> {
        let mut new_path = self.path.clone();
        new_path.push(name);
        fs::write(&new_path, "")?;

        Ok(NFile::new(new_path))
    }

    pub fn get_all_tasks(&self) -> Vec<NTask> {
        let mut list = Vec::new();
        for dir in &self.sub_dirs {
            list.append(&mut dir.get_all_tasks());
        }
        for file in &self.files {
            list.append(&mut extract_tasks_from_file(&NFile::new(file.clone())));
        }

        list
    }
}