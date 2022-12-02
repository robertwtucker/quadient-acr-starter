#!/usr/bin/env bash

set -euo pipefail

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
  REPO="flex"
  PRODUCT="icm"
  VERSION="15.0"
  LIMIT="10"
}

usage() {
  cat <<EOF
Usage: $script_name [options] [product:=icm] [version:=15.0]

Options:
  -h, --help           show this help
  -d, --debug          show debug output
  -l, --limit <num>    limit results to the latest num (defaults to 10)

EOF
}

parse_params() {
  local param
  while [[ $# -gt 0 ]]; do
    param="$1"
    shift
    case $param in
      -h | --help)
        usage
        exit 0
        ;;
      -d | --debug)
        set -x
        ;;
      -l | --limit)
        if [ $# -ge 1 ]; then
          LIMIT="$1"
          shift
        else
          echo "Missing required parameter limit value"
          exit 1
        fi
        ;;
      -*)
        echo "Invalid parameter was provided: $param"
        exit 1
        ;;
      icm | ips | interactive | scaler | scenario-engine)
        PRODUCT=$param
        if [ $# -gt 0 ]; then
          VERSION=$1
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

get_creds() {
  creds_file="${script_dir}/acr-creds.env"
  if [ -s "${creds_file}" ]; then
    source "${creds_file}"
  else
    echo "Credentials file is empty or does not exist"
    exit 1
  fi
}

init_script
parse_params "$@"
get_creds

echo -e "\nImage: ${ACR_NAME}.azurecr.io/${REPO}/${PRODUCT}:${VERSION}\n"

az acr repository show-tags \
	-n ${ACR_NAME} \
	-u ${ACR_USERNAME} \
	-p ${ACR_PASSWORD} \
	--repository ${REPO}/${PRODUCT} \
	--detail \
	--orderby time_desc \
	--query "[?contains(name,'${VERSION}')].{tags:name}" \
	--top ${LIMIT} \
	-o table
