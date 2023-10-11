#!/bin/bash

# be stricter
set -eo pipefail

# Get librustzcash libraries used in uniffi-zcash-lib
get_libs() {
	local output
	output=$(
		cargo metadata --format-version=1 --no-deps --manifest-path=./librustzcash/Cargo.toml |
			jq -r '.packages[] | .name' |
			xargs -I {} sh -c "cargo metadata --format-version=1 --no-deps --manifest-path=./uniffi-zcash-lib/lib/Cargo.toml | jq -r '.packages[] | .dependencies[] | .name' | grep '{}' | sort -u"
	)

	echo "$output"
}
