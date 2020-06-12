# scripts-common version 2.1.0
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/30f3d380d4c846689aaccfbc87b1a883)](https://www.codacy.com/manual/gitlabRepositories/scripts-common-tests_2?utm_source=gitlab.com&amp;utm_medium=referral&amp;utm_content=bertrand-benoit/scripts-common-tests&amp;utm_campaign=Badge_Grade)
[![pipeline status](https://gitlab.com/bertrand-benoit/scripts-common/badges/master/pipeline.svg)](https://gitlab.com/bertrand-benoit/scripts-common/-/commits/master)
[![coverage report](https://gitlab.com/bertrand-benoit/scripts-common/badges/master/coverage.svg)](https://gitlab.com/bertrand-benoit/scripts-common/-/commits/master)

This is a free common utilities/tool-box for GNU/Bash scripts, you can use for your own scripts.

## Getting Started
**scripts-common** provides lots of features, using mainly GNU/Bash built-in tools, like:
-   logger (writeMessage, info, warning, error), with timestamp and category
-   environment check and utilities (locale, isRoot, LSB)
-   path check and management (data file, directory, executable)
-   configuration file management (local configuration file, global configuration file, check and set configuration)
-   version check (isVersionGreater)
-   start/stop/up time
-   pattern matching (including isNumber, isDate ...)
-   extract lines from a file (from N, or between N and P)
-   PID file management
-   daemon start/pause/stop
-   Third party PATH management feature (Java, Ant ...)

## Context
Around 2000, I started writing it for my personal needs, creating lots of scripts at home and at work.

In 2010, I created [Hemera Intelligent System](https://gitlab.com/bertrand-benoit/hemerais/wikis) ([Repository](https://gitlab.com/bertrand-benoit/hemerais)), in which I factorized all my utilities, and developed more robust version.

In 2019, I extracted the Hemera's utilities part, and enhanced it to get it generic, to share it with everyone.

## Usage
In all the following methods, you just need to source the utilities file.
```bash
source <path to define>/scripts-common/utilities.sh
```

### Method 1 - Git submodule
You can add this project as [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) of your own Git repository.

You can adapt the name of the branch you want to use (`stable` is the recommended one):
```bash
git submodule add -b stable git@gitlab.com:bertrand-benoit/scripts-common.git
```

And then update your script to use it (e.g. if this script is in the root directory of your repository):
```bash
currentDir=$( dirname "$( command -v "$0" )" )
. "$currentDir/scripts-common/utilities.sh"
```

#### Update submodule
Whenever you want to get last version of script-commons, you can run:
```
git submodule update --remote
```


### Method 2 - Clone repository close to yours
Clone this repository in the parent directory of your own repository.

You can then source the utilities this way:
```bash
currentDir="$( dirname "$( command -v "$0" )" )"
source "$( dirname "$currentDir" )/scripts-common/utilities.sh"
```

### Method 3 - Clone repository anywhere
Clone this repository where you want, and define a variable in your `~/.bashrc` file, for instance:
```bash
export UTILITIES_PATH=/complete/path/to/scripts-common/utilities.sh
```

Then, in your script, you just need to use this variable:
```bash
source "$UTILITIES_PATH"
```

## Environment
There are some optional variables you can define before sourcing the `utilities.sh`, to tune the system to your needs.

-   **ROOT_DIR**           `<path>`  root directory to consider when performing various check
-   **TMP_DIR**            `<path>`  temporary directory where various dump files will be created
-   **PID_DIR**            `<path>`  directory where PID files will be created to manage daemon feature
-   **CONFIG_FILE**        `<path>`  path of configuration file to consider
-   **GLOBAL_CONFIG_FILE** `<path>`  path of GLOBAL configuration file to consider (configuration element will be checked in this one, if NOT found in the configuration file)
-   **DEBUG_UTILITIES**              `0|1`  activate debug message (not recommended in production)
-   **VERBOSE**                      `0|1`  activate info/debug message
-   **CATEGORY**                 `<string>` the category which prepends all messages
-   **LOG_CONSOLE_OFF**              `0|1`  disable message output on console
-   **LOG_FILE**                   `<path>` path of the log file
-   **LOG_FILE_APPEND_MODE**         `0|1`  activate append mode, instead of override one
-   **MODE_CHECK_CONFIG**   `0|1`  check ALL configuration and then quit (useful to check all the configuration you want, +/- like a dry run)

N.B.: when using `checkAndSetConfig` function, you can get back the corresponding configuration in **LAST_READ_CONFIG** variable (if it has NOT been found, it is set to *$CONFIG_NOT_FOUND*).

## Contributing
Don't hesitate to [contribute](https://opensource.guide/how-to-contribute/) or to contact me if you want to improve the project.
You can [report issues or request features](https://gitlab.com/bertrand-benoit/scripts-common/issues) and propose [merge requests](https://gitlab.com/bertrand-benoit/scripts-common/merge_requests).

## Versioning
The versioning scheme we use is [SemVer](http://semver.org/).

## Authors
[Bertrand BENOIT](mailto:contact@bertrand-benoit.net)

## License
This project is under the GPLv3 License - see the [LICENSE](LICENSE) file for details
