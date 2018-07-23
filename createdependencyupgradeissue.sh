#!/bin/bash
#
# createissue.sh "Summary line"
# 
# usage: 
#  Create an JIRA issue based on the
#  current maven project.
#  This will extract the project.issueManagement.url
#  from the pom file.
#
#
# Identify branch on which we are.
echo -n "Checking if we are on a branch..."
BRANCH=$(git symbolic-ref --short HEAD)
if [ $? -ne 0 ]; then
  echo ""
  echo "We are not on any branch. (detached?)"
  exit 1;
fi
echo "done."
# If we are not on master stop it,
# cause creating of a branch should be done
# from master.
echo -n "Check that we are on master..."
if [ "$BRANCH" != "master" ]; then
  echo ""
  echo "We are not master...We won't create a branch from ${BRANCH}. Please change to master."
  exit 2;
fi
echo "done."
#
#
# Get the issueManagement.url from pom file.
echo -n "Extracting issue url from pom.xml file..."
ISSUE_URL=$(mvn org.apache.maven.plugins:maven-help-plugin:3.1.0:evaluate -Dexpression=project.issueManagement.url -q -DforceStdout)
if [ $? -ne 0 ]; then
  echo ""
  echo "Can not extract issueManagement from pom file."
  echo "Error Code: $?"
  exit 3;
fi
echo "done."
#
# Get the version of the pom file without trailing SNAPSHOT
# which will be used for affectsVersion / fixedVersion
#
echo -n "Extracting version from pom.xml file..."
PLAIN_VERSION=$(mvn build-helper:parse-version -Dx=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion} org.apache.maven.plugins:maven-help-plugin:3.1.0:evaluate -Dexpression=x -q -DforceStdout)
if [ $? -ne 0 ]; then
  echo ""
  echo "Can not extract version from pom file."
  echo "Error Code: $?"
  exit 3;
fi
echo "done."
#
# Extract project name from it.
#   example: https://issues.apache.org/jira/browse/MSHARED
#   will result in: "MSHARED"
# 
PROJECT=$(basename $ISSUE_URL)
#
# Create an jira issue setting fixedVersions, affectedVersions.
echo -n "Creating JIRA issue..."
RESULT=$(jira-cli createdependencyupgrade --project $PROJECT --fix="${PLAIN_VERSION}" --affected="${PLAIN_VERSION}" "$1")
if [ $? -ne 0 ]; then
  echo ""
  echo "Failure while creating the JIRA issue."
  echo "$RESULT"
  exit 1;
fi
echo "done."
#
# printout something for the user to see something has happened.
echo "${RESULT}"
#
# Example looks like this: "OK MEJB-130 https://issues.apache.org/jira/browse/MEJB-130"
#
# Check for OK
EXPECTED=$(echo "${RESULT}" | cut -d " " -f1)
#
if [ "$EXPECTED" != "OK" ]; then
  echo "Something has gone wrong during issue creation."
  echo "${RESULT}"
  exit 5;
fi
#
# Extract created issue from result.
CREATED_ISSUE=$(echo "${RESULT}" | cut -d " " -f2)
#
# Create a branch based on the issue
#
git checkout -b ${CREATED_ISSUE}
# intentionally do not commit, cause this can
# be done via commitonissue.sh script.

