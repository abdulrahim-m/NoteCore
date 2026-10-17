use std::path::PathBuf;

use crate::core::entities::file::NFile;

mod core;

fn main() {
    let res = NFile::read(PathBuf::from("./New Note File.md"));
    match res {
        Ok(some) => {
            println!("File name: {}", some.title);

            println!("Metadata:\n");
            for (k, v) in some.metadata {
                println!("{}: {}", k, v)
            }

            println!("\nContent: {}", some.content)
        },
        Err(err) => println!("Error reading file: {}", err)
    }
}