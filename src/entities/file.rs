use std::{collections::HashMap, fs::{self, read_to_string}, io::Result, path::Path};

pub struct NFile {
    pub title: String,
    pub metadata: HashMap<String, String>,
    pub content: String,
}

impl NFile {
    pub fn new() -> NFile {
        NFile { 
            title: "New Note File".to_owned(), 
            metadata: HashMap::from([
                ("created_at".to_owned(), chrono::Local::now().to_string())
            ]), 
            content: String::new()
        }
    }

    pub fn save(&mut self, path: &str) -> Result<()> {
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

        fs::write(format!("{}/{}.md",path, self.title), data)?;

        Ok(())
    }

    pub fn read(path: &str) -> Result<NFile> {
        let con = read_to_string(path)?;

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

        let name = Path::new(path)
            .file_prefix()
            .and_then(|d| d.to_str())
            .unwrap_or("Unknown File")
            .to_owned();

        Ok(NFile { title: name, metadata: final_metadata, content: final_content })
    }
}
