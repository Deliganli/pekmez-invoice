
# Pekmez Invoice

Minimalistic CLI friendly invoice generator

![](./example/myinvoice.png)

Tried to get the looks from the projects in the <a href="#thanks">thanks</a> section.
Removed the complexity I didn't understand myself and added support to call it
from CLI.

## Usage

```
Minimalistic CLI invoice generator

Usage: pekmez-invoice [OPTIONS] --number <NUMBER> --date <DATE> --item <DESCRIPTION=PRICE>

Options:
  -n, --number <NUMBER>           Invoice number
  -d, --date <DATE>               Invoice date
  -c, --config <FILE>             Config file path. If left undefined, tries to find in sensible places, like $HOME, $XDG_CONFIG_HOME or $USERPROFILE
  -o, --output <FILE>             Output file [default: output.pdf]
  -i, --item <DESCRIPTION=PRICE>  Invoice lines
  -v, --verbose
  -h, --help                      Print help
  -V, --version                   Print version


    Example usage;
    pekmez-invoice --number 123 --date 25.10.2025 "Misdirecting witnesses=5000" --item "Taking forever to deduce the obvious=12999" --config ./config.yaml
```

## Configuration

It runs with sensible [defaults](./src/res/defaults.yaml) for English language. But you want to set the author and recipient of your invoice.

There is an [example](./example/config.yaml) config file bundled with the executables. You can modify it.

Put the config file somewhere, by default it will read from
`$XDG_CONFIG_HOME/pekmez-invoice/config.yaml`, `$XDG_CONFIG_HOME` depends on the
system, but usually `~/.config`.

Config file can be set with `--config config.yaml` option as well.

## Run

Current possible ways to run is below;

### Binary

Download the binaries, decompress and run;

```bash
pekmez-invoice \
    --config config.yaml \
    --date 15.09.2025 \
    --number 1234 \
    --item "Misdirecting witnesses=5000" \
    --item "Taking forever to deduce the obvious=12999"
```

### Nix

Run with [Nix](https://nixos.org/)

```bash
nix run github:Deliganli/pekmez-invoice -- \
    --date 15.09.2025 \
    --number 1234 \
    --item "Misdirecting witnesses=5000" \
    --item "Taking forever to deduce the obvious=12999"
```

### Typst

Run with [Typst](https://typst.app/)

Typst treats file paths relative to the given `typ` file. So `cd` into
where this code exists.

```bash
typst compile "./main.typ"
```

## Thanks

<a name="thanks"></a>
Inspired and straight out copied code from below projects

- [tiefletter](https://github.com/Tiefseetauchner/TiefLetter): nice and minimalistic invoice template
- [typst-invoice](https://github.com/erictapen/typst-invoice): minimalistic German invoice template
- [invoice-boilerplate](https://github.com/mrzool/invoice-boilerplate/): simplest yet best looking invoice template
