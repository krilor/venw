#!/bin/bash

# TODO allow override
export VENW_ROOT=~/.venw

venw() {

  if [[ $# -lt 1 ]]; then
    >&2 echo "Missing arguments."
    bash $VENW_ROOT/scripts/venw.sh help
    return 1
  fi

  COMMAND=$1

  # deactivate
  if [[ $COMMAND == "deactivate" ]]; then
    if [[ $VIRTUAL_ENV != "" ]]; then
      deactivate
    fi
    return 0
  fi

  # pass along to the script if it is not an activate command
  if [[ $COMMAND != "activate" ]]; then
    bash $VENW_ROOT/scripts/venw.sh "$@"
    return 0
  fi

  # want to activate a venv
  if [[ $# -ne 2 ]]; then
    >&2 echo "Please specify the venv to use."
    bash $VENW_ROOT/scripts/venw.sh help
    return 1
  fi

  VENV=$2

  if [[ ! -e $VENW_ROOT/venvs/$VENV/bin/activate ]]; then
    >&2 echo "Venv '$VENV' does not exist"
  fi

  source $VENW_ROOT/venvs/$VENV/bin/activate

  return 0

}
