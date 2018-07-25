#!/bin/bash
#
# usage: 
#
# Identify branch on which we are.
BRANCH=$(git symbolic-ref --short HEAD)
if [ $? -ne 0 ]; then
  echo "We are not on any branch. (detached?)"
  exit 1;
fi
# If we are already on master it does not make sense 
# to continue.
if [ "$BRANCH" == "master" ]; then
  echo "We are on master."
  exit 2;
fi
#
RESULT=$(jira-cli start $BRANCH)
if [ $? -ne 0 ]; then
  echo "Failure while taking the issue"
  echo "${RESULT}"
  exit 1;
fi
