#!/usr/bin/env bash
#
# Copyright (c) 2022 Quadient Group AG
#
# This file is subject to the terms and conditions defined in the
# 'LICENSE' file found in the root of this source code package.
#
set -euo pipefail

# -- Script initialization and setup
init_script() {
  # Useful variables
  readonly orig_cwd="$PWD"
  readonly script_params="$*"
  readonly script_path="${BASH_SOURCE[0]}"
  script_dir="$(dirname "$script_path")"
  script_name="$(basename "$script_path")"
  readonly script_dir script_name

  # Script variables
  ACR_NAME="quadientdistribution"
}

# -- Displays script usage information
show_usage() {
  cat <<EOF
Usage: $script_name [options]

Options:
  -h, --help       show this help
  -d, --debug      show debug output

EOF
}

# -- Parses scrirpt arguments
parse_params() {
  local param
  while [[ $# -gt 0 ]]; do
    param="$1"
    shift
    case $param in
      -h | --help)
        show_usage
        exit 0
        ;;
      -d | --debug)
        set -x
        ;;
      *)
        echo "Invalid parameter was provided: $param"
        exit 1
        ;;
    esac
  done
}

# -- Sources environment variables for ACR credentials (ACR_USERNAME, ACR_PASSWORD)
get_creds() {
  creds_file="${script_dir}/acr-creds.env"
  if [ -s "${creds_file}" ]; then
    source "${creds_file}"
  else
    echo "Credentials file is empty or does not exist"
    exit 1
  fi
}

# -- Main script processing
init_script
parse_params "$@"
get_creds

echo -e "\nRepositories available at ${ACR_NAME}.azurecr.io:\n"

az acr repository list \
	-n ${ACR_NAME} \
	-u ${ACR_USERNAME} \
	-p ${ACR_PASSWORD} \
	-o table
