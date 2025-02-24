#!/bin/bash

# malus docker builder
# Author: rye
# ! Requires real tabs for heredoc !


function usage {
	cat <<-EOF

		$0: A tool to build the ryeeaston.com ci/cd infrastructure on Docker.

		usage: $0 config_file
		       config_file: a JSON configuration file. Please see sample JSON config for
		         guidance on what needs to be set.
		
		EOF
}

function set_conf {
	if CONFIG="$(! cat "$1" | jq)"; then
		echo "Config failed to be read!"
		exit 2
	fi
}

function chk_dep {
	if ! command -v "$1" > /dev/null 2>&1; then
		echo "$1 missing. Please install it prior to running this script"
		exit 3
	fi
}

function set_regtoken {
	echo "Acquiring registration token..."
	if ! REGTOKEN="$(curl -s -L -X POST \
				-H "Accept: application/vnd.github+json" \
				-H "Authorization: Bearer $GITHUB_TOKEN" \
				-H "X-GitHub-Api-Version: 2022-11-28" \
				"https://api.github.com/repos/$OWNER/$REPO/actions/runners/registration-token" |\
			jq |  grep 'token' | awk -F'"' '{print $4}' )" || \
		[ -z "$REGTOKEN" ]; then
		echo "Setting registration token failed. Do you have permission on the repo?"
		exit 4
	fi
	echo "Registration token acquired."
}

function set_nonzero {
	printf -v "$1" "$2"
	[ -n "${!1}" ]
}

function eval_from_config {
	if ! set_nonzero "$1" "$(echo "${!3}" | jq -r ".[\"$2\"] // empty")"; then
		echo "The value of $2 could not be set from the $3."
		echo "Is $2 missing from your configuration file? See the sample."
		exit 5
	fi
}

function init_global_settings {
	eval_from_config NICKNAME nickname CONFIG
	eval_from_config "IMGNAME" "image-name" CONFIG
	eval_from_config CI_SETTINGS ci-settings CONFIG
}

function init_ci_settings {
	eval_from_config GITHUB_TOKEN github-token CI_SETTINGS
	eval_from_config RUNNERVER runner-version CI_SETTINGS
	eval_from_config TARGET target CI_SETTINGS
	eval_from_config OWNER owner TARGET
	eval_from_config REPO repo TARGET
	unset TARGET
	unset CI_SETTINGS
	set_regtoken
}

function announce_build {
	cat <<-EOF
		=========================
		    BUILDING $1 IMAGE
		=========================
		EOF
}

# EXECUTION BEGINS HERE

if (( $# != 1 )); then
	usage
	exit 1
fi

set -e

chk_dep command
chk_dep curl
chk_dep docker
chk_dep jq

set_conf "$1"
init_global_settings

announce_build CI
init_ci_settings

docker build -t "$IMGNAME"-ci docker/ci --build-arg RUNNERVER="$RUNNERVER" --build-arg OWNER="$OWNER" --build-arg REPO="$REPO" --build-arg REGTOKEN="$REGTOKEN" --build-arg NICKNAME="$NICKNAME" 

# announce_build CD
# TO-DO

echo "OK"