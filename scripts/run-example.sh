#!/bin/bash
set -e

## Usage
# ./scripts/run-examples <folder-name> <package-manager>
# Examples
# ./scripts/run-examples basic yarn

## Or run all tests without any arguments
# ./scripts/run-examples

# Setup prysk
python3 -m venv .cram_env

.cram_env/bin/python3 -m pip install --quiet --upgrade pip
echo "Installing prysk..."
.cram_env/bin/pip3 install --quiet prysk

export folder=$1
export pkgManager=$2

# If both arguments were provided, we'll try to run a specific test
if [ -n "$1" ] && [ -n "$2" ]; then
  TEST_FILE="examples_tests/$2-$1.t"
  if [ -f "$TEST_FILE" ]; then
    echo "Running $TEST_FILE"
    .cram_env/bin/prysk --shell="$(which bash)" "$TEST_FILE"
  else
    echo "Could not find $TEST_FILE"
    exit 1
  fi

  # exit if both args were provided and we haven't already exited
  exit
fi

echo "No arguments provided, running all tests"

if [[ $TURBO_TEST_EXAMPLE_PARALLEL = "true" ]]; then
  echo "Running example tests in parallel"
  .cram_env/bin/pip3 install --quiet pytest "prysk[pytest-plugin]" pytest-xdist
  .cram_env/bin/pytest -n auto --prysk-shell="$(which bash)" "$PWD/examples_tests/"
else
  echo "Running example tests serially"
  .cram_env/bin/prysk --shell="$(which bash)" "$PWD/examples_tests/"
fi
