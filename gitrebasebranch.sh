#!/bin/bash
#
# What it does:
#    $ git reset --soft HEAD~3
#    $ git commit --edit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"
# I don't want to count ~3 manually.
#
# Assumptions:
#   Branch is created from master
#
# usage: 
#      
#
# Identify branch on which we are.
BRANCH=$(git symbolic-ref --short HEAD)
if [ $? -ne 0 ]; then
  echo "We are not on any branch. (detached?)"
  exit 1;
fi
if [ "$BRANCH" == "master" ]; then
  echo "We are on master."
  exit 2;
fi
#
# Check if something is not committed?
#
git diff-index --quiet HEAD --
#
if [ $? -ne 0 ]; then
  echo "There are uncomitted changed in working tree."
  exit 1;
fi
#
#  Filter to get only the digits and not the spaces emited by wc -l | grep -oE '\d+'
NUMBER_OF_COMMITS=$(git rev-list  --first-parent ${BRANCH}...master | wc -l | grep -oE '\d+')
#
#
git reset --soft HEAD~${NUMBER_OF_COMMITS}
git commit --edit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"
