#!/bin/bash

# ***************************************************************************************************************
# DO NOT MODIFY THIS FILE.  This file may be replaced at anytime without notice in your source code repository.
# This file is part of the standard development framework at Alight. If you have suggested changes, please
# see this page for how to contribute to the Alight Development "Paved Paths":
# https://alightarchitecture.atlassian.net/wiki/x/AYC6GQ
#****************************************************************************************************************


if [ $# -eq 0 ]; then
    echo "Usage: $0 branch_name workflow_name commit_sha"
    exit 1
fi

echo 'Sleeping 20 seconds before checking on the "push" workflow status, giving time for the workflow to start ....'
sleep 20

run_id=$(gh run list --branch "$1" --workflow "$2" --limit 1 --json headSha,databaseId --jq ".[] | select(.headSha | startswith(\""$3"\")) | .databaseId")
echo "Starting to watch GitHub Workflow Run ID: $run_id"
gh run watch $run_id

echo " "
echo "Please view vulnerability details from the Wiz scan here..."
gh run view $run_id --json url --jq '.url'
echo " "
