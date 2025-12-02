use std::env;
use std::path::Path;
use std::path::PathBuf;

use config::Config;
use config::ConfigError;
use config::FileFormat;
use config::FileSourceFile;
use config::FileSourceString;
use serde::Deserialize;
use serde::Serialize;
use serde_yaml::Error;

#[derive(Debug, Serialize, Deserialize)]
#[allow(unused)]
pub struct Author {
    name: String,
    street: String,
    zip: String,
    city: String,
    country: String,
    tax_nr: String,
}

#[derive(Debug, Serialize, Deserialize)]
#[allow(unused)]
pub struct Recipient {
    name: String,
    street: String,
    zip: String,
    city: String,
    country: String,
}

#[derive(Debug, Serialize, Deserialize)]
#[allow(unused)]
pub struct Labeled {
    label: String,
    value: String,
}

#[derive(Debug, Serialize, Deserialize)]
#[allow(unused)]
pub struct Labels {
    invoice: String,
    pos: String,
    description: String,
    price: String,
    subtotal: String,
    total: String,
    tax: String,
    currency: String,
    tax_number: String,
    closing_statement: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[allow(unused)]
pub struct Item {
    pub desc: String,
    pub price: String,
}

#[derive(Debug, Serialize, Deserialize)]
#[allow(unused)]
pub struct Settings {
    author: Option<Author>,
    recipient: Option<Recipient>,
    payment: Option<Vec<Labeled>>,
    labels: Labels,
    items: Vec<Item>,
    number: String,
    date: String,
    tax: Option<String>,
    notes: Option<String>,
}

impl Settings {
    fn home_conf() -> Option<config::File<FileSourceFile, FileFormat>> {
        env::var("XDG_CONFIG_HOME")
            .map(PathBuf::from)
            .or_else(|_| env::var("HOME").map(|x| PathBuf::from(x).join(".config")))
            .or_else(|_| env::var("USERPROFILE").map(PathBuf::from))
            .or_else(|_| env::var("APPDATA").map(PathBuf::from))
            .map(|home| {
                home.join(std::env::var("CARGO_PKG_NAME").unwrap_or("pekmez-invoice".to_owned()))
                    .join("config.yaml")
            })
            .ok()
            .and_then(|x| Path::exists(x.as_path()).then_some(x))
            .map(|x| config::File::from(x))
    }

    fn default() -> config::File<FileSourceString, FileFormat> {
        config::File::from_str(include_str!("res/defaults.yaml"), FileFormat::Yaml)
    }

    pub fn new<T: Serialize>(file: Option<PathBuf>, c: T) -> Result<Self, ConfigError> {
        let root = Config::builder();

        let with_cli = match file.map(config::File::from) {
            None => {
                let with_defaults = root.add_source(Self::default());

                let with_home = match Self::home_conf().map(config::File::from) {
                    None => with_defaults,
                    Some(home) => with_defaults.add_source(home),
                };

                with_home.add_source(config::Environment::with_prefix("PEKMEZ"))
            }
            Some(configured_file) => root.add_source(configured_file),
        };

        let runtime_config = serde_yaml::to_string(&c).unwrap();

        with_cli
            .add_source(config::File::from_str(&runtime_config, FileFormat::Yaml))
            .build()?
            .try_deserialize()
    }

    pub fn to_yaml(&self) -> Result<String, Error> {
        serde_yaml::to_string(&self)
    }
}
