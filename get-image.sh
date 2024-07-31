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
  REPO="flex"
  PRODUCT="icm"
  TAG="16.0-latest"
}

# -- Displays script usage information
show_usage() {
  cat << EOF

Usage: $script_name [options] [product:=icm] [tag:=16.0-latest]

Options:
  -h, --help           show this help
  -d, --debug          show debug output
  --docker, --podman   specify the OCI client to use (default: docker)
  --registry <name>    name of the registry to replace Quadient's with
  --push               directive to push the image to the new registry

EOF
}

# -- Parses script arguments
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
      --registry)
        if [ $# -ge 1 ]; then
          REGISTRY="$1"
          shift
        else
          echo "Missing required parameter registry name"
          exit 1
        fi
        ;;
      --push)
        IS_SET_PUSH=Y
        ;;
      -*)
        echo "Invalid parameter was provided: $param"
        exit 1
        ;;
      icm | ips | interactive | scaler | scenario-engine | automation)
        PRODUCT=$param
        if [ $# -gt 0 ]; then
          TAG=$1
          shift
        fi
        ;;
      *)
        echo "Invalid parameter was provided: $param"
        exit 1
        ;;
    esac
  done
}

validate_params() {
  if [ -n "${IS_SET_PUSH:-}" ] && [ -z "${REGISTRY:-}" ]; then
    echo "Registry name must be specified if using --push option"
    exit 1
  fi
}

# -- Main script processing
init_script "$@"
parse_params "$@"
validate_params

# Login
if [ "${OCI_CLIENT}" == "podman" ]; then
  LOGIN_OPTS="--podman"
fi
# "$script_dir/acr-login.sh" ${LOGIN_OPTS:---docker} > /dev/null 2>&1
"$script_dir/acr-login.sh" ${LOGIN_OPTS:---docker}

# Pull image
readonly quadient_image="${ACR_NAME}.azurecr.io/${REPO}/${PRODUCT}:${TAG}"
echo -e "\nPulling image: ${quadient_image}"
${OCI_CLIENT} pull "${quadient_image}"

# Rename image (if necessary)
if [ -n "${REGISTRY:-}" ]; then
  readonly new_image="${quadient_image//${ACR_NAME}.azurecr.io/${REGISTRY}}"
  echo -e "\nTagging image as: ${new_image}"
  ${OCI_CLIENT} image tag "${quadient_image}" "${new_image}"
  echo -e "Removing tag: ${ACR_NAME}.azurecr.io"
  ${OCI_CLIENT} image rm "${quadient_image}"

  # Push image (if necessary)
  if [ -n "${IS_SET_PUSH:-}" ]; then
    echo -e "\nPushing image: ${new_image}"
    ${OCI_CLIENT} push "${new_image}"
  fi
fi
