#!/bin/bash

# be stricter
set -eo pipefail

# Use jq to get the outdated libs from the "cargo outdated" JSON string and generate Github issue labels
#
# Takes the following function args:
# $1 - "cargo outdated" JSON string
#
# Returns:
# - The labels that are used when searching for or creating a Github issue, in format 'lib_name-current_ver-latest_ver'
generate_issue_labels() {
	local outdated_libs_json=$1
	if [[ -z "$outdated_libs_json" ]]; then
		echo "required parameter for generate_issue_labels() is empty" 1>&2
		exit 1
	fi

	# Export ISSUE_LABELS in format - "crate_name-current_version-latest_version;..."
	local output
	output=$(echo "$outdated_libs_json" | jq -r 'select(.crate_name | startswith("uniffi-") or .=="zcash").dependencies[] | select(.project != .latest) | (.name+"-"+.project+"-"+.latest)' | sort -u | tr '\n' ';')

	echo "$output"
}

main() {
	libs=$(generate_issue_labels "$@")
	echo "$libs"
}

main "$@"
