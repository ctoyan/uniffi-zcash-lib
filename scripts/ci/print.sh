#!/bin/bash

# be stricter
set -eou pipefail

# Get librustzcash libraries used in uniffi-zcash-lib
#
# Takes the following function args:
# $1 - librustzcash Cargo.toml path
# $2 - uniffi-zcash-lib Cargo.toml path
#
# Returns:
# - The labels that are used when searching for or creating a Github issue, in format 'lib_name-current_ver-latest_ver'
print_workflow_diff() {
	local outdated_libs=$1
	local diff_result_workflow_url=$2

	echo -e "# :warning: New versions of librustzcash libraries are present :warning: \n"
	echo -e "You can view a better colored result of the diff in the **[CI logs]($diff_result_workflow_url)**.\n"

	IFS=';' read -ra arr <<<"$outdated_libs"
	for lib_name in "${arr[@]}"; do
		if [[ -z "$lib_name" ]]; then
			continue
		fi

		local lib_latest_version
		lib_latest_version=$(curl --silent "https://crates.io/api/v1/crates/$lib_name" | jq -r '.crate.max_stable_version')

		local lib_current_version
		lib_current_version=$(cargo metadata --format-version=1 -q --manifest-path=./uniffi-zcash-lib/lib/Cargo.toml | jq -r --arg lib_name "$lib_name" '.packages[] | select(.name == $lib_name) | .version')

		echo "## ${lib_name}"
		echo "\`CURRENTLY USED VERSION\`    :arrow_right: ${lib_current_version}"
		echo "\`LATEST PUBLISHED VERSION\`  :arrow_right: ${lib_latest_version}"
		echo ""
		echo "\`\`\`diff"
		cat "$lib_name".diff
		echo ""
		echo "\`\`\`"
	done
}

print_workflow_build_result() {
	local build_failing=$1
	local build_result_workflow_url=$2

	if [[ "$build_failing" == "true" ]]; then
		echo "# :warning: Build fails after bumping to the newer versions with the following output: :warning: "
		echo "You can also view the build result in the **[CI logs]($build_result_workflow_url)**."
		echo "\`\`\`"
		output=$(cat build_output)
		echo "$output"
		echo "\`\`\`"
	fi

	if [[ "$build_failing" == "false" ]]; then
		echo "# :white_check_mark: Build doesn't fail when bumping to the newer versions :white_check_mark: "
	fi

}

print_issue_diff() {
	local outdated_libs=$1
	local diff_result_workflow_url=$2

	echo "# :warning: New versions of librustzcash libraries are present :warning: "
	echo "You can view the also public API diff between versions in the **[CI logs]($diff_result_workflow_url)**."

	IFS=';' read -ra arr <<<"$outdated_libs"
	for lib_name in "${arr[@]}"; do
		if [[ -z "$lib_name" ]]; then
			continue
		fi

		local lib_latest_version
		lib_latest_version=$(curl --silent "https://crates.io/api/v1/crates/$lib_name" | jq -r '.crate.max_stable_version')

		local lib_current_version
		lib_current_version=$(cargo metadata --format-version=1 -q --manifest-path=./uniffi-zcash-lib/lib/Cargo.toml | jq -r --arg lib_name "$lib_name" '.packages[] | select(.name == $lib_name) | .version')

		echo "## ${lib_name}"
		echo "\`CURRENTLY USED VERSION\`    :arrow_right: ${lib_current_version}"
		echo "\`LATEST PUBLISHED VERSION\`  :arrow_right: ${lib_latest_version}"
		echo ""
		echo "\`\`\`diff"
		cat "$lib_name".diff
	done
}

print_issue_build_result() {
	local build_failing=$1
	local build_result_workflow_url=$2

	if [[ "$build_failing" == "false" ]]; then
		echo "# :white_check_mark: Build doesn't fail after updating to the newer versions :white_check_mark: "
	fi

	if [[ "$build_failing" == "true" ]]; then
		echo "# :warning: Build fails after bumping to the newer versions with the following output: :warning: "
		echo "You can view the also public API diff between versions in the **[CI logs]($build_result_workflow_url)**."
		echo "\`\`\`"
		output=$(cat build_output | grep -v "Compiling")
		echo "$output"
	fi

}

cut_msg() {
	# if the body has reached github issue body limit, then close the ``` and show message that limit is reached
	if [[ $(cat issue_body | wc -m) -gt 65300 ]]; then
		head -c 65300 <issue_body >temp_issue_body && mv temp_issue_body issue_body
		echo "..." >>issue_body
		echo "" >>issue_body
		echo "\`\`\`" >>issue_body
		echo "## :construction: The Github issue body size limit was reached. Please visit the summary link at the top of the issue for the full message :construction: " >>issue_body
	else
		echo "\`\`\`" >>issue_body
	fi

}
