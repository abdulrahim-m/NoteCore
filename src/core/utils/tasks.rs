use crate::core::entities::{file::NFile, task::NTask};

pub fn extract_tasks_from_file(file: &NFile) -> Vec<NTask> {
    let mut tasks = Vec::new();

    for (index, line) in file.content.lines().enumerate() {
        if let Some(task) = NTask::from_line(line, &file.path, index) {
            tasks.push(task);
        }
    }

    tasks
}

pub fn add_task_to_file(file: &mut NFile, new_task_text: &str, due_date: Option<String>) -> NTask {
    // Construct the new task line
    let due_str = match due_date {
        Some(d) => format!(" @{}", d),
        None => "".to_string(),
    };
    let line_string = format!("- [ ] {}{}", new_task_text, due_str);

    // Append it to the file content with a newline
    if file.content.ends_with('\n') || file.content.is_empty() {
        file.content.push_str(&line_string);
    } else {
        file.content.push('\n');
        file.content.push_str(&line_string);
    }

    // return the line number of the new task
    NTask::new(&file.path, file.content.lines().count())
}