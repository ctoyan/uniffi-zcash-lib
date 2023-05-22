use self::error::CLIError;
use crate::SupportedLang;
use clap::{builder::{ValueParser, PossibleValuesParser}, Arg, ArgMatches, Command};
use strum::VariantNames;

pub mod error;

pub fn get_matches() -> ArgMatches {
    Command::new("UniFFI Zcash CLI")
        .version(env!("CARGO_PKG_VERSION"))
        .about("A CLI for managing internal repo workflows")
        .subcommand_required(true)
        .arg(
            Arg::new("enabled_languages")
            .long("enabled-languages")
            .env("ENABLED_LANGUAGES")
            .value_delimiter(',')
            .value_parser(PossibleValuesParser::new(SupportedLang::VARIANTS))
            .required(false)
            .default_values(SupportedLang::VARIANTS)
        )
        .subcommand(
            Command::new("bindgen").about(format!(
            "Generates UniFFI bindings for all the supported languages ({}) and places it in the bindings directory",
            SupportedLang::VARIANTS.join(",")
        )))
        .subcommand(
            Command::new("release")
            .about("Prepares a release for a given a version (semantic versioning). It needs to be executed after the 'bindgen' command.")
            .subcommand(Command::new("python").about("Prepares release for Python.")
                .arg(arg_version())
            )
            .subcommand(Command::new("ruby").about("Prepares release for Ruby.")
                .arg(arg_version())           
            )
            .subcommand(Command::new("kotlin").about("Prepares release for Kotlin.")
                .arg(arg_version())
            )   
            .subcommand(Command::new("swift").about("Prepares release for Swift.")
                .arg(arg_version())
                .arg(arg_swift_git_repo_url())
            )
        )
        .subcommand(
            Command::new("publish")
            .about("It Publish the packages generated by the 'release' CLI subcommand for the different languages.")
            .subcommand(Command::new("python")
                .arg(
                    Arg::new("registry_url")
                    .long("registry-url")
                    .required(true)
                    .env("PYTHON_REGISTRY_URL")
                    .help("The http[s] URL of the target python package index. i.e https://upload.pypi.org/legacy/")
                )
                .arg(
                    Arg::new("registry_username")
                    .long("registry-username")
                    .required(true)
                    .env("PYTHON_REGISTRY_USERNAME")
                    .help("The pypi username. Should be '__token__' if using token auth.")
                )
                .arg(
                    Arg::new("registry_password")
                    .long("registry-password")
                    .required(true)
                    .env("PYTHON_REGISTRY_PASSWORD")
                    .help("The pypi password. In case of token auth, including the prefix 'pypi'.")
                )
            )
            .subcommand(Command::new("ruby")
                .arg(arg_version())
                .arg(
                    Arg::new("registry_url")
                    .long("registry-url")
                    .required(true)
                    .env("RUBY_REGISTRY_URL")
                    .help("The http[s] URL of the target ruby package index. i.e https://rubygems.org")
                )
                .arg(
                    Arg::new("registry_token")
                    .long("registry-token")
                    .required(true)
                    .env("RUBY_REGISTRY_TOKEN")
                    .help("The ruby API key.")
                )
            
            )
            .subcommand(Command::new("kotlin")
                .arg(
                    Arg::new("registry_url")
                    .long("registry-url")
                    .required(true)
                    .env("KOTLIN_REGISTRY_URL")
                    .help("The http[s] URL of the target kotlin package index. i.e https://repo.maven.apache.org/maven2/")
                )
                .arg(
                    Arg::new("registry_username")
                    .long("registry-username")
                    .required(true)
                    .env("KOTLIN_REGISTRY_USERNAME")
                    .help("The kotlin registry username, if using token, probably set this to 'token' .")
                )
                .arg(
                    Arg::new("registry_password")
                    .long("registry-password")
                    .required(true)
                    .env("KOTLIN_REGISTRY_PASSWORD")
                    .help("The kotlin registry password, can be also a token.")
                )            
            )
            .subcommand(Command::new("swift").about("Holds the Swift language subcommands")
                .subcommand(Command::new("git-repo")
                    .about("Publish a previously generated package to a Git swift repository.")
                    .arg(arg_swift_git_repo_url())                
                )
                .subcommand(Command::new("registry")
                    .about("Publish a previously generated package to a registry like https://swiftpackageindex.com/ .")
                    .arg(arg_version())
                    .arg(
                        Arg::new("registry_url")
                        .long("registry-url")
                        .required(true)
                        .env("SWIFT_REGISTRY_URL")
                        .help("The swift registry url. i.e https://swiftpackageindex.com/")
                    )
                    .arg(
                        Arg::new("registry_token")
                        .long("registry-token")
                        .required(true)
                        .env("SWIFT_REGISTRY_TOKEN")
                        .help("The swift registry token.")
                    )
                )               
            )
        )
        .get_matches()
}

fn arg_version() -> Arg {
    Arg::new("version")
        .short('v')
        .long("version")
        .env("PACKAGE_VERSION")
        .required(true)
        .value_parser(validator_semver())
}

fn arg_swift_git_repo_url() -> Arg {
    Arg::new("git_repo_url")
    .long("git-repo-url")
    .required(true)
    .env("SWIFT_GIT_REPO_URL")
    .help("For auth, use a Github personal access token.\nSee https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token\nExample: https://<github-username>:<github-token>@github.com/<your-repository>.git")
}

/// See https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
const REGEX_SEMVER: &str = r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$";
/// It generates a validator for semantic versioning
pub fn validator_semver() -> ValueParser {
    validator_regex(REGEX_SEMVER, "semver: https://semver.org")
}

/// Creates a clap validator (using ValueParser API) with a regex.
/// # Arguments
///
/// * `regex`   - The regex to test against.
/// * `err_msg` - Is a human friendly message to show in case the parser fails.
pub fn validator_regex(regex: &'static str, err_msg: &'static str) -> ValueParser {
    ValueParser::from(move |input: &str| -> CLIResult<String> {
        let reg = regex::Regex::new(regex).unwrap();
        match reg.is_match(input) {
            true => Ok(input.to_owned()),
            false => Err(format!("Value \"{}\" is not matching format: {}", input, err_msg).into()),
        }
    })
}

pub type CLIResult<T> = Result<T, CLIError>;
