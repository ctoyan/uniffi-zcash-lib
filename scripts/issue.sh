#!/bin/bash

# be stricter
set -eou pipefail

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
	local issue_labels
	issue_labels=$(echo "$outdated_libs_json" | jq -r 'select(.crate_name | startswith("uniffi-") or .=="zcash").dependencies[] | select(.project != .latest) | (.name+"-"+.project+"-"+.latest)' | sort -u | tr '\n' ';')

	echo "$issue_labels"
}

# Search for an issue from it's labels
#
# Takes the following function args:
# $1 - issue response from "gh issue" command in JSON format
#
# Returns:
# - The issue URL
issue_url_from_json() {
	local issue_json
	issue_json=$1

	if [[ -z "$issue_json" ]]; then
		echo "required parameter for issue_url_from_json() is empty" 1>&2
		exit 1
	fi

	echo "$issue_json" | jq -r '.[] | .url'
}

# Search for an issue from it's labels
#
# Takes the following function args:
# $1 - issue labels in format 'lib_name-current_ver-latest_ver'
#
# Returns:
# - The response of the "gh issue" command in JSON format
get_issue_by_labels() {
	local issue_labels
	issue_labels=$1

	if [[ -z "$issue_labels" ]]; then
		echo "required parameter for get_issue_by_labels() is empty" 1>&2
		exit 1
	fi

	IFS=';' read -ra arr <<<"$issue_labels"
	cmd_args=("gh" "issue" "list" "--repo" "$GITHUB_REPOSITORY" "--json" "body,url")
	for label in "${arr[@]}"; do
		if [[ -z "$label" ]]; then
			continue
		fi
		cmd_args+=("--label" "$label")
	done

	local issues_json
	issues_json=$("${cmd_args[@]}")

	echo "$issues_json"
}

# TODO: Remove main
# main() {
# 	libs=$(generate_issue_labels "$@")
# 	echo "$libs"
# }
#
# main "$@"