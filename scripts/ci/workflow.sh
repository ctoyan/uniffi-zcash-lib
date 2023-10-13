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
print_workflow_header() {
	local libs_up_to_date=$1
	local issue_already_exists=$2
	local existing_issue_url=$3
	local github_repo=$4
	local github_run_id=$5

	if [[ "$libs_up_to_date" == "true" ]]; then
		echo "# :white_check_mark: All libraries from librustzcash are up to date :white_check_mark: "
		exit 0
	fi

	if [[ "$issue_already_exists" == "true" ]]; then
		echo "# :page_with_curl: An issue already exists for those library versions :page_with_curl: "
		echo "**[VIEW EXISTING ISSUE]($existing_issue_url)**"
		exit 0
	fi

	echo "# :warning: New versions of librustzcash libraries are present :warning: "
	local workflow_url
	workflow_url=$(gh run --repo "$github_repo" view "$github_run_id" --json jobs --jq '.jobs[] | select(.name == "${{ github.job }}") | .url, (.steps[] | select(.name == "Show public API diffs") | "#step:\(.number):1")' | tr -d "\n")
	echo "You can view a better colored result of the diff in the **[CI logs]($workflow_url)**."
}
