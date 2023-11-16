#!/usr/bin/env bash

step_number=$1

ROOT_DIR=$(dirname "$(readlink -f "$0")")
RESET="\033[0m"
RED="\033[1;31m"
GREEN="\033[1;32m"

PROJECT_DIR="."

# Check if --path option is provided
while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      shift
      if [ -d "$1" ]; then
        PROJECT_DIR="$1"
      else
        echo_error "The specified directory '$1' does not exist."
        exit 1
      fi
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ -d "$ROOT_DIR/Swiftable" ]; then
  PROJECT_DIR="$ROOT_DIR/Swiftable"
fi

function step1() {
    # We check that "tuist" is successfully installed
    tuist_env_output=$(tuist version)

    # Check the exit code of the command
    if [ $? -eq 0 ]; then

    if [[ $tuist_env_output =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
        echo_success
    else
        echo_error "'tuist env' did not succeed. Have you installed Tuist?"
        exit 1
    fi
    else
    echo_error "'tuist version' command failed."
    exit 1
    fi
}

function step2() {
    if [ ! -f "$PROJECT_DIR/Project.swift" ]; then
    echo_error "$PROJECT_DIR/Project.swift file does not exist."
    exit 1
    fi

    # Check if Tuist directory exists
    if [ ! -d "$PROJECT_DIR/Tuist" ]; then
    echo_error "$PROJECT_DIR/Tuist directory does not exist."
    exit 1
    fi

    # Check if Tuist/Config.swift file exists
    if [ ! -f "$PROJECT_DIR/Tuist/Config.swift" ]; then
    echo_error "$PROJECT_DIR/Tuist/Config.swift file does not exist."
    exit 1
    fi

    # Check if the Tuist/Config.swift file contains the desired line
    if ! grep -q "let config = Config()" "$PROJECT_DIR/Tuist/Config.swift"; then
    echo_error "The $PROJECT_DIR/Tuist/Config.swift file does not contain the required line."
    exit 1
    fi

    echo_success
}

function step3() {
  tuist generate --no-open --path $PROJECT_DIR

  # Check the exit code of the 'tuist generate' command
  if [ $? -ne 0 ]; then
    echo_error "'tuist generate' command failed."
    exit 1
  fi

  echo_success
}

function step4() {
  expected_lines=("*.xcodeproj" "*.xcworkspace" "Derived/" ".DS_Store")

  gitignore_file=$PROJECT_DIR/.gitignore

  # Check each expected line in the file
  for line in "${expected_lines[@]}"; do
    if ! grep -q "$line" "$gitignore_file"; then
      echo_error "The line '$line' is missing in '$gitignore_file'."
      exit 1
    fi
  done

  echo_success
}

function step5() {
  tuist build --generate --path $PROJECT_DIR

  # Check the exit code of the 'tuist generate' command
  if [ $? -ne 0 ]; then
    echo_error "'tuist build' command failed."
    exit 1
  fi

  echo_success
}

function step6() {
  tuist build --generate --path $PROJECT_DIR

  # Check the exit code of the 'tuist generate' command
  if [ $? -ne 0 ]; then
    echo_error "'tuist build' command failed."
    exit 1
  fi

  echo_success
}

function echo_success() {
  local message="$1"
  echo -e "${GREEN}"All checks passed successfully."${RESET}"
}

function echo_error() {
  local message="$1"
  echo -e "${RED}Error: ${message}${RESET}"
}

# Use a case statement to determine which function to call
case $step_number in
  1)
    step1
    ;;
  2)
    step2
    ;;
  3)
    step3
    ;;
  4)
    step4
    ;;
  5)
    step5
    ;;
  6)
    step6
    ;;
  *)
    echo "Invalid topic number. Please provide a valid step number (1, 2, or 3)."
    exit 1
    ;;
esac