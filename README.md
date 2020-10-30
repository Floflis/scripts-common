**scripts-common version 2.1.1** [![Codacy Badge](https://api.codacy.com/project/badge/Grade/30f3d380d4c846689aaccfbc87b1a883)](https://www.codacy.com/manual/gitlabRepositories/scripts-common-tests_2?utm_source=gitlab.com&amp;utm_medium=referral&amp;utm_content=bertrand-benoit/scripts-common-tests&amp;utm_campaign=Badge_Grade)
[![pipeline status](https://gitlab.com/bertrand-benoit/scripts-common/badges/master/pipeline.svg)](https://gitlab.com/bertrand-benoit/scripts-common/-/commits/master)
[![coverage report](https://gitlab.com/bertrand-benoit/scripts-common/badges/master/coverage.svg)](https://gitlab.com/bertrand-benoit/scripts-common/-/commits/master)

This is a free common utilities/tool-box for GNU/Bash scripts, you can use for your own scripts.

Compatible with GNU/Bash version **v3.2+**, **v4.0+**, and **v5.0+**, it can be used under various operating systems like: GNU/Linux, Unix, Mac OS, Solaris and Windows.

Thanks to [Gitlab CI/CD](https://docs.gitlab.com/ee/ci/), it is continuously integrated.

----
**Table of contents**

[[_TOC_]]

## Getting Started
**scripts-common** mainly uses GNU/Bash built-in tools for highest compatibility. It provides lots of features:
-   automatic error trap and report (`dumpFuncCall`)
-   logger (`info`, `warning`, `error`, `writeMessage`), with timestamp and category
-   environment check (`checkLocale`, `isRootUser`)
-   path check (`pruneSlash`, `checkPath`, `isRelativePath`, `isAbsolutePath`)
-   advanced path utilities (`buildCompletePath`, `checkBin`, `checkDataFile`, `checkAndFormatPath`)
-   advanced local && global configuration files utilities (`listConfigKeys`, `loadConfigKeyValueList`, `getConfigValue`, `checkAndSetConfig`)
-   version (`isVersionGreater`, `getVersion`, `getDetailedVersion`)
-   time (`initializeStartTime`, `getUptime`, `finalizeStartTime`)
-   pattern matching (`matchesOneOf`, `removeAllSpecifiedPartsFromString`)
-   number \[sequence\] (`isNumber`, `isCompoundedNumber`, `extractNumberSequence`)
-   lines extraction (`getLastLinesFromN`, `getLinesFromNToP`)
-   remote contents (`getURLContents`)
-   PID file (`writePIDFile`, `deletePIDFile`, `getPIDFromFile`, `getProcessNameFromFile`, `isRunningProcess`, `checkAllProcessFromPIDFiles`)
-   daemon (`manageDaemon`, `daemonUsage`, `killChildProcesses`)
-   Third party Tools configuration (`manageJavaHome`, `manageAntHome`, `manageMavenHome`)

## Context
Around 2000, I started writing it for my personal needs, creating lots of scripts at home and at work.

In 2010, I created [Hemera Intelligent System](https://gitlab.com/bertrand-benoit/hemerais/wikis) ([Repository](https://gitlab.com/bertrand-benoit/hemerais)), in which I factorized all my utilities, and developed a more robust version.

In 2019, I extracted the Hemera's utilities part, and enhanced it to get it generic, to share it with everyone. It was the birth of this scripts-common project.

## Installation
### Method 1 (recommended) - Git submodule
You can add this project as [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) of your own Git repository.

You can adapt the name of the branch you want to use (`stable` is the recommended one), for instance with the git URL:
```bash
git submodule add -b stable git@gitlab.com:bertrand-benoit/scripts-common.git
```

If you prefer, you can use the HTTPS URL:
```bash
git submodule add -b stable https://gitlab.com/bertrand-benoit/scripts-common.git
```

Then, add the following lines in all your scripts in which you want to benefit from scripts-common features:
```bash
currentDir=$( dirname "$( command -v "$0" )" )
scriptsCommonUtilities="$currentDir/scripts-common/utilities.sh"
[ ! -f "$scriptsCommonUtilities" ] && echo -e "ERROR: scripts-common utilities not found, you must initialize your git submodule once after you cloned the repository:\ngit submodule init\ngit submodule update" >&2 && exit 1
# shellcheck disable=1090
. "$scriptsCommonUtilities"
```

Tips: whenever you want to get last version of script-common, you can run:
```bash
git submodule update --remote
```

### Method 2 - Clone repository close to yours
Clone this repository in the parent directory of your own repository.

Then, add the following lines in all your scripts in which you want to benefit from scripts-common features:
```bash
currentDir="$( dirname "$( command -v "$0" )" )"
scriptsCommonUtilities="$( dirname "$currentDir" )/scripts-common/utilities.sh"
[ ! -f "$scriptsCommonUtilities" ] && echo -e "ERROR: scripts-common utilities not found, you must install it before using this script (checked path: $scriptsCommonUtilities)" >&2 && exit 1
# shellcheck disable=1090
. "$scriptsCommonUtilities"
```

### Method 3 - Clone repository anywhere
Clone this repository where you want, and define a variable in your `~/.bashrc` file, for instance:
```bash
export SCRIPTS_COMMON_PATH=/complete/path/to/scripts-common/utilities.sh
```

Then, add the following lines in all your scripts in which you want to benefit from scripts-common features:
```bash
# Ensures utilities path has been defined, and sources it.
[ -z "${SCRIPTS_COMMON_PATH:-}" ] && echo "SCRIPTS_COMMON_PATH environment variable must be defined." >&2 && exit 1
[ ! -f "$SCRIPTS_COMMON_PATH" ] && echo -e "ERROR: scripts-common utilities not found, you must install it before using this script or adapt your SCRIPTS_COMMON_PATH environment variable (checked path: $SCRIPTS_COMMON_PATH)" >&2 && exit 1
# shellcheck disable=1090
. "$SCRIPTS_COMMON_PATH"
```

## Usage
### Environment variables
One of the strength of scripts-common is to be 100% autonomous.

You do NOT need to define any variable, and can stick on default configuration.

But if you want to tune scripts-common, there are lots of optional variables you can define either before sourcing the `utilities.sh`, or for any further instructions.

-   **BSC_ROOT_DIR**               `<path>`  root directory to consider when performing various check
-   **BSC_TMP_DIR**                `<path>`  temporary directory where various dump files are created
-   **BSC_PID_DIR**                `<path>`  directory where PID files are created to manage daemon feature
-   **BSC_CONFIG_FILE**            `<path>`  path of configuration file to consider
-   **BSC_GLOBAL_CONFIG_FILE**     `<path>`  path of GLOBAL configuration file to consider
-   **BSC_DISABLE_ERROR_TRAP**       `0|1`   disable TRAP on error (recommended only for Tests project where assert leads to 'error')
-   **BSC_DEBUG_UTILITIES**          `0|1`   enable Debug mode (not recommended in production)
-   **BSC_FORCE_COMPAT_MODE**        `0|1`   enable compatibility mode (not recommended in production)
-   **BSC_VERBOSE**                  `0|1`   enable Verbose mode, showing INFO messages (not recommended in production)
-   **BSC_CATEGORY**             `<string>`  the category which prepends all messages
-   **BSC_LOG_CONSOLE_OFF**          `0|1`   disable message output on console
-   **BSC_LOG_FILE**               `<path>`  path of the log file
-   **BSC_MODE_CHECK_CONFIG**        `0|1`   check ALL configuration and then quit (useful to check all the configuration you want, +/- like a dry run)
-   **BSC_DAEMON_STOP_TIMEOUT** `<integer>`  timeout (in seconds) before killing a daemon process after stop request

N.B.:
-   when a configuration element is not found in **BSC_CONFIG_FILE**, system checks the **BSC_GLOBAL_CONFIG_FILE**
-   when using `checkAndSetConfig` function, you can get result in **BSC_LAST_READ_CONFIG** variable (will be set to **$BSC_CONFIG_NOT_FOUND** if not existing)
-   when using `listConfigKeys` or `loadConfigKeyValueList` functions, you can get result in **BSC_LAST_READ_CONFIG_KEY_VALUE_LIST** variable

### Features documentation
In addition to this full documentation, and you can take inspiration from [Tests](https://gitlab.com/bertrand-benoit/scripts-common-tests/-/blob/master/tests.sh) which cover all features.

#### Automatic error trap and report
By default, as soon as you source scripts-common **utilities.sh**, system configure the shell to report any error (including usage of not set variables), and configure a trap on [ERR](https://www.gnu.org/software/bash/manual/html_node/Signals.html) signal to call `dumpFuncCall` function which shows all the stack causing the error.

Although it is not recommended, you can disable this behaviour, setting **BSC_DISABLE_ERROR_TRAP** variable to **1** before sourcing scripts-common **utilities.sh**.

#### Logger
##### Logger configuration
All messages are timestamped, and prefixed by the value of **BSC_CATEGORY** variable.
You can change this value at any time, along your script.

By default, system will create a dedicated timestamped log file.
You can define **BSC_LOG_FILE** variable with path of your choice to easily manage corresponding log file.

By default, system will log on console, and write in the log file.
You can define **BSC_LOG_CONSOLE_OFF** variable to **1** to disable logging on console (messages are still written in the log file).

##### Debug/informative messages
To log an **informative/debug** message:
```bash
info "This is an informative/debug message"
```

By default, informative/debug messages are neither written on console, or in log file.
You can set **BSC_VERBOSE** variable to **1** to change this behaviour.

##### Message
To log a message:
```bash
writeMessage "This is a simple message ..."
```

In some situation, you may want to use `writeMessageSL` to stay on the "same line", and then print a result.
```bash
writeMessageSL "Loading map of the whole galaxy ... "
if [ $( shuf -n 1 -i 0-1 ) -eq 1 ]; then
  echo "successfully done"
else
  echo "failed"
fi
```

##### Report Warning
To log a **warning** message:
```bash
warning "This is a warning"
```

##### Report Error (and exit)
To log an **error** message:
```bash
errorMessage "This is a fatal error"
```

By default, script aborts after error reporting, with **$BSC_ERROR_DEFAULT** exit status.
You can override this behaviour specifying the exit you want.
Using a `-1` exit status (not recommended in production), you disable the exit, and the script will keep on after error reporting.

```bash
errorMessage "This is an error with recovery" -1
```

#### Environment check
##### Root user
If you want to ensure the script is not launched as root:
```bash
if isRootUser; then
  errorMessage "This script should not be launched with root user."
fi
```

At the opposite, if you want to ensure current is root:
```bash
if ! isRootUser; then
  errorMessage "This script must be launched with root user."
fi
```

##### Locale
To ensure **LANG** environment variable is:
-   defined to use UTF-8 encoding characters (whatever the language)
-   matching an installed locale on your operating system

You can use the `checkLocale` feature. It performs all these checks and informs about issues.
In case checks fail, it defaults to `en_US.UTF-8`.

Then you can use the following instructions:
```bash
if ! checkLocale; then
 warning "You need to properly configured locale '$LANG', and install it on your system."
fi
```

You may prefer a short form:
```bash
! checkLocale && warning "You need to properly configured locale '$LANG', and install it on your system."
```

In some situation, you may check other locale is installed in the operating system, you can easily perform the check defining yourself the LANG environment variable for the context of the instruction:
```bash
! LANG=en_GB.UTF-8 checkLocale && warning "It is recommended to install the 'en_GB.UTF-8' locale on your system."
```

#### Advanced path utilities
##### Path check
You can check if a path exists (either a file or a directory):
```bash
checkPath "$myPath" || errorMessage "Path '$myPath' should exist. Create it and restart this script."
```

You can easily check if a path is relative or absolute (starting with a '/' character):
```bash
if isRelativePath "$myPath"; then
  writeMessage "Specified path '$myPath' is relative, building complete path ..."
fi

if isAbsolutePath "$myPath"; then
  writeMessage "Path '$myPath' is absolute, contrary to the truth ..."
fi
```

##### Check binary or Data availability
To ensure your script(s) will work, you can easily add safe-guard to ensure required binary(ies) are installed and available in path:
```bash
checkBin jq || errorMessage "This tool requires jq. Install it please, and then run this tool again."
checkBin pdftotext || errorMessage "This tool requires pdftotext. Install it please, and then run this tool again."
```

In the same way, you can check if some Data file are available before trying to work on them:
```bash
checkDataFile "/usr/share/doc/myApp/myApp.rules" || errorMessage "Unable to find Data file (See documentation). Create it please, and then run this tool again."
checkDataFile "$BSC_ROOT_DIR/myApp/myApp.rules" || errorMessage "Unable to find Data file (See documentation). Create it please, and then run this tool again."
```

##### Build complete path
You can easily prune ending slash of any path:
```bash
myPath=$( pruneSlash "$myRawPath" )
```

To get a **complete** path, meaning **pruned** path with **$HOME** substitution (if needed), and optionally prepended with a root directory.
By default, relative path are prepended by **$BSC_ROOT_DIR** environment variable. You can override this behaviour specifying path of your choice.

To get a "complete" path, with default options:
```bash
myCompletePath=$( buildCompletePath "$myRawPath" )
```

To get a "complete" path, without prepending:
```bash
myCompletePath=$( buildCompletePath "$myRawPath" 0 )
```

To get a "complete" path, specifying path to prepend if needed:
```bash
myCompletePath=$( buildCompletePath "$myRawPath" 1 "$myRootDirectory" )
```

##### Check and format several paths
The `checkAndFormatPath` function allows working on several paths at once, using the `buildCompletePath` function explained just before.

It is very interesting to process a list of paths (for instance, defined with configuration file feature), to create a list of pruned, formatted, absolute paths.
For instance, it can then be used to update **PATH** environment variable.

```bash
pathListToCheckAndFormat="my/sub/directory:~/directory/relative/to/my/home:some/directory/with/wildcards*"
pathList=$( checkAndFormatPath "$pathListToCheckAndFormat" )
```

By default, like for `buildCompletePath` function which is internally used, relative path are prepended by **$BSC_ROOT_DIR** environment variable. You can override this behaviour specifying path of your choice:

```bash
myRootDir="/opt/my/app"
pathListToCheckAndFormat="my/sub/directory:~/directory/relative/to/my/home:some/directory/with/wildcards*"
pathList=$( checkAndFormatPath "$pathListToCheckAndFormat" "$myRootDir" )
```

#### Advanced configuration files
**scripts-common** provides a powerful configuration files feature, with global and user configuration file notions.

This feature can work without any configuration, by default:
-   it considers global file as **/etc/\<script name without extension\>.conf**
-   it considers user file as **\<your home directory\>/.config/\<script name without extension\>.conf**

You can define **BSC_GLOBAL_CONFIG_FILE** and/or **BSC_CONFIG_FILE** variables to define your own global and/or user configuration files path.

When using with configuration files feature, system loads global configuration if any, and then merge with user configuration if any.
In case of duplicate configuration key, the user configuration overrides the global one.

Any configuration file can contain:
-   `<key1>=<value2>` formatted line, defining a key/value pair
-   comment line starting with '#' character
-   empty line

A key, is usually compounded of alphanumeric characters. Dot are allowed.

For instance, this is a legal configuration file:
```bash
# Default options values.
options.default.showAllNumber=1
options.default.color=1

# List of regular expressions of parts to remove from file name,
#  separated by | character.
# These regular expressions are used with sed, with -E option,
#  and case-insensitive.
# You can check the man of sed for more information about writing such expressions.
patterns.removeMatchingParts="^[0-9][0-9]*_|[(.[][12][90][0-9][0-9][].)]|[([][0-9][0-9]*\/[0-9][0-9]*\/[12][90][0-9][0-9][])]"
```

##### List/load available configuration keys
To list all available configuration keys (system will load global and/or user configuration files like described earlier):
```bash
writeMessage "$( listConfigKeys )"
```

To load available configuration keys in a GNU/Bash array (recommended):
```bash
IFS= read -r -a readCompleteConfigKeyList <<< "$( listConfigKeys )"
writeMessage "${readCompleteConfigKeyList[@]}"
```

##### List/load available configuration key/value pairs
You can use the `loadConfigKeyValueList` function, to load configuration key/value pairs in a GNU/Bash associative array, which will be stored in **BSC_LAST_READ_CONFIG_KEY_VALUE_LIST** variable.
The recommended way is to create your own variable with the contents of this variable, after the function call.

Like for previous function, when using this one, system will load global and/or user configuration files like described earlier.

To load **all** available configuration key/value pairs:
```bash
writeMessage "These are the loaded configuration key/value pairs:"
loadConfigKeyValueList
declare -n myLoadedConfig="BSC_LAST_READ_CONFIG_KEY_VALUE_LIST"
for configKey in "${!myLoadedConfig[@]}"; do
  writeMessage "$configKey => ${myLoadedConfig[$configKey]}"
done
```

This function allows to filter on some specific wanted keys, for instance to load available configuration key/value pairs, whose key started by **my.specific.config**:
```bash
writeMessage "These are the loaded configuration key/value pairs:"
loadConfigKeyValueList "my.specific.config"
declare -n myLoadedConfig="BSC_LAST_READ_CONFIG_KEY_VALUE_LIST"
for configKey in "${!myLoadedConfig[@]}"; do
  writeMessage "$configKey => ${myLoadedConfig[$configKey]}"
done
```

In addition, this function allows to automatically remove part of key name, while loading specific configuration.
It is very useful to get a ready to use list for your algorithm.

To get a complete concrete sample, you can check documentation of my [bankAccountReportToQIF](https://gitlab.com/bertrand-benoit/bankAccountReportToQIF#user-configuration-file-sample) tool.
Among others things, there are lots of "account mapping" configuration (prefixed by **map.account**), which needs to be used directly when parsing accounting report document.

To perform this operation, loading only configuration key/value pairs whose key starts with **map.account.**, and with key names without the starting "map.account." part:
```bash
writeMessage "These are the loaded configuration key/value pairs:"
loadConfigKeyValueList "map[.]account[.].*" "map[.]account[.]"
declare -n myLoadedConfig="BSC_LAST_READ_CONFIG_KEY_VALUE_LIST"
for configKey in "${!myLoadedConfig[@]}"; do
  writeMessage "$configKey => ${myLoadedConfig[$configKey]}"
done
```

N.B.: both arguments of the `loadConfigKeyValueList` function are used with [GNU/Bash Shell parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) so you can go further with them.

For instance, to load any configuration whose key contains **account**, and remove **map.** if any in their names:
```bash
loadConfigKeyValueList ".*account.*" "map[.]"
```

##### Check and get specific configuration key/value pair
If you want to get a configuration value with almost no control (not recommended), you can use the simple `getConfigValue` function (which is used internally).

For instance:
```bash
myConfigValue=$( getConfigValue "my.config.key" )
```

It is recommended to use the `checkAndSetConfig` powerful function which uses lots of internal functions to get the value, check it, check its kind (path, binary, option, data) according to your parameters.

By default, when checking a configuration element, system exits on error if is not found. It is a very powerful safe-guard to ensure your script will perfectly work.

For any reason (e.g. special option checking all configuration to produce a complete report), you can define **BSC_MODE_CHECK_CONFIG** variable to 1 to allow system to keep on even if configuration element doesn't exist.

When using the `checkAndSetConfig` function, these are the various supported configuration types, you can specify:
-   **$BSC_CONFIG_TYPE_OPTION**: no more check on value
-   **$BSC_CONFIG_TYPE_PATH**: challenge the value to be an existing path, using the `checkPath` function (see dedicated information earlier in this documentation)
-   **$BSC_CONFIG_TYPE_DATA**: challenge the value to be an existing data file, using the `checkDataFile` function (see dedicated information earlier in this documentation)
-   **$BSC_CONFIG_TYPE_BIN**: challenge the value to be an available executable, using the `checkBin` function (see dedicated information earlier in this documentation)

Once all controls have been successfully performed, the value is stored in the **$BSC_LAST_READ_CONFIG** variable.

###### Check and get configured Option
For instance, to get the value of a configured option:
```bash
checkAndSetConfig "my.config.key" "$BSC_CONFIG_TYPE_OPTION"
declare -n mySimpleOption="BSC_LAST_READ_CONFIG"
writeMessage "Value of my configured element => $mySimpleOption"
```

###### Check and get configured Path
For instance, to get the value of a configured path, with default option:
```bash
checkAndSetConfig "my.config.key" "$BSC_CONFIG_TYPE_PATH"
declare -n myPath="BSC_LAST_READ_CONFIG"
writeMessage "Value of my configured element => $myPath"
```

For instance, to get the value of a configured path, specifying path to prepend in case of relative path:
```bash
checkAndSetConfig "my.config.key" "$BSC_CONFIG_TYPE_PATH" "$myRootDirectory"
declare -n myPath="BSC_LAST_READ_CONFIG"
writeMessage "Value of my configured element => $myPath"
```

In case you tolerate the path does not exist yet (for instance if you want to create it yourself), you can specify an additional parameter (it is consider only for **$BSC_CONFIG_TYPE_PATH** type):
```bash
checkAndSetConfig "my.config.key" "$BSC_CONFIG_TYPE_PATH" "$myRootDirectory" 0
declare -n myPath="BSC_LAST_READ_CONFIG"
writeMessage "Value of my configured element => $myPath"
```

###### Check and get configured Data file
For instance, to get the value of a configured Data file, with default option:
```bash
checkAndSetConfig "my.config.key" "$BSC_CONFIG_TYPE_DATA"
declare -n myDataFile="BSC_LAST_READ_CONFIG"
writeMessage "Value of my configured element => $myDataFile"
```

For instance, to get the value of a configured Data file, specifying path to prepend in case of relative path:
```bash
checkAndSetConfig "my.config.key" "$BSC_CONFIG_TYPE_DATA" "$myRootDirectory"
declare -n myDataFile="BSC_LAST_READ_CONFIG"
writeMessage "Value of my configured element => $myDataFile"
```

###### Check and get configured Binary/Executable
For instance, to get the value of a configured Binary, with default option:
```bash
checkAndSetConfig "my.config.key" "$BSC_CONFIG_TYPE_BIN"
declare -n myExecutable="BSC_LAST_READ_CONFIG"
writeMessage "Value of my configured element => $myExecutable"
```

For instance, to get the value of a configured Binary, specifying path to prepend in case of relative path:
```bash
checkAndSetConfig "my.config.key" "$BSC_CONFIG_TYPE_BIN" "$myRootDirectory"
declare -n myExecutable="BSC_LAST_READ_CONFIG"
writeMessage "Value of my configured element => $myExecutable"
```

#### Version
##### Extract simple version from a file
To extract the version information from the first line of a file like Changelog, NEWS, README.md, etc ...
```bash
version=$( getVersion "/path/to/my/file" )
```

Sometimes, you want to define a default version value (for instance when in first version of you project, the corresponding file did not exist yet):
```bash
version=$( getVersion "/path/to/my/file" "0.1.6" )
```

##### Extract commit hash from Git repository
To create a detailed version, adding the last commit hash or you git repository, you can use these instructions:
```bash
version=$( getVersion "/path/to/my/file" "0.1.6" )
detailedVersion=$( getDetailedVersion "$version" "/path/to/my/repository" )
```

You then obtain something like
> 0.1.6 (commit beaec68 of 2020-06-17)

##### Compare two versions
You can compare two versions with `isVersionGreater` feature. It implements a safe-guard to ensure they match [SemVer](http://semver.org/) format.

For instance to perform instructions, if `$version1` is greater than `$version2`:
```bash
if isVersionGreater "$version1" "$version2"; then
  # Specific instructions ...
fi
```

By default, the function performs a "is greater than" check, if you want a "is greater than or equal" check, you can define the third parameter to **1**:
```bash
isVersionGreater "1.2.3.4" "1.2.3.4" 1 && writeMessage "Equality check OK"
```

#### Time
##### Formatted Datetime
To get a formatted date\[time\], you can use the following function, specifying the format of you choice, for instance:
```bash
myDateTime=$( getFormattedDatetime '%Y-%m-%d-%H-%M-%S' )
```

This function uses the compatibility system allowing to work even on old GNU/Bash version starting from 3.0.

##### Uptime
To initialize the **uptime** feature:
```bash
initializeStartTime
```

At anytime, you get get **uptime**:
```bash
info "Uptime: $( getUptime )"
```

To stop the feature:
```bash
finalizeStartTime
```

#### Pattern matching
You can easily check if a string matches one pattern (among several) using the `matchesOneOf` function.
The pattern(s) can be specified using a GNU/Bash array, thus in a single instruction, you can check along several patterns.

For instance:
```bash
declare -a patterns=( "[My ]*f?irst[ pattern]*" "[ \t][0-9][0-9]*[ \t]" "^NoThing[ \t]*Void$" )
myValue="anyStringYouWantToCheck"
if matchesOneOf "$myValue" "${patterns[@]}"; then
  writeMessage "Launcher is ready for ignition !"
fi
```

When working on Data, sometimes you need to process it to remove various useless part(s), and work on true Data.

For instance, it is the case of:
-   [bankAccountReportToQIF](https://gitlab.com/bertrand-benoit/bankAccountReportToQIF) which removes various useless information after accounting PDF report file convert
-   [episodesChecker](https://gitlab.com/bertrand-benoit/episodesChecker) when extracting number sequence from files' name

The parts to remove can be specified using a '|' separated list, thus in a single instruction, you can easily remove according to several patterns.
This format is very efficient and allows patterns definition with configuration file feature.

For instance:
```bash
myPatterns="$pattern1|$pattern2|$pattern3"
myValue="anyStringYouWantToProcess"

data=$( removeAllSpecifiedPartsFromString "$myValue" "$myPatterns" )
```

#### Number \[sequence\]
To test if a string is a simple number:
```bash
if ! isNumber "$myValue"; then
  warning "Specified value '$myValue' is not a number. Please read documentation and try again."
fi
```

To test if a string is a compounded number (one or several numbers, a dash, followed by one or several numbers):
```bash
if isCompoundedNumber "$myValue"; then
  writeMessage "Ok, '$myValue' is a compounded number."
fi
```

To extract number sequence from a string:
```bash
numberSequence="$( extractNumberSequence 'LotsOfUselessThings.3.AndSomeMore.myExtension')"       # 3
numberSequence="$( extractNumberSequence 'LotsOfUselessThings.7-9.AndSomeMore.myExtension')"     # 7-9
numberSequence="$( extractNumberSequence 'LotsOfUselessThings.11 à 13.AndSomeMore.myExtension')" # 11-13
numberSequence="$( extractNumberSequence 'LotsOfUselessThings.17 & 19.AndSomeMore.myExtension')" # 17-19
numberSequence="$( extractNumberSequence 'LotsOfUselessThings.29-30.AndSomeMore.myExtension')"   # 29-30
```

#### Lines extraction
You can easily extract last lines of a file, with the **getLastLinesFromN** function.

For instance, to extract the 10 last lines of specified file:
```bash
getLastLinesFromN "/path/to/my/file" "10"
```

You can extract specific lines of a file from one index to another, with the **getLinesFromNToP** function.

For instance, to extract the lines 10 to 20 of specified file:
```bash
getLinesFromNToP "/path/to/my/file" "10" "20"
```

#### Remote contents
To extract a remote contents, you can use the **getURLContents** function.
```bash
getURLContents "https://libraryofbabel.info/search.cgi?find=scripts%20common%20will%20help%20you" "/tmp/contents.html"
```

You can force the User-agent if you need it:
```bash
getURLContents "https://libraryofbabel.info/search.cgi?find=scripts%20common%20will%20help%20you" "/tmp/contents.html" "Mozilla/5.0"
```

#### PID file
To easily manage Daemon, it is recommended to use the advanced Daemon feature (see next documentation part), provided by scripts-common.

Nevertheless, in some situation, you may need to manage PID file yourself, and perform some process running check.

By default, system creates a directory dedicated to store PID files, according to your script name, and timestamp.

You can use the **BSC_PID_DIR** environment variable to specify your own directory (can be interesting to keep the same across several execution of your main script).

##### Create PID file
To create/write/register a PID for the running process:
```bash
myPIDFile="$BSC_PID_DIR/myWonderfulProcess.pid"
myProcessName="$0" # Could be anything else
writePIDFile "$myPIDFile" "$myProcessName"
```

To create/write/register a PID for the third party tool you are going to execute/launch, for instance with `inotifywait`:
```bash
myPIDFile="$BSC_PID_DIR/myWonderfulProcess.pid"
monitorBin="inotifywait"
IFS=' ' read -r -a monitorOptions <<< "-q --format '%f' -e close_write -m /tmp"
writePIDFile "$myPIDFile" "$monitorBin"
exec "$monitorBin" "${monitorOptions[@]}"
```

N.B.:
-   the PID registered is the one of the current process, which corresponds to your script at beginning, but since we use `exec` here, the process "becomes" the launched third party tool, and thus the PID corresponds to it
-   it is why it is important to specify the process name which thus can be different from the parent script

##### Get information from PID file
To get back the PID from the file:
```bash
processPID=$( getPIDFromFile "$myPIDFile" )
```

To get back the process name/path from the file:
```bash
processName=$( getProcessNameFromFile "$myPIDFile" )
```

##### Delete PID file
To delete a PID file:
```bash
deletePIDFile "$myPIDFile"
```

##### Check if process is running, from PID file
To check if a process is running from its PID file:
```bash
if isRunningProcess "$myPIDFile"; then
  writeMessage "The rocket is still moving toward its destination"
fi
```

N.B.: if the process is dead, system will automatically delete the corresponding PID file

##### Check if ALL process are running, from PID directory
If you created several PID files in a directory, you can check ALL process at once (and automatically clean PID file of dead process):
```bash
checkAllProcessFromPIDFiles
```

By default, this function will consider the **$BSC_PID_DIR** PID Directory.

You can specify any other directory:
```bash
checkAllProcessFromPIDFiles "/tmp/myApp/mySpecialPIDDir"
```

#### Daemon
**scripts-common** provides a powerful Daemon feature, allowing precise process management, check, and cleaning.
It uses PID file feature described earlier and some internal functions like `_startProcess`, `_stopProcess` and `_setUpKillChildTrap` which are not intended to be used directly in your script (don't hesitate to [request the feature](https://gitlab.com/bertrand-benoit/scripts-common/issues) if you think it is a good idea).

To fully benefit from this feature, you should follow this "framework" for each of your Daemon script:
-   create a dedicated script, taking inspiration from one of scripts-common [Daemon samples](/misc/)

-   adapt the script to your needs, for instance:
    -   logger category (usually at beginning of your Daemon script)
    -   scripts-common behaviour (usually at beginning of your Daemon script) like verbosity, logging on console, log file ...
    -   (1) use configuration feature to get tool to launch, and its corresponding options
    -   adapt/enhance supported CLI options, and behaviour
    -   (2) write the instructions of your Daemon script (usually at end of your Daemon script)

You have the choice to write a Daemon script:
-   (1) launching a third party tool, with its options, for instance, a monitoring system, a sound recorder, a processor, a downloader, a file system monitor, an e-mail server ...
-   (2) launching its own instructions, once it is "daemonized"

##### Print Daemon usage
At any time, for instance when parsing CLI, or when user specified an '-h' or '--help' option, you can easily print a ready to use Usage help:
```bash
daemonUsage "$myDaemonName"
```

It is very useful if you stick to the proposed Daemon framework, and you don't want to bother writing your own usage.

##### Daemon feature mechanisms
The core of **scripts-common** Daemon feature is implemented in `manageDaemon` function.

You can perform 100% of your Daemon management with this function.

This is the usage of the function:
```bash
manageDaemon <action> <name> <pid file> <process name> [<logFile> <outputFile> [<options>]]
```

| Parameters       | Explanations                                                                                          | Details                                                             |
|------------------|-------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| \<action\>       | available values:                                                                                     |                                                                     |
|                  | $BSC\_DAEMON\_ACTION\_START                                                                           | requests start of the Daemon                                        |
|                  | $BSC\_DAEMON\_ACTION\_STATUS                                                                          | checks the status of the Daemon                                     |
|                  | $BSC\_DAEMON\_ACTION\_STOP                                                                            | stops the Daemon and all its potential child processes              |
|                  | $BSC\_DAEMON\_ACTION\_RUN                                                                             | (internal) (optional) runs instructions of the Daemon script itself |
|                  | $BSC\_DAEMON\_ACTION\_DAEMON                                                                          | (internal) really turns to a Daemon                                 |
|                  |                                                                                                       |                                                                     |
| \<name\>         | name of your Daemon script                                                                            |                                                                     |
| \<pid file\>     | the PID file to use to manage the process which will be "daemonized"                                  |                                                                     |
| \<process name\> | the name/path of the process to launch (can be a third party tool, or the Daemon script itself)       |                                                                     |
| \<logFile\>      | the log file to define with $BSC_LOG_FILE variable (See Logger Feature) in the Daemon process context | only needed if action is $BSC\_DAEMON\_ACTION\_START                |
| \<outputFile\>   | the file in which Daemon output will be redirected                                                    | only needed if action is $BSC\_DAEMON\_ACTION\_START                |
| \<options\>      | Daemon options, MUST be an GNU/Bash array                                                             | only needed if action is $BSC\_DAEMON\_ACTION\_DAEMON               |

Of course, you can directly use this function if you want, but it is strongly recommended to stick to the framework described earlier to benefit from all the potential of this feature.

When requesting Daemon stop:
-   system sends a [TERM](https://www.gnu.org/software/bash/manual/html_node/Signals.html) signal
-   system waits during $BSC_DAEMON_STOP_TIMEOUT seconds
-   system sends a [KILL](https://www.gnu.org/software/bash/manual/html_node/Signals.html) signal if the process is still running

For any reason, when the Daemon process exits (if it naturally ends, or if its stop has been requested):
-   its own [EXIT](https://www.gnu.org/software/bash/manual/html_node/Signals.html) signal is trapped, and `killChildProcesses` function is called to stop all its potential child processes (see documentation below)

##### Daemon launching third party tool
You can start copying this [specific Daemon sample](/misc/daemonScriptLaunchingThirdPartyTool.sh.sample), and follow the framework described earlier.

Your Daemon script can start any third party tool, with any options.

This is the usual Action flow for such Daemon script:

| $BSC\_DAEMON\_ACTION\_START | \-> | $BSC\_DAEMON\_ACTION\_STATUS\* | \-> | $BSC\_DAEMON\_ACTION\_DAEMON \*\* | \-> | $BSC\_DAEMON\_ACTION\_STOP |
| ----- | --- | -------- | --- | ---------- | --- | ---- |

\* $BSC\_DAEMON\_ACTION\_STATUS action can be used at any time, even before start, and after stop actions

\*\* $BSC\_DAEMON\_ACTION\_DAEMON  is internal and must NOT be called directly

##### Daemon launching its own instructions
You can start copying this [specific Daemon sample](/misc/daemonScriptLaunchingItsOwnInstructions.sh.sample), and follow the framework described earlier.

Once the state machine reaches the 'run' status, your own Daemon script instructions will be executed, and you can then perform everything you need.

This is the usual Action flow for such Daemon script:

| $BSC\_DAEMON\_ACTION\_START | \-> | $BSC\_DAEMON\_ACTION\_STATUS\* | \-> | $BSC\_DAEMON\_ACTION\_DAEMON \*\* | \-> | $BSC\_DAEMON\_ACTION\_RUN\*\*\* | \-> | $BSC\_DAEMON\_ACTION\_STOP |
| ----- | --- | -------- | --- | ---------- | --- | --------- | --- | ---- |

\* $BSC\_DAEMON\_ACTION\_STATUS action can be used at any time, even before start, and after stop actions

\*\* $BSC\_DAEMON\_ACTION\_DAEMON  is internal and must NOT be called directly

\*\*\* $BSC\_DAEMON\_ACTION\_RUN is internal and must NOT be called directly

##### Daemon - kill all child processes
When requesting stop of a Daemon script (either it launched a third party tool, or launched its own instructions), system used internally the `killChildProcesses` function.

It allows to recursively send a [HUP](https://www.gnu.org/software/bash/manual/html_node/Signals.html) signal to ALL child processes of the specified parent PID.

It is very precious to:
-   avoid resources hanging
-   free CPU and memory resources, and avoid memory leak
-   clean processes, and avoid idle/zombies ones

You can (but do not need, if you use the Daemon feature) use this function directly:
```bash
killChildProcesses "$myParentProcessPID" 1
```

For instance, to kill all child processes started by your current script (not recommended), you can use:
```bash
killChildProcesses "$$" 1
```

#### Third party Tools configuration
The third party tools configuration is a powerful feature based on configuration file, and path management features.

There are several possible situations:
-   the third party tool environment variable is already defined (e.g. **$JAVA_HOME** for Java)

-   if not defined:
    -   the system checks the corresponding configuration element in local and global configuration files (e.g. **environment.java.home** for Java)
    -   if defined, ensures the path exists, and is a directory
    -   then sets the environment variable

-   from environment variable, checks one or several binaries which should be under corresponding directory (e.g. **java** and **javac** for Java)

-   if all checks are successful => configuration is completed and valid, the Third-party tool can be used

-   system informs about version of thus configured third party tool

In any other situation (badly defined environment variable, bad path, binaries not found ...), the system reports a precise error.

Like explained in the configuration feature part, by default the system exits on error message when checking configuration.

So, to add a safe-guard in your script, to ensure third party tool is configured, you can simply call the corresponding function (e.g. for Java and Maven):
```bash
manageJavaHome
manageMavenHome

# Ok, configuration is OK, script can safely keep on
```

If you want to implement a complete configuration check (for instance, to report all potential errors and then exits), you can add some specific error message:
```bash
BSC_MODE_CHECK_CONFIG=1
if ! manageJavaHome; then
  errorMessage "Unable to configure third-party tool 'Java'. Please either define 'JAVA_HOME' environment variable, or set properly 'environment.java.home' in your configuration file."
fi
```

N.B.: there are plenty of interesting Third party tools, if you need scripts-common to support some more, please, [request the feature](https://gitlab.com/bertrand-benoit/scripts-common/issues).

## Contributing
Don't hesitate to [contribute](https://opensource.guide/how-to-contribute/) or to contact me if you want to improve the project.
You can [report issues or request features](https://gitlab.com/bertrand-benoit/scripts-common/issues) and propose [merge requests](https://gitlab.com/bertrand-benoit/scripts-common/merge_requests).

## Versioning
The versioning scheme we use is [SemVer](http://semver.org/).

## Authors
[Bertrand BENOIT](mailto:contact@bertrand-benoit.net)

## License
This project is under the GPLv3 License - see the [LICENSE](LICENSE) file for details
