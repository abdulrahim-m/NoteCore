use crate::entities::file::NFile;

mod entities;

fn main() {
    let res = NFile::read("./New Note File.md");
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