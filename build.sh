#!/bin/bash

# malus docker builder
# Author: rye
# ! Requires real tabs for heredoc !


function usage {
	cat <<-EOF

		$0: A tool to build the ryeeaston.com ci/cd infrastructure on Docker.

		usage: $0  org_name repo_name [nickname]
		       owner_name: the owner of a repository
		       repo_name: the name of a repository
		       nickname: (optional) the nickname for the machine this runs on, defaults to malus 
		
		environment:
		       GITHUB_TOKEN: required, a github classic token
		       RUNNERVER: optional, a custom github/runner version. defaults to 2.322.0
			   IMGNAME: optional, a custom name for the ci/cd images. defaults to ryeeastoncom
		
		EOF
}

function chk_ghp {
	if [ -z "$GITHUB_TOKEN" ]; then
		echo "GITHUB_TOKEN not set. Please authorize a classic personal access token and export it."
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
}

function announce_build {
	cat <<-EOF
		=========================
		    BUILDING $1 IMAGE
		=========================
		EOF
}

# EXECUTION BEGINS HERE

if (( $# < 2 )) || (( $# > 3 )); then
	usage
	exit 1
fi

set -e

chk_ghp
chk_dep command
chk_dep curl
chk_dep docker
chk_dep jq

OWNER="$1"
REPO="$2"
NICKNAME="${3:-malus}"
RUNNERVER="${RUNNERVER:-2.322.0}"
IMGNAME="${IMGNAME:-ryeeastoncom}"

set_regtoken

announce_build CI
docker build -t "$IMGNAME"-ci docker/ci --build-arg RUNNERVER="$RUNNERVER" --build-arg OWNER="$OWNER" --build-arg REPO="$REPO" --build-arg REGTOKEN="$REGTOKEN" --build-arg NICKNAME="$NICKNAME" 

# announce_build CD
# TO-DO