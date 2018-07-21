#!/bin/bash
#
# usage: 
#  Call this script after you have switched onto the branch
#  you would like to merge back into master.
#  and close the appropriate ticket in JIRA as well.
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
# If we are on another branch goto master
git co master
# Only allow fast-forward merges..
git merge --ff-only $BRANCH
if [ $? -ne 0 ]; then
  echo "git merge can't be fast forwarded"
  exit 1;
fi
git push origin master
if [ $? -ne 0 ]; then
  echo "git push to master has failed. rejected?"
  exit 1;
fi
# delete remote branch
git push origin --delete $BRANCH
if [ $? -ne 0 ]; then
  echo "failed to delete $BRANCH ?"
  exit 1;
fi
# delete local branch
git branch -d $BRANCH
