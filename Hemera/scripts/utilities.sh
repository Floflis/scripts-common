#!/bin/bash
#
# Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
# Copyright (C) 2010 Bertrand Benoit <projettwk@users.sourceforge.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see http://www.gnu.org/licenses
# or write to the Free Software Foundation,Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA 02110-1301  USA
#
# Version: 1.0
# Description: provides lots of utilities functions.
#
# This script must NOT be directly called.

#########################
## Global configuration
# Cf. http://www.gnu.org/software/bash/manual/bashref.html#The-Shopt-Builtin
# Ensures respect to quoted arguments to the conditional command's =~ operator. 
shopt -s compat31

# Ensures installDir is defined.
[ -z "$installDir" ] && echo -e "This script must NOT be directly called. installDir variable not defined" >&2 && exit 1
source "$installDir/scripts/defineConstants.sh"

#########################
## Global variables
[ -z "$verbose" ] && verbose=0
[ -z "$checkConfAndQuit" ] && checkConfAndQuit=0 # special toggle defining if system must quit after configuration check (activate when using -X option of scripts)

# Defines default category if not already defined.
[ -z "$category" ] && category="general"


#########################
## Functions - various

# usage: _doGetVersion <NEWS file path>
# This method returns the more recent version of the given NEWS file path.
# It can be used to define version of any installation of Hemera (e.g. while upgrading).
function _doGetVersion() {
  local _newsFile="$1"

  # Lookup the version in the NEWS file (which did not exist in version 0.1)
  [ ! -f "$_newsFile" ] && echo "0.1.0" && return 0

  # Extracts the version.
  grep "version [0-9]" "$_newsFile" |head -n 1 |sed -e 's/^.*version[ ]\([0-9][0-9.]*\)[ ].*$/\1/;'
}

# usage: getVersion
function getVersion() {
  _doGetVersion "$installDir/NEWS"
}

# usage: getDetailedVersion
function getDetailedVersion() {
  # General version is given by the $H_VERSION variable.
  # Before all, trying to get precise version in case of source code version.
  revision=$( LANG=C svn info "$installDir" 2>&1|grep "^Revision:" |sed -e 's/Revision:[ \t][ \t]*/-r/' )

  # Prints the general version and the potential precise version (will be empty if not defined).
  echo "$H_VERSION$revision"
}

# usage: isVersionGreater <version 1> <version 2>
# Version syntax must be digits separated by dot (e.g. 0.1.0).
function isVersionGreater() {
  # Safeguard - ensures syntax is respected.
  [ $( echo "$1" |grep -e "^[0-9][0-9.]*$" |wc -l ) -eq 1 ] || errorMessage "Unable to compare version because version '$1' does not fit the syntax (digits separated by dot)" $ERROR_ENVIRONMENT
  [ $( echo "$2" |grep -e "^[0-9][0-9.]*$" |wc -l ) -eq 1 ] || errorMessage "Unable to compare version because version '$2' does not fit the syntax (digits separated by dot)" $ERROR_ENVIRONMENT

  # Defines arrays with specified versions.
  local _v1Array=( ${1//./ } )
  local _v2Array=( ${2//./ } )

  # Lookups version element until they are not the same.
  index=0
  while [ ${_v1Array[$index]} -eq ${_v2Array[$index]} ]; do
    let index++

    # Ensures there is another element for each version.
    [ -z "${_v1Array[$index]}" ] && v1End=1 || v1End=0
    [ -z "${_v2Array[$index]}" ] && v2End=1 || v2End=0

    # Continues on next iteration if NONE is empty.
    [ $v1End -eq 0 ] && [ $v2End -eq 0 ] && continue

    # If the two verions have been fully managed, they are equals (so the first is NOT greater).
    [ $v1End -eq 1 ] && [ $v2End -eq 1 ] && return 1

    # if the first version has not been fully managed, it is greater
    #  than the second (there is still version information), and vice versa.
    [ $v1End -eq 0 ] && return 0 || return 1
  done

  # returns the comparaison of the element with 'index'.
  [ ${_v1Array[$index]} -gt ${_v2Array[$index]} ]
}

# usage: writeMessage <message> [<0 or 1>]
# 0: keep on the same line
# 1: move to next line
function writeMessage() {
  local message="$1"
  messageTime=$(date +"%d/%m/%y %H:%M.%S")

  echoOption="-e"
  [ ! -z "$2" ] && [ "$2" -eq 0 ] && echoOption="-ne"

  # Checks if message must be shown on console.
  if [ -z "$noconsole" ] || [ $noconsole -eq 0 ]; then
    echo $echoOption "$messageTime  [$category]  $message" |tee -a "${h_logFile:-/tmp/hemera.log}"
  else
    echo $echoOption "$messageTime  [$category]  $message" >> "${h_logFile:-/tmp/hemera.log}"
  fi
}

# usage: info <message> [<0 or 1>]
# Shows message only if verbose is ON.
function info() {
  [ $verbose -eq 0 ] && return 0
  local message="$1"
  shift
  writeMessage "INFO: $message" $*
}

# usage: warning <message>
# Shows warning message.
function warning() {
  local message="$1"
  messageTime=$(date +"%d/%m/%y %H:%M.%S")

  # Checks if message must be shown on console.
  if [ -z "$noconsole" ] || [ $noconsole -eq 0 ]; then
    echo -e "$messageTime  [$category]  \E[31m\E[4mWARNING\E[0m: $message" |tee -a "${h_logFile:-/tmp/hemera.log}" >&2
  else
    echo -e "$messageTime  [$category]  \E[31m\E[4mWARNING\E[0m: $message" >> "${h_logFile:-/tmp/hemera.log}"
  fi
}

# usage: errorMessage <message> [<exit code>]
# Shows error message and exits.
function errorMessage() {
  local message="$1"
  messageTime=$(date +"%d/%m/%y %H:%M.%S")

  # Checks if message must be shown on console.
  if [ -z "$noconsole" ] || [ $noconsole -eq 0 ]; then
    echo -e "$messageTime  [$category]  \E[31m\E[4mERROR\E[0m: $message" |tee -a "${h_logFile:-/tmp/hemera.log}" >&2
  else
    echo -e "$messageTime  [$category]  \E[31m\E[4mERROR\E[0m: $message" >> "${h_logFile:-/tmp/hemera.log}"
  fi

  exit ${2:-$ERROR_DEFAULT}
}

# usage: updateStructure <dir path>
function updateStructure() {
  mkdir -p "$1" || errorMessage "Unable to create structure pieces (check permissions): $1" $ERROR_ENVIRONMENT
}

# usage: getLastLinesFromN <file path> <line begin>
function getLastLinesFromN() {
  local _source="$1" _lineBegin="$2"

  cat -n "$_source" |awk "\$1 >= $_lineBegin {print}" |sed -e 's/^[ \t]*[0-9][0-9]*[ \t]*//'
}

# usage: getLinesFromNToP <file path> <from line N> <line begin> <line end>
function getLinesFromNToP() {
  local _source="$1" _lineBegin="$2" _lineEnd="$3"
  local _sourceLineCount=$( cat "$_source" |wc -l )

  tail -n $( expr $_sourceLineCount - $_lineBegin + 1 ) "$_source" |head -n $( expr $_lineEnd - $_lineBegin + 1 )
}

# usage: checkGNUWhich
# Ensures "which" is a GNU which.
function checkGNUWhich() {
  [ $( LANG=C which --version 2>&1|head -n 1 |grep -w "GNU" |wc -l ) -eq 1 ]
}

# usage: checkEnvironment
function checkEnvironment() {
  checkGNUWhich || errorMessage "GNU version of which not found. Please install it." $ERROR_ENVIRONMENT
}

# usage: checkLSB
function checkLSB() {
  lsbFunctions="/lib/lsb/init-functions"
  [ -f "$lsbFunctions" ] || errorMessage "Unable to find LSB file $lsbFunctions. Please install it." $ERROR_ENVIRONMENT
  source "$lsbFunctions"
}

# usage: isEmptyDirectory <path>
function isEmptyDirectory()
{
  [ $( ls -1 "$1" |wc -l ) -eq 0 ]
}

# usage: cleanNotManagedInput
function cleanNotManagedInput() {
  info "Cleaning NOT managed input (new and current)"
  rm -f "$h_newInputDir"/* "$h_curInputDir"/* >/dev/null || exit $ERROR_ENVIRONMENT
}

# usage: waitUntilAllInputManaged [<timeout>]
# Default timeout is 2 minutes.
function waitUntilAllInputManaged() {
  local _remainingTime=${1:-120}
  info "Waiting until all input are managed (timeout: $_remainingTime seconds)"
  while ! isEmptyDirectory "$h_newInputDir" || ! isEmptyDirectory "$h_curInputDir"; do
    [ $_remainingTime -eq 0 ] && break
    sleep 1
    let _remainingTime--
  done
}

# usage: matchesOneOf <patterns> <element to check>
function matchesOneOf() {
  local _patterns="$1" _element="$2"

  for pattern in $_patterns; do
    [[ "$_element" =~ "$pattern" ]] && return 0
  done

  return 1
}

# usage: extractI18Nelement <i18n file> <destination file>
function extractI18Nelement() {
  local _i18nFile="$1" _destFile="$2"
  grep -re "^[ \t]*[^#]" "$_i18nFile" |sort > "$_destFile"
}

# usage: checkOSLocale
function checkOSLocale() {
  [ $checkConfAndQuit -eq 0 ] && info "Checking LANG environment variable ... "

  # Checks LANG is defined with UTF-8.
  if [ $( echo $LANG |grep -i "[.]utf[-]*8" |wc -l ) -eq 0 ] ; then
      # It is a fatal error but in 'checkConfAndQuit' mode.
      warning "You must update your LANG environment variable to use the UTF-8 charmaps ('${LANG:-NONE}' detected). Until then Hemera will attempt using en_US.UTF-8."

      export LANG="en_US.UTF-8"
  fi

  # Ensures defined LANG is avaulable on the OS.
  if [ $( locale -a 2>/dev/null |grep -i $LANG |wc -l ) -eq 0 ] && [ $( locale -a 2>/dev/null |grep $( echo $LANG |sed -e 's/UTF[-]*8/utf8/' ) |wc -l ) -eq 0 ]; then
    # It is a fatal error but in 'checkConfAndQuit' mode.
    warning "Although the current OS locale '$LANG' defines to use the UTF-8 charmaps, it is not available (checked with 'locale -a'). You must install it or update your LANG environment variable. Until then Hemera will attempt using en_US.UTF-8."

    export LANG="en_US.UTF-8"
  fi

  return 0
}

# usage: getOfflineDocPath
# echoes the offline documentation path if any, empty string otherwise.
function getOfflineDocPath() {
  local _docPath="$installDir/doc/HemeraBook/index.html"

  [ ! -f "$_docPath" ] && echo "" && return 1
  echo "$_docPath"
  return 0
}

# usage: getURLContents <url> <destination file>
function getURLContents() {
  info "Getting contents of URL '$1'"
  ! wget --user-agent="Mozilla/Firefox 3.6" -q "$1" -O "$2" && writeMessage "Error while getting contents of URL '$1'" && return 1
  info "Got contents of URL '$1' with success"
  return 0
}

#########################
## Functions - PID & Process management

# usage: writePIDFile <pid file>
function writePIDFile() {
  local _pidFile="$1"
  [ -f "$_pidFile" ] && errorMessage "PID file '$_pidFile' already exists."
  echo "$$" > "$_pidFile"
  info "Written PID '$$' in file '$1'."
}

# usage: deletePIDFile <pid file>
function deletePIDFile() {
  info "Removing PID file '$1'"
  rm -f "$1"
}

# usage: getPIDFromFile <pid file>
function getPIDFromFile() {
  local _pidFile="$1"

  # Checks if PID file exists, otherwise regard process as NOT running.
  [ ! -f "$_pidFile" ] && info "PID file '$_pidFile' not found." && return 1

  # Gets PID from file, and ensures it is defined.
  local pidToCheck=$( head -n 1 "$1" )
  [ -z "$pidToCheck" ] && info "PID file '$_pidFile' empty." && return 1

  # Writes it.
  echo "$pidToCheck" && return 0
}

# usage: isRunningProcess <pid file> <process name>
function isRunningProcess() {
  local _pidFile="$1"
  local _processName=$( basename "$2" ) # Removes the path which can be different between each action

  # Checks if PID file exists, otherwise regard process as NOT running.
  pidToCheck=$( getPIDFromFile "$_pidFile" ) || return 1

  # Checks if a process with specified PID is running.
  info "Checking running process, PID=$pidToCheck, process=$_processName."
  [ $( ps h -p "$pidToCheck" |grep -E "$_processName($|[ \t])" |wc -l ) -eq 1 ] && return 0

  # It is not the case, informs and deletes the PID file.
  deletePIDFile "$_pidFile"
  info "process is dead but pid file exists. Deleted it."
  return 1
}

# usage: startProcess <pid file> <process name>
function startProcess() {
  local _pidFile="$1"
  shift
  local _processName="$1"

  ## Writes the PID file.
  writePIDFile "$_pidFile" || return 1

  ## If noconsole is not already defined, messages must only be written in log file (no more on console).
  [ -z "$noconsole" ] && export noconsole=1

  ## Executes the specified command -> such a way the command WILL have the PID written in the file.
  info "Starting background command: $*"
  exec $*
}

# usage: stopProcess <pid file> <process name>
function stopProcess() {
  local _pidFile="$1"
  local _processName="$2"

  # Gets the PID.
  pidToStop=$( getPIDFromFile "$_pidFile" ) || errorMessage "No PID found in file '$_pidFile'."

  # Requests stop.
  info "Requesting process stop, PID=$pidToStop, process=$_processName."
  kill -s TERM "$pidToStop" || return 1

  # Waits until process stops, or timeout is reached.
  remainingTime=$PROCESS_STOP_TIMEOUT
  while [ $remainingTime -gt 0 ] && isRunningProcess "$_pidFile" "$_processName"; do
    # Waits 1 second.
    sleep 1
    let remainingTime--
  done

  # Checks if it is still running, otherwise deletes the PID file ands returns.
  ! isRunningProcess "$_pidFile" "$_processName" && deletePIDFile "$_pidFile" && return 0

  # Destroy the process.
  info "Killing process stop, PID=$pidToStop, process=$_processName."
  kill -s KILL "$pidToStop" || return 1
}

# usage: killChildProcesses <pid> [1]
# 1: toggle defining is it the top hierarchy proces.
function killChildProcesses() {
  local _pid=$1 _topProcess=${2:-0}

  # Manages PID of each child process of THIS process.
  for childProcessPid in $( ps -o pid --no-headers --ppid $_pid ); do
    # Ensures the child process still exists; it won't be the case of the last launched ps allowing to
    #  get child process ...
    $( ps -p $childProcessPid --no-headers >/dev/null ) && killChildProcesses "$childProcessPid"
  done

  # Kills the child process if not main one.
  [ $_topProcess -eq 0 ] && kill -s HUP $_pid 
}

# usage: setUpKillChildTrap <process name>
function setUpKillChildTrap() {
  export TRAP_processName="$1"

  ## IMPORTANT: when the main process is stopped (or killed), all its child must be stopped too,
  ##  defines some trap to ensure that.
  # When this process receive an EXIT signal, kills all its child processes.
  # N.B.: old system, killing all process of the same process group was causing error like "broken pipe" ...
  trap 'writeMessage "Killing all processes of the group of main process $TRAP_processName"; killChildProcesses $$ 1; exit 0' EXIT
}

# usage: manageDaemon <action> <name> <pid file> <process> [<logFile> <outputFile> <options>]
#   action can be: start, status, stop (and daemon, only for internal purposes)
#   logFile, outputFile and options are only needed if action is "start"
function manageDaemon() {
  local _action="$1" _name="$2" _pidFile="$3" _processName="$4"
  local _logFile="$5" _outputFile="$6" _options="$7"

  case "$_action" in
    daemon)
      # If the option is NOT the special one which activates last action "run"; setups trap ensuring
      # children process will be stopped in same time this main process is stopped, otherwise it will
      # setup when managing the run action.
      [[ "$_options" != "$DAEMON_SPECIAL_RUN_ACTION" ]] && setUpKillChildTrap "$_processName"

      # Starts the process.
      startProcess "$_pidFile" "$_processName" $_options
    ;;

    start)
      # Ensures it is not already running.
      isRunningProcess "$_pidFile" "$_processName" && writeMessage "$_name is already running." && return 0

      # Starts it, launching this script in daemon mode.
      h_logFile="$_logFile" "$0" -D >>"$_outputFile" 2>&1 &
      writeMessage "Launched $_name."
    ;;

    status)
      isRunningProcess "$_pidFile" "$_processName" && writeMessage "$_name is running." || writeMessage "$_name is stopped."
    ;;

    stop)
      # Ensures it is running.
      ! isRunningProcess "$_pidFile" "$_processName" && writeMessage "$_name is NOT running." && return 0

      # Stops the process.
      stopProcess "$_pidFile" "$_processName" || errorMessage "Unable to stop $_name."
      writeMessage "Stopped $_name."
    ;;

    run)
      ## If noconsole is not already defined, messages must only be written in log file (no more on console).
      [ -z "$noconsole" ] && export noconsole=1

      # Setups trap ensuring children process will be stopped in same time this main process is stopped.
      setUpKillChildTrap "$_processName"
    ;;

    [?])  return 1;;
  esac
}

# usage: daemonUsage <name>
function daemonUsage() {
  local _name="$1"
  echo -e "Usage: $0 -S||-T||-K||-X [-hv]"
  echo -e "-S\tstart $_name daemon"
  echo -e "-T\tstatus $_name daemon"
  echo -e "-K\tstop $_name daemon"
  echo -e "-X\tcheck configuration and quit"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"
  echo -e "\nYou must either start, status or stop the $_name daemon."

  exit $ERROR_USAGE
}

# usage: isHemeraComponentStarted
# returns <true> if at least one component is started (regarding PID files).
function isHemeraComponentStarted() {
  [ $( find "$h_pidDir" -type f |wc -l ) -gt 0 ]
}

#########################
## Functions - configuration

# usage: getConfigValue <config key>
function getConfigValue() {
  # Checks if the key exists.
  if [ $( grep -re "^$1=" "$h_configurationFile" 2>/dev/null|wc -l ) -eq 0 ]; then
    # Prints error message (and exit) only if NOT in "check config and quit" mode.
    [ $checkConfAndQuit -eq 0 ] && errorMessage "Configuration key '$1' NOT found" $ERROR_CONFIG_VARIOUS
    echo -e "configuration key \E[31mNOT FOUND\E[0m" && return $ERROR_CONFIG_VARIOUS
  fi

  # Gets the value (may be empty).
  # N.B.: in case there is several, takes only the last one (interesting when there is several definition in configuration file).
  grep -re "^$1=" "$h_configurationFile" 2>/dev/null|sed -e 's/^[^=]*=//;s/"//g;' |tail -n 1
  return 0
}

# usage: getConfigValue <supported values> <value to check>
function checkAvailableValue() {
  [ $( echo "$1" |grep -w "$2" |wc -l ) -eq 1 ]
}

# usage: isAbsolutePath <path>
# "true" if the path begins with "/"
function isAbsolutePath() {
  [[ "$1" =~ "^\/.*$" ]]
}

# usage: isSimplePath <path>
# "true" if there is NO "/" character (and so the tool should be in PATH)
function isSimplePath() {
  [[ "$1" =~ "^[^\/]*$" ]]
}

# usage: getConfigPath <config key> [<path to prepend> <force prepend>]
# <path to prepend>: the path to prepend if the path is NOT absolute and NOT simple.
# Defaut <path to prepend> is $h_tpDir
# <force prepend>: 0=disabled (default), 1=force prepend for "single path" (useful for data file)
function getConfigPath() {
  local _configKey="$1" _pathToPreprend="${2:-$h_tpDir}" _forcePrepend="${3:-0}"

  value=$( getConfigValue "$_configKey" ) || return 1

  # Checks if it is an absolute path.
  isAbsolutePath "$value" && echo "$value" && return 0

  # Checks if it is a "simple" path.
  isSimplePath "$value" && [ $_forcePrepend -eq 0 ] && echo "$value" && return 0

  # Prefixes with Hemera install directory path.
  echo "$_pathToPreprend/$value"
}

# usage: checkBin <binary name/path>
function checkBin() {
  # Informs only if not in 'checkConfAndQuit' mode.
  [ $checkConfAndQuit -eq 0 ] && info "Checking binary '$1' ... "

  # Checks if the binary is available.
  which "$1" >/dev/null 2>&1 && return 0
 
  # It is not the case, if NOT in 'checkConfAndQuit' mode, it is a fatal error.
  [ $checkConfAndQuit -eq 0 ] && errorMessage "Unable to find binary '$1'." $ERROR_CHECK_BIN
  # Otherwise, simple returns an error code.
  return $ERROR_CHECK_BIN
}

# usage: checkDataFile <data file path>
function checkDataFile() {
  # Informs only if not in 'checkConfAndQuit' mode.
  [ $checkConfAndQuit -eq 0 ] && info "Checking data file '$1' ... "

  # Checks if the file exists.
  [ -f "$1" ] && return 0
 
  # It is not the case, if NOT in 'checkConfAndQuit' mode, it is a fatal error.
  [ $checkConfAndQuit -eq 0 ] && errorMessage "Unable to find data file '$1'." $ERROR_CHECK_CONFIG
  # Otherwise, simple returns an error code.
  return $ERROR_CHECK_CONFIG
}

# usage: checkAndGetConfig <config key> <config type> [<path to prepend>]
# <config key>: the full config key corresponding to configuration element in configuration file
# <config type>: the type of config among
#   $CONFIG_TYPE_OPTION: options -> nothing more will be done
#   $CONFIG_TYPE_BIN: binary -> system will ensure binary path is available
#   $CONFIG_TYPE_DATA: data -> data file path existence will be checked
# <path to prepend>: (only for type $CONFIG_TYPE_BIN and $CONFIG_TYPE_DATA) the path to prepend if
#  the path is NOT absolute and NOT simple. Defaut <path to prepend> is $h_tpDir
# If all is OK, it defined the h_lastConfig variable with the requested configuration element.
function checkAndSetConfig() {
  local _configKey="$1" _configType="$2" _pathToPreprend="${3:-$h_tpDir}"
  export h_lastConfig="NotFound" # reinit global variable.

  [ -z "$_configKey" ] && errorMessage "checkAndSetConfig function badly used (configuration key not specified)"
  [ -z "$_configType" ] && errorMessage "checkAndSetConfig function badly used (configuration type not specified)"

  local _message="Checking '$_configKey' ... "

  # Informs about config key to check, according to situation:
  #  - in 'normal' mode, message is only shown in verbose mode
  #  - in 'checkConfAndQuit' mode, message is always shown
  [ $checkConfAndQuit -eq 0 ] && info "$_message" || writeMessage "$_message" 0

  # Gets the value, according to the type of config.
  if [ $_configType -eq $CONFIG_TYPE_OPTION ]; then
    _value=$( getConfigValue "$_configKey" )
    valueGetStatus=$?
  else    
    [ $_configType -eq $CONFIG_TYPE_DATA ] && forcePrepend=1 || forcePrepend=0
    _value=$( getConfigPath "$_configKey" "$_pathToPreprend" $forcePrepend )
    valueGetStatus=$?
  fi

  # Ensures value has been successfully got.
  if [ $valueGetStatus -ne 0 ]; then
    # Prints error messafe is any.
    [ ! -z "$_value" ] && echo -e "$_value" |tee -a "${h_logFile:-/tmp/hemera.log}"
    # If NOT in 'checkConfAndQuit' mode, it is a fatal error, so exists.
    [ $checkConfAndQuit -eq 0 ] && exit $valueGetStatus
    # Otherwise, simply returns an error status.
    return $valueGetStatus
  fi

  # Checks if it is a path.
  if [ $_configType -eq $CONFIG_TYPE_OPTION ]; then
    # No sense.
    checkPathStatus=0
  elif [ $_configType -eq $CONFIG_TYPE_BIN ]; then
    checkBin "$_value"
    checkPathStatus=$?
  elif [ $_configType -eq $CONFIG_TYPE_DATA ]; then
    checkDataFile "$_value"
    checkPathStatus=$?
  fi

  # Ensures path check has been successfully done.
  if [ $checkPathStatus -ne 0 ]; then
    # If NOT in 'checkConfAndQuit' mode, it is a fatal error, so exists.
    [ $checkConfAndQuit -eq 0 ] && exit $checkPathStatus
    # Otherwise, show an error message, and simply returns an error status.
    echo -e "$_value \E[31mNOT FOUND\E[0m" |tee -a "${h_logFile:-/tmp/hemera.log}"
    return $checkPathStatus
  fi

  # Here, all is OK, there is nothing more to do.
  [ $checkConfAndQuit -eq 1 ] && echo "OK" |tee -a "${h_logFile:-/tmp/hemera.log}"

  # Sets the global variable
  export h_lastConfig="$_value"
  return 0
}

# usage: checkAndFormatPath <paths>
# ALL paths must be specified if a single parameter.
function checkAndFormatPath() {
  local _paths="$1"

  formattedPath=""
  for pathToCheckRaw in $( echo $_paths |sed -e 's/[ ]/€/g;s/:/ /g;' ); do
    pathToCheck=$( echo "$pathToCheckRaw" |sed -e 's/€/ /g;' )

    # Defines the completes path, according to absolute/relative path.
    completePath="$pathToCheck"
    ! isAbsolutePath "$pathToCheck" && completePath="$h_tpDir/$pathToCheck"

    # Uses "ls" to complete the path in case there is wildcard.
    if [ $( echo "$completePath" |grep "*" |wc -l ) -eq 1 ]; then
      formattedWildcard=$( echo "$completePath" |sed -e 's/^/"/;s/$/"/;s/*/"*"/g;s/""$//;' )
      completePath=$( ls -d $( eval echo $formattedWildcard ) )
    fi

    # Checks if it exists, if 'checkConfAndQuit' mode.
    if [ $checkConfAndQuit -eq 1 ]; then
      writeMessage "Checking path '$pathToCheck' ... " 0
      [ -d "$completePath" ] && echo "OK" |tee -a "${h_logFile:-/tmp/hemera.log}" || echo -e "\E[31mNOT FOUND\E[0m" |tee -a "${h_logFile:-/tmp/hemera.log}"
    fi

    # In any case, updates the formatted path list.
    formattedPath=$formattedPath:$completePath
  done
  echo "$formattedPath"
}

#########################
## Functions - uptime

# usage: initializeUptime
function initializeStartTime() {
  date +'%s' > "$h_startTime"
}

# usage: getUptime
function getUptime() {
  [ ! -f "$h_startTime" ] && echo "not started" && exit 0
  
  local _currentTime=$( date +'%s' )
  local _startTime=$( cat "$h_startTime" )
  local _uptime=$( expr $_currentTime - $_startTime )

  printf "%02dd %02dh:%02dm.%02ds" $(($_uptime/86400)) $(($_uptime%86400/3600)) $(($_uptime%3600/60)) $(($_uptime%60))
}


#########################
## Functions - Recognized Commands mode
# usage: initRecoCmdMode
# Creates hemera mode file with normal mode.
function initRecoCmdMode() {
  updateRecoCmdMode "$H_RECO_CMD_MODE_NORMAL_I18N"
}

# usage: updateRecoCmdMode <i18n mode>
function updateRecoCmdMode() {
  local _newModei18N="$1"

  # Defines the internal mode corresponding to this i18n mode (usually provided by speech recognition).
  local _modeIndex=0
  for availableMode in ${H_SUPPORTED_RECO_CMD_MODES_I18N[*]}; do
    # Checks if this is the specified mode.
    if [ "$_newModei18N" = "$availableMode" ]; then
      # It is the case, writes the corresponding internal mode in the mode file.
      echo "${H_SUPPORTED_RECO_CMD_MODES[$_modeIndex]}" > "$h_recoCmdModeFile"
      return 0
    fi

    let _modeIndex++
  done

  # No corresponding internal mode has been found, it is fatal.
  # It should NEVER happen because mode must have been checked before this call.
  errorMessage "Unable to find corresponding internal mode of I18N mode '$_newModei18N'" $ERROR_ENVIRONMENT
}

# usage: getRecoCmdMode
# Returns the recognized commands mode.
function getRecoCmdMode() {
  # Ensures the mode file exists.
  [ ! -f "$h_recoCmdModeFile" ] && errorMessage "Unable to find Hemera recognized command mode file '$h_recoCmdModeFile'" $ERROR_ENVIRONMENT
  cat "$h_recoCmdModeFile"
}


#########################
## Functions - commands

# usage: initializeCommandMap
function initializeCommandMap() {
  # Removes the potential existing list file.
  rm -f "$h_commandMap"

  # For each available commands.
  for commandRaw in $( find "$h_coreDir/command" -maxdepth 1 -type f ! -name "*~" ! -name "*.txt" |sort |sed -e 's/[ \t]/£/g;' ); do
    local _command=$( echo "$commandRaw" |sed -e 's/£/ /g;' )
    local _commandName=$( basename "$_command" )
    
    # Extracts keyword.
    local _keyword=$( head -n 30 "$_command" |grep "^#.Keyword:" |sed -e 's/^#.Keyword:[ \t]*//g;s/[ \t]*$//g;' )
    [ -z "$_keyword" ] && warning "The command '$_commandName' doesn't seem to respect format. It will be ignored." && continue

    # Updates command map file.
    for localizedName in $( grep -re "$_keyword"_"PATTERN_I18N" "$h_i18nFile" |sed -e 's/^[^(]*(//g;s/).*$//g;s/"//g;' ); do
      echo "$localizedName=$_command" >> "$h_commandMap"
    done
  done
}

# usage: getMappedCommand <speech recognition result command>
# <speech recognition result command>: 1 word corresponding to speeched command
# returns the mapped command script if any, empty string otherwise.
function getMappedCommand() {
  local _commandName="$1"

  # Ensures map file exists.
  [ ! -f "$h_commandMap" ] && warning "The command map file has not been initialized." && return 1

  # Attempts to get mapped command script.
  echo $( grep "^$_commandName=" "$h_commandMap" |sed -e 's/^[^=]*=//g;' )
}


#########################
## Functions - source code management
# usage: manageJavaHome
# Ensures JAVA environment is ok, and ensures JAVA_HOME is defined.
function manageJavaHome() {
  # Checks if environment variable JAVA_HOME is defined.
  if [ -z "$JAVA_HOME" ]; then
    # Checks if it is defined in configuration file.
    checkAndSetConfig "environment.java.home" "$CONFIG_TYPE_OPTION"    
    javaHome="$h_lastConfig"
    if [ -z "$javaHome" ]; then
      # It is a fatal error but in 'checkConfAndQuit' mode.
      local _errorMessage="You must either configure JAVA_HOME environment variable or environment.java.home configuration element."
      [ $checkConfAndQuit -eq 0 ] && errorMessage "$_errorMessage" $ERROR_ENVIRONMENT
      warning "$_errorMessage" && return 0
    fi

    # Ensures it exists.
    if [ ! -d "$javaHome" ]; then 
      # It is a fatal error but in 'checkConfAndQuit' mode.
      local _errorMessage="environment.java.home defined '$javaHome' which is not found."
      [ $checkConfAndQuit -eq 0 ] && errorMessage "$_errorMessage" $ERROR_CONFIG_VARIOUS
      warning "$_errorMessage" && return 0
    fi
    
    export JAVA_HOME="$javaHome"
  fi

  # Ensures it is a jdk home directory.
  local _javaPath="$JAVA_HOME/bin/java"
  local _javacPath="$JAVA_HOME/bin/javac"
  _errorMessage=""
  if [ ! -f "$_javaPath" ]; then
    _errorMessage="Unable to find java binary, ensure '$JAVA_HOME' is the home of a Java Development Kit version 6."
  elif [ ! -f "$_javacPath" ]; then
    _errorMessage="Unable to find javac binary, ensure '$JAVA_HOME' is the home of a Java Development Kit version 6."
  fi

  if [ ! -z "$_errorMessage" ]; then
    # It is a fatal error but in 'checkConfAndQuit' mode.
    [ $checkConfAndQuit -eq 0 ] && errorMessage "$_errorMessage" $ERROR_ENVIRONMENT
    warning "$_errorMessage" && return 0
  fi

  writeMessage "Found: $( "$_javaPath" -version 2>&1|head -n 2| sed -e 's/$/ [/;' |tr -d '\n' |sed -e 's/..$/]/' )"
}

# usage: manageAntHome
# Ensures ANT environment is ok, and ensures ANT_HOME is defined.
function manageAntHome() {
  # Checks if environment variable ANT_HOME is defined.
  if [ -z "$ANT_HOME" ]; then
    # Checks if it is defined in configuration file.
    checkAndSetConfig "environment.ant.home" "$CONFIG_TYPE_OPTION"    
    antHome="$h_lastConfig"
    if [ -z "$antHome" ]; then
      # It is a fatal error but in 'checkConfAndQuit' mode.
      local _errorMessage="You must either configure ANT_HOME environment variable or environment.ant.home configuration element."
      [ $checkConfAndQuit -eq 0 ] && errorMessage "$_errorMessage" $ERROR_ENVIRONMENT
      warning "$_errorMessage" && return 0
    fi

    # Ensures it exists.
    if [ ! -d "$antHome" ]; then 
      # It is a fatal error but in 'checkConfAndQuit' mode.
      local _errorMessage="environment.ant.home defined '$antHome' which is not found."
      [ $checkConfAndQuit -eq 0 ] && errorMessage "$_errorMessage" $ERROR_CONFIG_VARIOUS
      warning "$_errorMessage" && return 0
    fi

    export ANT_HOME="$antHome"
  fi

  # Checks ant is available.
  local _antPath="$ANT_HOME/bin/ant"
  if [ ! -f "$_antPath" ]; then
    # It is a fatal error but in 'checkConfAndQuit' mode.
    local _errorMessage="Unable to find ant binary, ensure '$ANT_HOME' is the home of an installation of Apache Ant." 
    [ $checkConfAndQuit -eq 0 ] && errorMessage "$_errorMessage" $ERROR_ENVIRONMENT
    warning "$_errorMessage" && return 0
  fi

  writeMessage "Found: $( "$_antPath" -v 2>&1|head -n 1 )"
}

# usage: manageTomcatHome
# Ensures Tomcat environment is ok, and defines h_tomcatDir.
function manageTomcatHome() {
  local tomcatDir="$h_tpDir/webServices/bin/tomcat"
  if [ ! -d "$tomcatDir" ]; then
    # It is a fatal error but in 'checkConfAndQuit' mode.
    local _errorMessage="Apache Tomcat '$tomcatDir' not found. You must either disable Tomcat activation (hemera.run.activation.tomcat), or install it/create a symbolic link."
    [ $checkConfAndQuit -eq 0 ] && errorMessage "$_errorMessage" $ERROR_CONFIG_VARIOUS
    warning "$_errorMessage" && return 0
  fi
  
  export h_tomcatDir="$tomcatDir"

  # Checks the Tomcat version.
  local _version="Apache Tomcat Version [unknown]"
  if [ -f "$tomcatDir/RELEASE-NOTES" ]; then
    _version=$( head -n 30 "$tomcatDir/RELEASE-NOTES" |grep "Apache Tomcat Version" |sed -e 's/^[ \t][ \t]*//g;' )
  elif [ -x "/bin/rpms" ]; then
    _version="Apache Tomcat Version "$( cd -P "$tomcatDir"; /bin/rpm -qf "$PWD" |sed -e 's/^[^-]*-\([0-9.]*\)-.*$/\1/' )
  fi
  
  writeMessage "Found: $_version"
}

# usage: launchJavaTool <class qualified name> <additional properties> <options>
function launchJavaTool() {
  local _jarFile="$h_libDir/hemera.jar"
  local _className="$1"
  local _additionalProperties="$2"
  local _options="$3"

  # Checks if verbose.
  [ $verbose -eq 0 ] && _additionalProperties="$_additionalProperties -Dhemera.log.noConsole=true"

  # Ensures jar file has been created.
  [ ! -f "$_jarFile" ] && errorMessage "You must build Hemera libraries before using $_className" $ERROR_ENVIRONMENT

  # N.B.: java tools output (standard and error) are append to the logfile; however, some error messages can
  #  be directly printed on output, so output are redirected to logfile too.

  # Launches the tool.
  "$JAVA_HOME/bin/java" -classpath "$_jarFile" \
    -Djava.system.class.loader=hemera.HemeraClassLoader \
    -Dhemera.property.file="$h_configurationFile" \
    -Dhemera.log.file="$h_logFile" $_additionalProperties \
    "$_className" \
    $_options >> "$h_logFile" 2>&1
}
