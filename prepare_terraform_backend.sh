#!/bin/bash

set -e

function throw_exception {
  echo "☠️  ${1:-"Uncaught Error: The line above may give some clues"}" 1>&2
  exit 1
}

trap throw_exception ERR

# Configure backend and exit early if on CI environment
#
if [[ "$CI" != "" || "$1" == "cicd" ]];then
  echo "terraform {
  cloud {
    organization = \"guidion\"
  }
}" > backend.tf


  echo "🤘 Created backend (CI) configuration as 'backend.tf'"
  exit 0
fi

## Local configuration section (CI sould never be able to get to this point)

# First some sanity checks :)
#

# Need to know which OS we're on
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     OS_ENV=Linux;;
    Darwin*)    OS_ENV=Mac;;
    CYGWIN*)    OS_ENV=Cygwin;;
    MINGW*)     OS_ENV=MinGw;;
    MSYS_NT*)   OS_ENV=Git;;
    *)          OS_ENV="UNKNOWN:${unameOut}"
esac

# Account for Windows
echo "ℹ️  Running in $OS_ENV. Will attempt to do the right thing in this environment"
if [[ "$OS_ENV" == "Cygwin" ]] || [[ "$OS_ENV" == "MINGW" ]]; then
  HOME_DIRECTORY=$HOMEPATH
else
  HOME_DIRECTORY=$HOME
fi

# Test for AWS credentials
# Keep a pre-set AWS_PROFILE if present; otherwise derive a default from credentials.
if [[ -z "${AWS_PROFILE:-}" ]] && [[ -s "$HOME_DIRECTORY/.aws/credentials" ]]; then
  AWS_PROFILE=$(sed -nE 's/^\[([^]]+)\]$/\1/p' < "$HOME_DIRECTORY/.aws/credentials" | head -n 1)
fi
if [[ -z "${AWS_PROFILE:-}" ]]; then
  throw_exception "AWS credentials are not configured (or AWS_PROFILE is not set)"
fi
export AWS_PROFILE

AWS_ACCOUNT=$(aws --output json sts get-caller-identity | jq -r '.Account')

echo "ℹ️  Your current AWS profile is named $AWS_PROFILE"
echo "ℹ️  The session is for the AWS account $AWS_ACCOUNT"

# Now that we've checked for sanity, we can begin
#

# Handle project not being given as first argument
if [ -z "$1" ];then
  BUCKET_LISTING=$(aws s3api list-buckets --output json | jq -r '.Buckets[]?.Name // empty')

  throw_exception "Please provide the project name as the first argument (e.g. 'web')
ℹ️  Hint: It's the first bit of a bucket ending with '-dev-terraform-backends'. Here's a listing of all the buckets in this account:

$BUCKET_LISTING"
fi
PROJECT=$1
BUCKET="$PROJECT-dev-terraform-backends"

# Do a soft check on AWS account name not matching project name
ACCOUNT_ALIAS=$(aws --output json iam list-account-aliases | jq -r '.AccountAliases[0]')
if ! [[ "$ACCOUNT_ALIAS" =~ .*$PROJECT.* ]];then
  echo "⚠️  🤖 DANGER, WILL ROBINSON! The project name isn't in the AWS account name. Proceeding, but please make sure this is the correct AWS account:
Account alias:  $ACCOUNT_ALIAS
Account number: $AWS_ACCOUNT
"
fi

# Handle 'workspace' name (application name) not being given as second argument
BUCKET_CONTENTS=$(aws s3 ls "s3://$BUCKET/") # Done in two parts so this can be caught by the trap
WORKSPACE_LISTING=$(echo "$BUCKET_CONTENTS" | sed 's/PRE //' | sed 's/\///')
if [ -z "$2" ];then
  throw_exception "Please provide one of these for the 'workspace' name as the second argument:
ℹ️
$WORKSPACE_LISTING"
fi
S3_WORKSPACE=$2

# Explicit check not needed here, since the raw command will yield an informative
# error for the trap
aws s3 cp "s3://$BUCKET/$S3_WORKSPACE/terraform.tfvars" .
echo "🤘 Copied variables file to terraform.tfvars"

# Function for changing Terraform workspaces
select_workspace() {
  WORKSPACE_TO_SET=$1

  WORKSPACES=$(terraform workspace list)
  if ! echo "$WORKSPACES" | grep -E "^[ *]*${WORKSPACE_TO_SET}$"; then
    terraform workspace new "$WORKSPACE_TO_SET"
  fi
  terraform workspace select "$WORKSPACE_TO_SET"
}

# Write the backend file
echo "
terraform {
  backend \"s3\" {
    bucket         = \"$BUCKET\"
    key            = \"$S3_WORKSPACE/$S3_WORKSPACE.tfstate\"
    region         = \"eu-central-1\"
    dynamodb_table = \"$PROJECT-dev-terraform-backends-statefile-locks\"
    encrypt        = true
  }
}
" > backend.tf
echo "🤘 Created backend (S3) configuration as 'backend.tf'"

echo "ℹ️ Running terraform init in order to persist later workspace selection"
terraform init

# If 'namespaced' is given as the third argument run in a workspace named after
# the user, and add the 'name_suffix' to the Terraform variables for the modules
# to use in their resource naming
if [ "$3" == "namespaced" ];then
  select_workspace "$USER" > /dev/null
  echo "ℹ️ You are in your own personal workspace ($USER)"

  echo "
name_suffix = \"$USER\"
  " >> terraform.tfvars
  echo "🤘 Added your username for resource namespacing"
# By default, use the default (shared) workspace
else
  select_workspace "default" > /dev/null
  echo "ℹ️ You are in the default (shared) workspace"
fi


if ! [[ -f ".gitignore" ]]; then
  touch .gitignore
  echo "🤘 Created .gitignore file, because one didn't exist"
fi
IGNORED_FILES=( "node_modules" "dist" "coverage/" ".npmrc" ".DS_Store" "config/local.json" ".terraform" ".terraform.lock.hcl" "terraform.tfstate*" "*.tfvars" "backend.tf")
for this_filename in "${IGNORED_FILES[@]}"
do :
  if ! grep -q "$this_filename" '.gitignore'; then
    echo "$this_filename" >> .gitignore
    echo "🤘 Added $this_filename to .gitignore because it was missing"
  fi
done
