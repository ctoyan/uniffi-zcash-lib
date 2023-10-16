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

		LIB_LATEST_VERSION=$(curl --silent "https://crates.io/api/v1/crates/$lib_name" | jq -r '.crate.max_stable_version')
		LIB_CURRENT_VERSION=$(cargo metadata --format-version=1 -q --manifest-path=./uniffi-zcash-lib/lib/Cargo.toml | jq -r --arg lib_name "$lib_name" '.packages[] | select(.name == $lib_name) | .version')

		echo -e "## ${lib_name} \n"
		echo -e "\`CURRENTLY USED VERSION\`    :arrow_right: ${LIB_CURRENT_VERSION} \n"
		echo -e "\`LATEST PUBLISHED VERSION\`  :arrow_right: ${LIB_LATEST_VERSION} \n"
		echo -e " \n"
		echo -e "\`\`\`diff \n"
		cat "$lib_name".diff
		echo -e " \n"
		echo -e "\`\`\` \n"
	done
}

print_build_result() {
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
