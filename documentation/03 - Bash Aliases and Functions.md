# Bash aliases and functions to speed up setup and day-to-day tasks
> **Note:** All items between square brackets, [...], describe arguments or variables to be provided. For instance, [FILE] requires a file name or path to be provided, [STRING] requires text or a string of characters etc.
## Aliases
- ll - usually standard and available in modern Ubuntu releases, lists all files and directories, including hidden ones, with details
- mkexec [FILE]- make a file (argument) executable
- aup - update without restart, running apt update, upgrade and dist-upgrade as well as updating snaps
- aupr - same as aup, quicker, minus snap update but with restart
-catlog [STRING] - tail the last 100 lines of var syslog and filter for text argument with grep
- nbrc - edit the .bashrc with nano

## Functions
- gcom [MESSAGE] - performs git commit with a time-stamped (format: YYYYmmddHHMM) message string [MESSAGE]. If no message is provided, the timestamp and the default message "Work in progress". Shortens and provides a default for `git commit -am "YYYYmmddHHMM - Details"`
- gtag [VERSION] [MESSAGE] - performs a `git tag` on the current repository. Version number [VERSION] should be provided, as `v0.0.0` or simply `0.0.0`, changing the numbers to match your version. [MESSAGE] string is optional. Analogous to `git tag -a v1.4 -m "my version"

