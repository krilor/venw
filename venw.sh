#!/bin/bash
set -eu
# venw
usage() {
  echo """Usage: venw command [options]

================================================================
activate <venv>      | Source the virtualenvs activate script
deactivate           | Deactivate the current virtual env
list                 | List venvs
init                 | Init venw by creating some directories
install <version>    | Get and compile python version from source
new <venv> [version] | Create a new virtualenv
=================================================================
"""
}

##
## Utils
##

# print to std err
# err <message...>
err() {
  >&2 echo "$@"
}

# print to std out
# out <message...>
out() {
  echo "$@"
}

# show commands and run them
# run <command...>
run() {
  out "  " "$@"
  eval "$@"
}

# reports if venv exists or not
# venv_exists <venv>
venv_exists() {
  VENV=$1
  out "Checking if venv exists."
  run "test -e $VENW_ROOT/venvs/$VENV/bin/python"
  return $?
}

# returns the path for the version binary
# version_binary_path <version>
version_binary_path() {
  echo -n "$VENW_ROOT/versions/$VERSION/bin/python${VERSION%.*}"
  return 0
}

# reports if python version exists
# version_exists <version>
version_exists() {
  VERSION=$1
  out "Checking if version exists."
  run "test -e $(version_binary_path $VERSION)"
  return $?
}

##
## Commands
##

# install python from source
# install <version>
install() {

  if [[ $# -lt 1 ]]; then
    err "Missing version. Please specify a version"
    exit 1
  fi

  VERSION=$1

  # TODO version format

  VERSION_ROOT=$VENW_ROOT/versions/$VERSION
  VERSION_ARCHIVE=Python-$VERSION.tar.xz
  VERSION_ARCHIVE_PATH=$VENW_ROOT/versions/$VERSION/src/$VERSION_ARCHIVE

  out "Installing version $VERSION in $VERSION_ROOT"
  out "We first want to get the archive $VERSION_ARCHIVE from python.org"

  if [ -e $VERSION_ARCHIVE_PATH ]; then
    out "The archive allready exists in $VERSION_ARCHIVE_PATH"
  else
    out "We first create the version directory, then download the archive"
    run "mkdir --parents $VERSION_ROOT/src"
    run "wget --quiet https://www.python.org/ftp/python/$VERSION/$VERSION_ARCHIVE -O $VERSION_ARCHIVE_PATH"
  fi

  out "Changing directory to the version src directory"
  run "cd $VERSION_ROOT/src"

  if [ -e $VERSION_ROOT/src/configure ]; then
    out "Archive has been extracted since $VERSION_ROOT/src/configure exists"
  else
    out "Extracting archive"
    run "tar xf $VERSION_ARCHIVE --strip-components=1"
  fi

  if [ -e $VERSION_ROOT/src/Makefile ]; then
    out "Build has been configures since Makefile exists"
  else
    out "Configuring build"
    run "./configure --prefix $VERSION_ROOT --quiet"
  fi

  if [ -e $VERSION_ROOT/src/python ]; then
    out "Version has been build since python binary exists".
  else
    out "Building"
    run "make"
  fi

  if [ -e $VERSION_ROOT/bin ]; then
    out "Version has been installed since bin directory exists"
  else
    out "Installing to $VERSION_ROOT/bin"
    run "make altinstall"
  fi

  out "Restoring working directory"
  run "cd -"

  out "Version $VERSION is installed in $VERSION_ROOT"

}

# list virtual environments
list() {
  out "Checking for versions is just looking for directories in $VENW_ROOT/venvs"
  run "ls -1 $VENW_ROOT/venvs"
}

# init venw
init() {
  out "Creating a few directories in $VENW_ROOT"
  run "mkdir -p $VENW_ROOT/venvs"
  run "mkdir -p $VENW_ROOT/versions"
}

#
# new virtual environment
# new <venv> [version]
# if version is not specified, system python (in path) will be used
new() {

  if [[ $# -lt 1 ]]; then
    err "Missing venv name."
    usage
    exit 1
  fi

  VENV=$1

  if venv_exists $VENV; then
    err "Venv '$VENV' allready exists"
    return 1
  fi

  PYTHON="python3"
  if [[ $# -lt 2 ]]; then
    out "Version was not supplied. Using python3 from your path."
  else

    VERSION=$2
    if ! version_exists $VERSION; then
      out "Version $VERSION is not installed, so installing it now."
      install $VERSION
    fi

    PYTHON=$( version_binary_path $VERSION)
    out "Using python binary in $PYTHON"

  fi

  run "$PYTHON -m venv $VENW_ROOT/venvs/$VENV"

}

#
# Autocomplete
#
autocomplete() {
  # Autocomplete script is invoked (by bash autocomplete) with
  # venw.sh command prefix previous
  # Example: venw.sh venw ac venw

  COMP_COMMAND=$1
  COMP_PREFIX=$2
  COMP_PREVIOUS=$3

  # Also, example from env:
  # COMP_KEY=9
  # COMP_LINE=venw
  # COMP_POINT=5
  # COMP_TYPE=63
  # See https://linux.die.net/man/1/bash

  case $COMP_PREVIOUS in
    venw)
      compgen -W "activate deactivate install list new" $COMP_PREFIX
      ;;
    activate)
      compgen -W "$(ls $VENW_ROOT/venvs)" $COMP_PREFIX
      ;;
  esac
}

if [[ ! -z ${COMP_TYPE+x} ]]; then
  autocomplete "$@"
  exit 0
fi

#
## Parse options
#

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  KEY="$1"

  case $KEY in
    -h|--help)
      usage
      exit
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional arguments

#
## Parse command and arguments
#

if [[ $# -lt 1 ]]; then
  >&2 echo "Missing command."
  usage
fi

COMMAND=$1

case $COMMAND in
  install)
    install "${@:2}"
    ;;
  list)
    list
    ;;
  init)
    init
    ;;
  new)
    new "${@:2}"
    ;;
  *)
    >&2 echo "Unknown command: $COMMAND"
    usage
    ;;
esac
