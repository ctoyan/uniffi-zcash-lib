use std::fs::{read_to_string, OpenOptions};
use std::io::Write;
use std::path::Path;


fn main() {
    println!("cargo:rerun-if-changed=src/udl");
    println!("cargo:rerun-if-changed=../uniffi-zcash-test/src/udl");
    generate_udl_file();

    uniffi::generate_scaffolding("./src/zcash.udl").unwrap();
}

fn generate_udl_file() {
    let mut content =
        "/* Autogenerated by the `build.rs` script - do not modify */\n\n".to_string();

    content.push_str(&join_udl_files(&[
        "src/udl",
        "../uniffi-zcash-test/src/udl",
    ]));

    content.push_str("\n/* vi:set ft=cs syn=cs: */");

    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .open("src/zcash.udl")
        .unwrap();

    writeln!(file, "{content}").unwrap();
}

fn join_udl_files<P: AsRef<Path>>(paths: &[P]) -> String {
    paths
        .iter()
        .map(|path| {
            if path.as_ref().is_dir() {
                join_udl_files(
                    &path
                        .as_ref()
                        .read_dir()
                        .unwrap()
                        .filter_map(|entry| {
                            let path = entry.unwrap().path();
                            if path.is_dir() || is_udl_file(&path) {
                                Some(path)
                            } else {
                                None
                            }
                        })
                        .collect::<Vec<_>>(),
                )
            } else {
                read_to_string(path).unwrap_or_else(|error| {
                    panic!(
                        "error occurred while trying to read \"{}\": {error}",
                        path.as_ref()
                            .to_str()
                            .unwrap_or("<couldn't convert path to string>")
                    )
                })
            }
        })
        .collect::<Vec<String>>()
        .join("\n")
}

fn is_udl_file<P: AsRef<Path>>(path: P) -> bool {
    let path = path.as_ref();
    path.is_file()
        && path
            .extension()
            .map(|extension| extension == "udl")
            .unwrap_or_default()
}
