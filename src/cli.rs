use std::env;
use std::path::PathBuf;

use clap::ArgAction;
use clap::Parser;
use clap::builder::ValueParser;
use clap::crate_authors;

use serde::{Deserialize, Serialize};

use crate::settings::Item;

#[derive(Parser, Debug, Serialize, Deserialize)]
#[command(
    version,
    about = "Minimalistic CLI invoice generator",
    author = crate_authors!("\n"),
    after_help = r#"
    Example usage;
    pekmez-invoice --number 123 --date 25.10.2025 "Misdirecting witnesses=5000" --item "Taking forever to deduce the obvious=12999" --config ./src/res/details.yaml
    "#,
)]
pub struct Args {
    #[arg(short = 'n', long = "number", help = "Invoice number")]
    pub number: String,

    #[arg(short = 'd', long = "date", help = "Invoice date")]
    pub date: String,

    #[arg(
        short = 'c',
        long = "config",
        value_name = "FILE",
        help = "Config file path. If left undefined, tries to find in sensible places, like $HOME, $XDG_CONFIG_HOME or $USERPROFILE"
    )]
    pub config: Option<PathBuf>,

    #[arg(
        short = 'o',
        long = "output",
        help = "Output file",
        value_name = "FILE",
        default_value = r"output.pdf"
    )]
    pub output: PathBuf,

    #[clap(
        short = 'i',
        long = "item",
        help = "Invoice lines",
        value_name = "DESCRIPTION=PRICE",
        action = ArgAction::Append,
        value_parser = ValueParser::new(parse_items),
        required = true,
    )]
    pub items: Vec<Item>,

    #[clap(short = 'v', long = "verbose")]
    pub verbose: bool,
}

#[derive(Serialize, Deserialize)]
pub struct RuntimeConfig {
    number: String,
    date: String,
    items: Vec<Item>,
}

impl Args {
    pub fn to_runtime_config(&self) -> RuntimeConfig {
        RuntimeConfig {
            number: self.number.clone(),
            date: self.date.clone(),
            items: self.items.clone(),
        }
    }
}

fn parse_items(raw: &str) -> Result<Item, String> {
    let (desc, price) = raw
        .rsplit_once('=')
        .ok_or("item must be a description and a price separated by an equal sign")?;

    Ok(Item {
        desc: desc.trim().to_owned(),
        price: price.trim().to_owned(),
    })
}
