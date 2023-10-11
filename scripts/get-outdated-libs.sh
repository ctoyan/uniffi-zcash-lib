#!/bin/bash

# be stricter
set -eo pipefail

# Get librustzcash libraries used in uniffi-zcash-lib
get_outdated_libs() {
	local used_libs=$1
	IFS=';' read -ra arr <<<"$used_libs"
	cmd_args=("cargo" "outdated" "--format" "json")
	for lib_name in "${arr[@]}"; do
		if [[ -z "$lib_name" ]]; then
			continue
		fi
		cmd_args+=("-p" "$lib_name")
	done

	OUTDATED_LIBS_JSON=$("${cmd_args[@]}")

	# Export ISSUE_LABELS in format - "crate_name-current_version-latest_version;..."
	ISSUE_LABELS=$(echo $OUTDATED_LIBS_JSON | jq -r 'select(.crate_name | startswith("uniffi-") or .=="zcash").dependencies[] | select(.project != .latest) | (.name+"-"+.project+"-"+.latest)' | sort -u)
	ISSUE_LABELS=$(echo $ISSUE_LABELS | tr ' ' ';')
	echo "ISSUE_LABELS=$ISSUE_LABELS" >>$GITHUB_ENV

	# Export OUTDATED_LIBS, where a uniffi librustzcash dependency version is not latest, in format - "crate_name;..."
	OUTDATED_LIBS=$(echo $OUTDATED_LIBS_JSON | jq -r 'select(.crate_name | startswith("uniffi-") or .=="zcash").dependencies[] | select(.project != .latest) | .name' | sort -u)
	OUTDATED_LIBS=$(echo $OUTDATED_LIBS | tr ' ' ';')
}

main() {
	libs=$(get_libs)
	echo "$libs"
}

main "$@"
