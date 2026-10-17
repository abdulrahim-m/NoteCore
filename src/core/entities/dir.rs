use std::{fs, io::Result, path::PathBuf};

use crate::core::{entities::{file::NFile, task::NTask}, utils::tasks::extract_tasks_from_file};

pub struct NDir {
    pub path: PathBuf,
    pub sub_dirs: Vec<NDir>,
    pub files: Vec<PathBuf>
}

impl NDir {
    pub fn new(pth: PathBuf) -> Result<NDir> {
        fs::create_dir_all(&pth)?;

        Ok(NDir{
            path: pth,
            files: Vec::new(),
            sub_dirs: Vec::new()
        })
    }

    pub fn refresh(&mut self) -> Result<()> {
        let entries = fs::read_dir(&self.path)?;
        let mut new_sub_dir = Vec::new();
        let mut new_files = Vec::new();

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

                let mut sub_dir = NDir::new(path_buf)?;
                if let Err(e) = sub_dir.refresh() {
                    println!("Error refreshing {}: {}", path_str, e)
                };

                new_sub_dir.push(sub_dir);
            } else if path_buf.is_file() {
                // Only collect Markdown files
                if path_buf.extension().and_then(|s| s.to_str()) == Some("md") {
                }
                new_files.push(path_buf);
            }
        }

        // Replace with new values
        self.sub_dirs.clear();
        self.sub_dirs.append(&mut new_sub_dir);

        self.files.clear();
        self.files.append(&mut new_files);

        Ok(())
    }

    pub fn new_file(&self, name: &str) -> Result<NFile> {
        let mut new_path = self.path.clone();
        new_path.push(name);
        fs::write(&new_path, "")?;

        NFile::new(new_path, name)
    }

    pub fn get_all_tasks(&self) -> Vec<NTask> {
        let mut list = Vec::new();
        for dir in &self.sub_dirs {
            list.append(&mut dir.get_all_tasks());
        }
        for file in &self.files {
            if let Ok(note_file) = NFile::read(file.clone()) {
                list.append(&mut extract_tasks_from_file(&note_file));
            }
        }

        list
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_dir_recursive_scanning_and_tasks() {
        // Initialize and refresh directory
        let temp_dir = std::env::temp_dir().join("dir_test_vault");
        let _ = fs::remove_dir_all(&temp_dir);

        let dir = NDir::new(temp_dir.clone());
        assert!(dir.is_ok());
        let mut dir = dir.unwrap();

        // Create a subdirectory inside the temp vault
        let sub_path = temp_dir.join("NestedFolder");
        let _ = fs::create_dir_all(&sub_path);

        // refresh
        assert!(dir.refresh().is_ok());

        // Check if subdirectory was found
        assert_eq!(dir.sub_dirs.len(), 1);
        assert_eq!(dir.sub_dirs[0].files.len(), 0);
        
        let file_path = sub_path.join("NestedNote.md");
        fs::write(&file_path, "- [ ] Nested Task @2026-11-01").unwrap();

        // refresh
        assert!(dir.refresh().is_ok());
        assert_eq!(dir.sub_dirs.len(), 1);
        assert_eq!(dir.sub_dirs[0].files.len(), 1);

        // Check if global task aggregation works across subdirectories
        let tasks = dir.get_all_tasks();
        assert_eq!(tasks.len(), 1);
        assert_eq!(tasks[0].text, "Nested Task");
        assert_eq!(tasks[0].due_date, Some("2026-11-01".to_string()));

        // Clean up
        let _ = fs::remove_dir_all(temp_dir);
    }
}