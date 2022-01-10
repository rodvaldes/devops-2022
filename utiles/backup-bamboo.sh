#!/bin/bash
#
#  Script Backup de Bamboo
#
# THIS IS NOT PLUG AND PLAY. YOU NEED TO READ THIS SCRIPT 
# AND ADAPT IT TO YOUR VERY REQUIREMENTS
#
# This script should be used as a guide on what steps should be taken to proceed
# with an external backup of Bamboo. It is expected that each customer may have 
# particular requirements and changes to this script might be necessary
# 

# This script will:
# * Pause your Bamboo instance
# * Sync your Bamboo home contents to a backup location
# * Dump your MySQL/PostgreSQL/Favorite database
# * Resume your Bamboo instance

# Requirements:
# * rsync
# * curl
# * python
# * mysqldump or pg_dump (or any DB_dump tool you require)
# * bamboo admin account credentials or a PAT (see below)

# Usage:
# Adjust any variables within the # VARIABLES block
# Run it from the command line or cron

#
# VARIABLES
#
curl="/usr/bin/curl -s -k"
rsync="/usr/bin/rsync -a --numeric-ids --sparse --delete"
backup_dir="/home/robot/backups"
backup_sql="${backup_dir}/bamboo_database.sql"
bamboo_home="/var/atlassian/bamboo/atlassian-bamboo-8.1.1"
bamboo_url="http://localhost:8085"
url="${bamboo_url}/rest/api/latest/server"
verbose=1

# Define the authentication method: token, or user and password
# We are using auth="userpass" by default
# If you prefer to use a Personal Authentication Token (PAT), define auth="token"
# https://confluence.atlassian.com/bamboo/personal-access-tokens-976779873.html
auth="userpass"
#auth="token"
username="admin"
password="admin"
token="XXXXXYYYYYZZZZZZAAAAAABBBBBBCCCCCC"

# Define the number of times and the interval between each state check
# Once a request for a PAUSED state is issued, Bamboo will remain in a
# PAUSING state until all jobs are completed before declaring itself 
# as PAUSED
# * Default: Tries=60, Interval=30 (s) = Total 30m
getStateTries=60
getStateInterval=30

# Try to revert to the initial Bamboo state if the script fails. Recommended
revertIfFail=1

#
# END OF VARIABLES
#

# -e will make this script fail on first error
set -e

# Print verbose logs
verbose() {
 ((verbose)) && printf " ==> $*\n"
}

# Export the authentication method to curl
case $auth in
  userpass)
    verbose "_CURL_AUTH=userpass"
    _CURL_AUTH="-u ${username}:${password}" 
    ;;
  token)
    verbose "_CURL_AUTH=token"
    _CURL_AUTH="-H \"Authorization: Bearer ${token}\""
    ;;
  *)
    echo "You must set \$auth to either \"userpass\" or \"token\""
    ;;
esac

# Get the current state of Bamboo
getState() {
  ${curl} -H "Content-Type:application/json" -H "Accept:application/json" \
    ${_CURL_AUTH} -X GET ${url} 2>/dev/null \
    | python -c 'import json,sys;print json.load(sys.stdin)["state"]'
}

# Define vars and actions according to the state
defineState() {
  case $1 in
    resume|RUNNING)
      api_state="RUNNING" && action="resume" && revert="pause" ;;
    pause|PAUSING|PAUSED)
      api_state="PAUSED" && action="pause" && revert="resume" ;;
  esac
}

# Wait for a State to be present
# Uses a combination of $getStateTries and $getStateInterval
waitforState() {
  # ARG1 is the desired state RUNNING / PAUSED
  # ARG2 is the timeout (1 sec interval)
  trap 'return 1' SIGINT SIGTERM 
  max_retry=$2
  counter=1
  defineState $1
  verbose "Expected state: ${api_state^^}"
  until (getState | grep -q ${api_state^^}) ; do
    sleep ${getStateInterval} 
    [[ ${counter} = ${max_retry} ]] && echo "State check failed" && return 1
    echo "Waiting for ${api_state^^} state. Trying again. #${counter}"
    ((counter++))
  done
  verbose "Acquired state: $(getState)"
}

# Modifies Bamboo state
setState() {
  # ARG1 is the desired state RUNNING / PAUSED
  new_state=$1
  curr_state="$(getState)"
  verbose "Current state: ${curr_state}" 

  callsetState() {
    defineState $1
    if [ "$2" = "revert" ] ; then
      _target="${url}/${revert}?os_authType=basic"
    else
      _target="${url}/${action}?os_authType=basic"
    fi

    verbose "Running ${curl} ***masked*** -X \"${_target}\""
    eval $(echo ${curl} ${_CURL_AUTH} -X POST -o /dev/null ${_target}) 
  }
  
  verbose "Sending API call state to ${new_state} Bamboo"
  callsetState ${new_state}
  verbose "Calling waitforState ${new_state} ${getStateTries}"
  waitforState ${new_state} ${getStateTries} ||  \
    ( ((revertIfFail)) \
        && echo "Failed to set state to ${new_state}. Reverting state" \
        && echo "Current state: $(getState)" \
        && callsetState ${new_state} revert \
        && waitforState ${curr_state} ${getStateTries} \
        && return 1)
}

# Collect Original state before anything
INITIAL_STATE=$(getState)
verbose "Initial state is: ${INITIAL_STATE}"

# Pause server with validation
# Will try to set Bamboo into a PAUSED state
# It will try up (getStateTries x getStateInterval)
echo "Starting Bamboo backup: $(date)"
verbose "Calling Bamboo setState pause"
setState pause && GOOD_TO_BACKUP=1

if [ ${GOOD_TO_BACKUP} ] ; then
  echo "Bamboo was set to a PAUSED state. Proceeding with FS/DB Backup"
  # Backup Bamboo home
  # It excludes the artifact folder
  # You may remove this exclusion but your backup size and time may increase considerably
  verbose "Calling Filesystem backup process"
  ${rsync} --exclude=build-dir --exclude=build_logs --exclude=artifacts ${bamboo_home} ${backup_dir}

  # Dump the database contents
  # Replace with the database user
  # Make sure your backup command works non-interactively (no confirmations/password 
  # prompts). Some databases require ACLs to be set. Make sure it allows the script to
  # dump the DB.
  # Validate the command manually before using it with in the script
  verbose "Calling DB backup process"
  #pg_dump -U postgres -h localhost > ${backup_sql}
  mysqldump -uroot -proot bamboo > ${backup_sql}

  # Resume Bamboo
  # Puts Bamboo in a RUNNING state
  verbose "Calling Bamboo setState resume"
  setState resume && echo "Bamboo was set to a RUNNING state. Backup finished successfully"
else
  echo "There was an issue with the backup. Exiting"
  exit 1
fi