use clap::Parser;
use settings::Settings;
use std::fs;
use typst_lib::TypstWrapperWorld;
use typst_pdf::PdfOptions;

mod cli;
mod settings;

fn main() {
    let args = cli::Args::parse();
    let arg_config = args.to_runtime_config();
    let combined_config = Settings::new(args.config, &arg_config).unwrap();
    let config_content = combined_config.to_yaml().unwrap();

    if args.verbose {
        print!("{config_content}");
    }

    let template = include_str!("res/template.typ");
    let content = format!(
        r#"
        {template}

        #invoice(
            yaml(bytes("{config_content}"))
        )"#
    );

    let world = TypstWrapperWorld::new(".".to_owned(), content);

    let document = typst::compile(&world)
        .output
        .expect("Error compiling typst");

    let pdf = typst_pdf::pdf(&document, &PdfOptions::default()).expect("Error exporting PDF");
    fs::write(args.output, pdf).expect("Error writing PDF.");
}
