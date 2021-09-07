# Virtual Environment Wrapper for python

`venw` is a handy wrapper for pythons venv that allows you to specify the version of python to use.

## Why yet another python version manager

Learn. Simplicity. Usage of venv.

## Requirements

*
* Requires the use of python > 3.3 (for now).
* Bash (I'm running Ubuntu)

## Usage

```
Usage: venw command [options]
=====
install <version>
new <venv> [version]
activate <venv>
=====
```

## Install

`venw` is installed by copying a couple of scripts to the __VENW_ROOT__ (currently harcoded to ~/.venv), and sourcing one of them in ~/.bashrc

```bash
mkdir -p ~/.venw/scripts
wget https://raw.githubusercontent.com/krilor/venw/register.sh -O ~/.venw/scripts/register.sh
wget https://raw.githubusercontent.com/krilor/venw/venw.sh -O ~/.venw/scripts/venw.sh
echo "source ~/.venw/scripts/register.sh >> ~/.bashrc"
source ~/.bashrc
```

## Implementation details

### Getting the desired version of python

Like [pyenv](https://github.com/pyenv/pyenv), Python versions are installed by compiling source.

## License

MIT
