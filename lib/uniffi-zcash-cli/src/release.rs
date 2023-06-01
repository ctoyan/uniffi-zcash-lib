use std::{
    fs::{copy, create_dir_all, read_to_string, OpenOptions},
    io::Write,
    ops::Add,
    path::PathBuf,
    process::Command,
};

use fs_extra::dir::{self, CopyOptions};
use serde_json::json;

use crate::{
    cli::CLIResult,
    helper::{
        clean_dir, cmd_success, in_file_template_replace, tmp_folder, LINUX_SHARED_LIB_NAME,
        MACOS_SHARED_LIB_NAME,
    },
};

pub fn python(cfg: &PythonConfig) -> CLIResult<()> {
    cfg.bindings_dir.try_exists()?;
    clean_dir(&cfg.package_dir)?;

    dir::copy(
        &cfg.package_template_dir,
        &cfg.package_dir,
        &CopyOptions::new().content_only(true),
    )?;

    // Copy all needed files from previously generated bindings operation

    copy(
        cfg.bindings_dir.join(LINUX_SHARED_LIB_NAME),
        cfg.package_dir.join("zcash").join(LINUX_SHARED_LIB_NAME),
    )?;
    copy(
        cfg.bindings_dir.join(MACOS_SHARED_LIB_NAME),
        cfg.package_dir.join("zcash").join(MACOS_SHARED_LIB_NAME),
    )?;
    copy(
        cfg.bindings_dir.join("zcash.py"),
        cfg.package_dir.join("zcash").join("zcash.py"),
    )?;

    // Modify in place setup.py in order to set version in the template.
    let setup_py_path = cfg.package_dir.join("setup.py");
    in_file_template_replace(setup_py_path, &json!({ "version": cfg.version }))?;

    // Prepare python distribution files
    cmd_success(
        Command::new("python")
            .arg("-m")
            .arg("pip")
            .arg("install")
            .arg("--user")
            .arg("--upgrade")
            .arg("build")
            .spawn()?
            .wait(),
    )?;

    cmd_success(
        Command::new("python")
            .arg("-m")
            .arg("build")
            .current_dir(&cfg.package_dir)
            .spawn()?
            .wait(),
    )?;

    // Install lib and test.
    cmd_success(
        Command::new("python")
            .arg("-m")
            .arg("pip")
            .arg("install")
            .arg("--force-reinstall")
            .arg(".")
            .current_dir(&cfg.package_dir)
            .spawn()?
            .wait(),
    )?;

    let test_app_path = tmp_folder()?;

    dir::copy(
        &cfg.test_app_template_dir,
        &test_app_path,
        &CopyOptions::new().content_only(true),
    )?;

    cmd_success(
        Command::new("python")
            .arg("app.py")
            .current_dir(test_app_path)
            .spawn()?
            .wait(),
    )
}

pub struct PythonConfig {
    pub version: String,
    pub package_template_dir: PathBuf,
    pub test_app_template_dir: PathBuf,
    pub bindings_dir: PathBuf,
    pub package_dir: PathBuf,
}

pub fn ruby(cfg: &RubyConfig) -> CLIResult<()> {
    cfg.bindings_dir.try_exists()?;
    clean_dir(&cfg.package_dir)?;

    dir::copy(
        &cfg.package_template_dir,
        &cfg.package_dir,
        &CopyOptions::new().content_only(true),
    )?;

    // Copy all needed files from previously generated bindings operation
    copy(
        cfg.bindings_dir.join(LINUX_SHARED_LIB_NAME),
        cfg.package_dir.join("lib").join(LINUX_SHARED_LIB_NAME),
    )?;
    copy(
        cfg.bindings_dir.join(MACOS_SHARED_LIB_NAME),
        cfg.package_dir.join("lib").join(MACOS_SHARED_LIB_NAME),
    )?;
    copy(
        cfg.bindings_dir.join("zcash.rb"),
        cfg.package_dir.join("lib").join("zcash.rb"),
    )?;

    // Modify in place the gemspec in order to set version in the template.

    let gemspec_path = cfg.package_dir.join("zcash.gemspec");
    in_file_template_replace(gemspec_path, &json!({ "version": cfg.version }))?;

    // Super hack 🔥. In order to be able to load shared library provided in the gem,
    // we need either to provide to the "ffi_lib" function loader (see zcash.rb) an absolute path
    // or a library name which was previously added to $LD_LIBRARY_PATH for lookup.
    //
    // In our case we want the former option. That is normally done by using the
    // caller file (zcash.rb) as reference, calculating the absolute path from its path.
    // But the zcash.rb file is generated by UniFFI and its out of our control.
    // So, we search and replace after the "bindgen" CLI command generates it.
    // We also make use of the 'os' gem, in order to detect in runtime what shared
    // library its needed .so or .dylib.

    let binding_file = cfg.package_dir.join("lib").join("zcash.rb");
    let original_content = read_to_string(&binding_file)?;
    let content = "require 'os' \n".to_string().add(&original_content);
    let result = content.replace(
        "ffi_lib 'uniffi_zcash'",
        "ffi_lib File.join(File.dirname(File.expand_path(__FILE__)), '/libuniffi_zcash' + (OS.windows? && '.dll' || OS.mac? && '.dylib' || '.so'))",
    );

    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(binding_file)?;
    file.write_all(result.as_bytes())?;

    // Prepare Ruby distribution files

    cmd_success(
        Command::new("gem")
            .arg("build")
            .arg("zcash.gemspec")
            .current_dir(&cfg.package_dir)
            .spawn()?
            .wait(),
    )?;

    // Install and test
    cmd_success(
        Command::new("gem")
            .arg("install")
            .arg(format!("./zcash-{}.gem", cfg.version))
            .current_dir(&cfg.package_dir)
            .spawn()?
            .wait(),
    )?;

    let test_app_path = tmp_folder()?;
    dir::copy(
        &cfg.test_app_template_dir,
        &test_app_path,
        &CopyOptions::new().content_only(true),
    )?;

    cmd_success(
        Command::new("ruby")
            .arg("app.rb")
            .current_dir(test_app_path)
            .spawn()?
            .wait(),
    )
}

pub struct RubyConfig {
    pub version: String,
    pub package_template_dir: PathBuf,
    pub test_app_template_dir: PathBuf,
    pub bindings_dir: PathBuf,
    pub package_dir: PathBuf,
}

pub fn kotlin(cfg: &KotlinConfig) -> CLIResult<()> {
    cfg.bindings_dir.try_exists()?;
    clean_dir(&cfg.package_dir)?;

    dir::copy(
        &cfg.package_template_dir,
        &cfg.package_dir,
        &CopyOptions::new().content_only(true),
    )?;

    // Copy all needed files from previously generated bindings operation
    let bindings_code = cfg.bindings_dir.join("uniffi").join("zcash");
    copy(
        bindings_code.join(LINUX_SHARED_LIB_NAME),
        cfg.package_dir
            .join("lib")
            .join("libs")
            .join(LINUX_SHARED_LIB_NAME),
    )?;
    copy(
        bindings_code.join(MACOS_SHARED_LIB_NAME),
        cfg.package_dir
            .join("lib")
            .join("libs")
            .join(MACOS_SHARED_LIB_NAME),
    )?;
    copy(
        bindings_code.join("zcash.kt"),
        cfg.package_dir
            .join("lib")
            .join("src")
            .join("main")
            .join("kotlin")
            .join("zcash")
            .join("Zcash.kt"),
    )?;

    // Modify in place the build.gradle.kts in order to set version in the template.
    let gradle_path = cfg.package_dir.join("lib").join("build.gradle.kts");
    in_file_template_replace(gradle_path, &json!({ "version": cfg.version }))?;

    // Publish to local Maven, check everything is ok. Next step will exercise the dependency.
    cmd_success(
        Command::new("gradle")
            .arg("publishToMavenLocal")
            .current_dir(&cfg.package_dir)
            .spawn()?
            .wait(),
    )?;

    // Execute the little, built in APP test. Ensure all the build chain is ok.
    let test_app_path = tmp_folder()?;

    dir::copy(
        &cfg.test_app_template_dir,
        &test_app_path,
        &CopyOptions::new().content_only(true),
    )?;

    in_file_template_replace(
        test_app_path.join("app").join("build.gradle.kts"),
        &json!({ "version": cfg.version }),
    )?;

    cmd_success(
        Command::new("gradle")
            .arg("run")
            .current_dir(test_app_path)
            .spawn()?
            .wait(),
    )
}

pub struct KotlinConfig {
    pub version: String,
    pub package_template_dir: PathBuf,
    pub test_app_template_dir: PathBuf,
    pub bindings_dir: PathBuf,
    pub package_dir: PathBuf,
}

pub fn swift(cfg: &SwiftConfig) -> CLIResult<()> {
    cfg.bindings_dir.try_exists()?;
    clean_dir(&cfg.package_dir)?;

    // Generate a /tmp subfolder , so git does not have problems git the parent
    // project repository. From here all operations will be done in that folder.
    let tmp_package_dir = std::env::temp_dir().join("zcash_uniffi_swift_package_build");
    clean_dir(&tmp_package_dir)?;

    // We will leave a pointer (a text file) to properly signalize we are operating
    // outside the working tree, by adding the absolute path to the temporary subfolder.
    let mut pointer = OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .open(cfg.package_dir.join("processing_at.txt"))?;
    pointer.write_all(tmp_package_dir.to_str().unwrap().as_bytes())?;

    let package_subfolder = tmp_package_dir.join("Zcash");

    create_dir_all(&package_subfolder)?;

    cmd_success(
        Command::new("git")
            .arg("clone")
            .arg(&cfg.git_repo_url)
            .arg(&package_subfolder)
            .spawn()?
            .wait(),
    )?;

    dir::copy(
        &cfg.package_template_dir,
        &package_subfolder,
        &CopyOptions::new().overwrite(true).content_only(true),
    )?;

    // Copy all needed files from previously generated bindings operation
    copy(
        cfg.bindings_dir.join(LINUX_SHARED_LIB_NAME),
        package_subfolder
            .join("Sources")
            .join("zcashFFI")
            .join(LINUX_SHARED_LIB_NAME),
    )?;
    copy(
        cfg.bindings_dir.join(MACOS_SHARED_LIB_NAME),
        package_subfolder
            .join("Sources")
            .join("zcashFFI")
            .join(MACOS_SHARED_LIB_NAME),
    )?;
    copy(
        cfg.bindings_dir.join("zcashFFI.h"),
        package_subfolder
            .join("Sources")
            .join("zcashFFI")
            .join("uniffi_zcash.h"),
    )?;
    copy(
        cfg.bindings_dir.join("zcash.swift"),
        package_subfolder
            .join("Sources")
            .join("Zcash")
            .join("zcash.swift"),
    )?;

    // Commit and tag the version
    cmd_success(
        Command::new("git")
            .arg("add")
            .arg(".")
            .current_dir(&package_subfolder)
            .spawn()?
            .wait(),
    )?;

    cmd_success(
        Command::new("git")
            .arg("commit")
            .arg("-m")
            .arg(format!("Version {}", &cfg.version))
            .current_dir(&package_subfolder)
            .spawn()?
            .wait(),
    )?;

    cmd_success(
        Command::new("git")
            .arg("tag")
            .arg(&cfg.version)
            .current_dir(&package_subfolder)
            .spawn()?
            .wait(),
    )?;

    // Execute the test app for testing all generated stuff.
    let test_app_path = tmp_folder()?;

    dir::copy(
        &cfg.test_app_template_dir,
        &test_app_path,
        &CopyOptions::new().content_only(true),
    )?;

    // Use the previously generated git package for testing against.
    let data = &json!({ "version": cfg.version, "git_repo_path": &package_subfolder});
    in_file_template_replace(test_app_path.join("Package.swift"), data)?;

    let generated_shared_lib_path = package_subfolder.join("Sources").join("zcashFFI");
    cmd_success(
        Command::new("swift")
            .current_dir(test_app_path)
            .arg("run")
            .arg("-Xlinker")
            .arg(format!(
                "-L{}",
                generated_shared_lib_path.as_path().to_string_lossy()
            ))
            .env("LD_LIBRARY_PATH", generated_shared_lib_path)
            .spawn()?
            .wait(),
    )
}

pub struct SwiftConfig {
    pub version: String,
    pub git_repo_url: String,
    pub package_template_dir: PathBuf,
    pub test_app_template_dir: PathBuf,
    pub bindings_dir: PathBuf,
    pub package_dir: PathBuf,
}
