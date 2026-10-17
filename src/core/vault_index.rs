use std::{io::Result, path::PathBuf};

use crate::core::{entities::{dir::NDir, task::NTask}};

pub struct VaultIndex{
    pub directories: Vec<NDir>
}

impl VaultIndex {
    pub fn new() -> VaultIndex {
        VaultIndex { 
            directories: Vec::new()
        }
    }

    pub fn new_dir(&mut self, path: PathBuf) -> Result<()> {
        self.directories.push(NDir::new(path)?);
        Ok(())
    }

    pub fn refresh(&mut self) -> Result<()> {
        for dir in &mut self.directories {
            dir.refresh()?
        }
        Ok(())
    }

    pub fn get_all_tasks(&self) -> Vec<NTask> {
        let mut list = Vec::new();

        for dir in &self.directories {
            list.append(&mut dir.get_all_tasks());
        }

        list
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn test_vault_scanning() {
        // Create a temporary directory for testing
        let temp_dir = std::env::temp_dir().join("test_vault");
        let _ = fs::create_dir_all(&temp_dir);

        // Create a dummy markdown file inside it
        let dummy_file = temp_dir.join("note1.md");
        fs::write(&dummy_file, "- [ ] Test task in vault").unwrap();

        // Initialize and refresh the vault index
        let mut vault = VaultIndex::new();
        vault.new_dir(temp_dir.clone());
        let refresh_res = vault.refresh();

        assert!(refresh_res.is_ok());

        // Verify tasks are extracted properly across the vault
        let tasks = vault.get_all_tasks();
        assert_eq!(tasks.len(), 1);
        assert_eq!(tasks[0].text, "Test task in vault");

        // Clean up
        let _ = fs::remove_dir_all(temp_dir);
    }
}