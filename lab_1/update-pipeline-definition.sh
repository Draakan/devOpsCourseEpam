#!/bin/bash

if ! command -v jq &> /dev/null
then
  echo "jq command not found. You need to install it"
	echo "e.g 'sudo apt install jq' or 'sudo snap install jq'"
  exit 1;
fi

if [[ ! -f $1 ]]
then
	echo "target file not found"
  exit 1;
fi

file_path=$1
changed_file_name="pipeline-$(date +'%Y-%m-%d-%H-%M').json"
branch=main
owner=draakan
poll_for_source_changes=false
configuration=development

options=$(getopt -o o:c:b:p --long owner:,configuration:,branch:,poll_for_source_changes -- "$@")

eval set -- "$options"

while true; do
  case "$1" in
    -o|--owner)
      owner="$2"
      shift 2
      ;;
    -c|--configuration)
      configuration="$2"
      shift 2
      ;;
    -b|--branch)
      branch="$2"
      shift 2
      ;;
    -p|--poll_for_source_changes)
      poll_for_source_changes=true
      shift
      ;;
    --)
      shift
      ;;
    *)
      break
      ;;
  esac
done

echo "Running the $0 with:"
echo "owner: $owner"
echo "configuration: $configuration"
echo "branch: $branch"
echo "poll_for_source_changes: $poll_for_source_changes"

has_all_required_properties=$(jq \
'
[
.pipeline.version,
.pipeline.stages[0].actions[0].configuration.Branch,
.pipeline.stages[0].actions[0].configuration.Owner,
.pipeline.stages[0].actions[0].configuration.PollForSourceChanges
] | all
' < $file_path)

if [[ ! $has_all_required_properties == "true" ]]
then
	echo "not all required properties exist"
  exit 1;
fi

jq \
--arg branch "$branch" \
--arg owner "$owner" \
--arg poll_for_source_changes "$poll_for_source_changes" \
--arg configuration "$configuration" \
'
del(.metadata) |
.pipeline.version = (.pipeline.version + 1) |
.pipeline.stages[0].actions[0].configuration.Branch = $branch |
.pipeline.stages[0].actions[0].configuration.Owner = $owner |
.pipeline.stages[0].actions[0].configuration.PollForSourceChanges = ($poll_for_source_changes | test("true")) |
.pipeline.stages |= map (
	if (.actions[0].configuration.EnvironmentVariables | type) == "string"
	then .actions[0].configuration.EnvironmentVariables = (
		.actions[0].configuration.EnvironmentVariables | sub("{{BUILD_CONFIGURATION value}}"; $configuration)
	) else . end
)
' < $file_path > $changed_file_name

echo "Changes are saved in $changed_file_name"


