# FONT COLORS
RED='\033[1;31m' # Error
YELLOW='\033[1;33m' # Warning
CYAN='\033[0;36m' # In progress
GREEN='\033[1;32m' # Success
NC='\033[0m' # No color

# VARIABLES
USER_DIRS=("logs" "repos" "setup")
USER_FILES=("/logs/init.log" "/logs/errors.log")
BASE_DIR="$HOME"
PREV_DIR="$(pwd)"
WARNINGS=()
ERRORS=()

# FUNCTIONS
assert() { # Test function requiring 3 arguments: 1. a string describing the test; 2. the expected result string or number; 3. the actual outcome of a function or other output from $(). Prints expected and result on failure, clipping both to their first 20 characters.
  local DESCRIPTION=$1
  local EXPECTED=$2
  local RESULT=$3
  local CHAR_LIMIT=50
  if [[ ${#} -ne 3 ]]; then
    echo -e "\033[1;31mThe number of arguments provided to the assert function should be 3\033[0m" >&2
    return 1
  fi
  if [[ "$RESULT" != $EXPECTED ]]; then
    if [[ "${#RESULT}" -gt "$CHAR_LIMIT" ]]; then
      RESULT="${RESULT:0:$CHAR_LIMIT} (...)"
    fi
    if [[ "${#EXPECTED}" -gt "$CHAR_LIMIT" ]]; then
      EXPECTED="${EXPECTED:0:$CHAR_LIMIT} (...)"
    fi
    echo -e "\033[1;31mTEST: \033[0m${DESCRIPTION}: \033[1;31mFailed\033[0m"
    echo -e "EXPECTED:\t${EXPECTED}"
    echo -e "RESULT:\t\t${RESULT}"
    return 0
  fi
  echo -e "\033[1;32mTEST: \033[0m${DESCRIPTION}: \033[1;32mPassed\033[0m"
}

enable_bash_customisations() { # Check .bashrc and source from customisation files
  local BASHRC_FILE="$HOME/.bashrc"
  local INSERT=""
  if [[ -f "$BASHRC_FILE" ]]; then
    if [[ ! -z $(cat "$BASHRC_FILE"|grep "source $HOME/setup/bash_aliases_and_functions") ]]; then
      echo -e "${YELLOW}Bash customisations found${NC}"
      return 0
    fi
    if [[ "$(ask_confirmation 'Install bash aliases and helper functions to your .bashrc?')" == "y" ]]; then
      echo
      INSERT="\n## Bash customisations (v0.1): aliases and functions\nsource $HOME/setup/bash_aliases_and_functions"
      echo -e "$INSERT" >> "$BASHRC_FILE"
    else
      echo
      return 0
    fi
  fi
}

set_base_dir() { # Set base directory to either $HOME (production) or test_home (development)
  if [[ ! $(basename $PWD) == "uboontup" ]]; then
    BASE_DIR=$PWD/test_home;
  fi
  cd $BASE_DIR
}

critical_exit() {
  
}

check_base_dir() { # Check if pwd is correct directory
  if [[ ! $(pwd) == $BASE_DIR ]]; then
    # else echo error, log to syslog and exit
    
  fi
}

check_base_dir_write() {
  NOW_STR="$(date_string)"
  echo "before temp"
  ls
  mkdir "$NOW_STR""_folder"
  echo "after temp"
  ls
  echo "This is a test file"|tee "$NOW_STR""_folder/""$NOW_STR""_file.txt"
  if [[ -d "$NOW_STR""_folder" && -f "$NOW_STR""_folder/""$NOW_STR""_file.txt" ]]; then
    echo -e "${GREEN}Directory $NOW_STR""_folder is writable${NC}"
    rm "$NOW_STR""_folder/""$NOW_STR""_file"
    if [[ $? -ne 0 ]]; then
      echo "ERROR!!!"
      exit 1
    else
      echo "ALL IS VELL"
    fi
    rm -r "$NOW_STR""_folder"
    if [[ $? -ne 0 ]]; then
      echo "ERROR!!!"
      exit 1
    else
      echo "ALL IS VELL"
    fi
#     echo after rm
#     ls
#     # if [[ -d "$NOW_STR""_folder" ]]; then
#     #   echo -e "${YELLOW}Temporary files could not be removed${NC}"
#     #   echo
#     #   if [[ "$(ask_confirmation 'Do you want to proceed with installation anyway? Some items may not install correctly.')" != "y" ]]; then
#     #     echo "${RED}Aborting installation. Goodbye!${NC}"
#     #     exit 1
#     #   fi
#     # fi
#   else
#     ERROR_MESSAGE="The base directory is not writable"
#     ERRORS+=($ERROR_MESSAGE)
#     echo -e "${RED}ERRORS:${NC}"
#     printf "%s\n" "${ERRORS[@]}"
#     logger -t $(basename "$0") -p user.err $ERROR_MESSAGE
#     exit 1
  else
    ERROR_MESSAGE="The installation directory cannot be written to. Please verify that you have permission to continue or try again later."
    ERRORS+=("$ERROR_MESSAGE")
    echo -e "${RED}ERRORS:${NC}"
    printf "%s\n" "${ERRORS[@]}"
    logger -t $(basename "$0") -p user.err $ERROR_MESSAGE
    exit 1
  fi
}

date_string() {
  echo $(date +%Y%m%d%H%M%S)
}

ask_confirmation() {
  if [[ -z "$1" ]]; then
    PROMPT="Confirm (y/n): ";
  else
    PROMPT="$1"$'\nConfirm (y/n): '
  fi
  read -p "$PROMPT" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      printf "y";
    else
      printf "n";
  fi
}

# enable_bash_customisations
# Execute actions
set_base_dir
check_base_dir
check_base_dir_write
# check_and_create_dir "${USER_DIRS[@]}"
# backup_folder "test" "bkp_"


cd $PREV_DIR
if [[ $PREV_DIR == $(pwd) ]]; then
  echo -e "${GREEN}Thank you for using Uboontup. We hope you had a nice experience.${NC}"
  exit 0;
else
  echo -e "${RED}We are sorry, but something went wrong.${NC} File an issue or contact us on ${YELLOW}Github${NC} for further assistance."
  exit 1
fi