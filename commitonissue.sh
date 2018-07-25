#!/bin/bash
#
# usage: 
#  Commit current state of code
#  based on current branch name.
#  It is assumed that the branch name represents
#  an JIRA issue.
#  From the JIRA issue the information
#  for the commit will be gathered.
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
# TODO: Tweak jira-cli via templates to make this easier.
SUMMARY=$(jira-cli view $BRANCH | grep "^summary: " | cut -d " " -f2-)
if [ $? -ne 0 ]; then
  echo "Failure while getting information from JIRA"
  exit 1;
fi
# commit the curent state.
git commit -a -m"[$BRANCH] - $SUMMARY"
