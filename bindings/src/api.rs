use std::path::PathBuf;

use notecore::vault_index::VaultIndex;

pub struct DartTask {
    pub text: String,
    pub completed: bool,
    pub due_date: Option<String>,
    pub source_file: String,
}

pub fn greet(name: String) -> String {
    format!("Hello from Rust core, {}! Your note engine is ready.", name)
}

pub struct NoteVaultBridge {
    vault: VaultIndex,
}

impl NoteVaultBridge {
    /// Initialize the vault with the local path chosen on mobile
    pub fn new(vault_path: String) -> Self {
        let mut vault = VaultIndex::new();
        let _ = vault.new_dir(PathBuf::from(vault_path));
        let _ = vault.refresh();
        Self { vault }
    }

    /// Refresh the vault files from disk
    pub fn refresh_vault(&mut self) -> Result<(), String> {
        self.vault.refresh().map_err(|e| e.to_string())
    }

    /// Get all tasks across the vault to display in Flutter's master task view
    pub fn get_all_tasks(&self) -> Vec<DartTask> {
        self.vault.get_all_tasks()
            .into_iter()
            .map(|t| DartTask {
                text: t.text,
                completed: t.completed,
                due_date: t.due_date,
                source_file: t.source_file.to_string_lossy().into_owned(),
            })
            .collect()
    }
}