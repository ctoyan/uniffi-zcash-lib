#!/bin/bash

# be stricter
set -eou pipefail

# Upgrade a list of outdated librustzcash crates. Build the project. Return an env var indicating if the build was successful.
#
# Takes the following function args:
# $1 - outdated uniffi librustzcash dependencies where the version is not latest, in format - "crate_name;...".
#
# Returns:
# - an env var indicating if the build failed or succeeded. Contains a string "true" or "false"
upgrade_and_build() {
	local outdated_libs=$1
	if [[ -z "$outdated_libs" ]]; then
		echo "required parameter for upgrade_and_build() is empty" 1>&2
		exit 1
	fi

	IFS=';' read -ra arr <<<"$outdated_libs"
	cmd_args=("cargo" "upgrade")
	for lib_name in "${arr[@]}"; do
		if [[ -z "$lib_name" ]]; then
			continue
		fi
		cmd_args+=("-p" "$lib_name")
	done
	cmd_args+=("-i" "--manifest-path" "./uniffi-zcash-lib/lib/Cargo.toml")
	"${cmd_args[@]}"

	# avoid colored output, because the way ANSI color codes are written in the file, can't be renderd in markdown
	cargo build -p zcash --color=never --manifest-path=./uniffi-zcash-lib/lib/Cargo.toml &>build_output || command_failed=1

	local does_build_fail
	if [ "${command_failed:-0}" -eq 1 ]; then
		does_build_fail="true"
	else
		does_build_fail="true"
	fi

	# revert back to original dependency versions
	git -C ./uniffi-zcash-lib checkout .
	cargo update -p zcash --manifest-path=./uniffi-zcash-lib/lib/Cargo.toml

	echo "$does_build_fail"
}
