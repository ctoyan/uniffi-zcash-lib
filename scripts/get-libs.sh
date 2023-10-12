#!/bin/bash

# be stricter
set -eo pipefail

# Get librustzcash libraries used in uniffi-zcash-lib
#
# Takes the following function args:
# $1 - librustzcash Cargo.toml path
# $2 - uniffi-zcash-lib Cargo.toml path
#
# Returns:
# - The labels that are used when searching for or creating a Github issue, in format 'lib_name-current_ver-latest_ver'

get_libs() {
	local librustzcash_cargo_path=$1
	local uniffi_cargo_path=$2
	if [[ -z "$librustzcash_cargo_path" || -z "$uniffi_cargo_path" ]]; then
		echo "required parameter for get_libs() is empty" 1>&2
		exit 1
	fi

	local output
	output=$(
		cargo metadata --format-version=1 --no-deps --quiet --manifest-path="$librustzcash_cargo_path" |
			jq -r '.packages[] | .name' |
			xargs -I {} sh -c "cargo metadata --quiet --format-version=1 --no-deps --manifest-path=$uniffi_cargo_path | jq -r '.packages[] | .dependencies[] | .name' | grep '{}' | sort -u | tr '\n' ';'"
	)

	echo "$output"
}

# TODO: Remove main
# main() {
# 	libs=$(get_libs "$@")
# 	echo "$libs"
# }
#
# main "$@"
