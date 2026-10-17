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

    pub fn new_dir(&mut self, path: PathBuf) {
        self.directories.push(NDir::new(path));
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