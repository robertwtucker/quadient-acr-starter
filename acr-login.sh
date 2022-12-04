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
  readonly script_path="${BASH_SOURCE[0]}"
  script_dir="$(dirname "$script_path")"
  script_name="$(basename "$script_path")"
  readonly script_dir script_name

  # Script variables
  ACR_NAME="quadientdistribution"
  OCI_CLIENT="docker"
}

# -- Displays script usage information
show_usage() {
  cat <<EOF

Usage: $script_name [options]

Options:
  -h, --help           show this help
  -d, --debug          show debug output
  --docker, --podman   specify the OCI client to use (default: docker)

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
      --docker)
      OCI_CLIENT="docker"
      ;;
      --podman)
      OCI_CLIENT="podman"
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
    # shellcheck source=acr-creds.env
    source "${creds_file}"
  else
    echo "Credentials file is empty or does not exist"
    exit 1
  fi
}

# -- Main script processing
init_script "$@"
parse_params "$@"
get_creds

echo -e "\nLogging into ${ACR_NAME}.azurecr.io with ${OCI_CLIENT}...\n"

echo "${ACR_PASSWORD}" | ${OCI_CLIENT} login --username "${ACR_USERNAME}" --password-stdin "${ACR_NAME}.azurecr.io"
