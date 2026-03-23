#!/bin/bash
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
ERRORS=()
WARNINGS=()

# FUNCTIONS
set_base_dir() { # Set base directory to either $HOME (production) or test_home (development)
  if [[ ! $(basename $PWD) == "uboontup" ]]; then
    BASE_DIR=$PWD/test_home;
  fi
  cd $BASE_DIR
}

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

check_base_dir() { # Check if pwd is correct directory
  local DUMMIES=()
  if [[ ! $(pwd) == $BASE_DIR ]]; then
    # else echo error, log to syslog and exit
    ERROR_MESSAGE="The installation directory cannot be accessed. Please verify that you have permission to continue or try again later"
    ERROR+=($ERROR_MESSAGE)
    echo "$ERROR_MESSAGE"
    logger -t $(basename "$0") -p user.err $ERROR_MESSAGE
    exit 1
  else
    NOW_STR="$(date_string)"
    mkdir "$NOW_STR""_folder"
    echo "This is a test file"|tee "$NOW_STR""_folder/""$NOW_STR""_file.txt"
    
    ## to check if current directory is writeable
    ## create and delete dummy folder
    ## create and delete dummy file
  fi
  
}

# FUNCTION DEFINITIONS
# RETURN A TIMESTAMP - DATE STRING WITH TIME
date_string() {
  echo $(date +%Y%m%d%H%M%S)
}

# ASK FOR CONFIRMATION
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

# CHECK AND CREATE REQUIRED DIRECTORIES
check_and_create_dir () {
  for user_dir in "$@"; do
    if [[ -d "$BASE_DIR/$user_dir" ]]; then
      echo -e "$BASE_DIR/$user_dir ${RED}already exits${NC}"|tee -a $BASE_DIR/logs/setup_00_init.log
      if [[ $(ask_confirmation "Back up folder contents?") == 'y' ]]; then
        echo
        BKP_STR="bkp_$(date_string)"
        echo "$BASE_DIR"
        echo "$BKP_STR"
        mkdir "$BASE_DIR/$BKP_STR"
        mv -i "$BASE_DIR/$user_dir/*" "$BASE_DIR/$BKP_STR"
        mv -i "$BASE_DIR/$BKP_STR" "$BASE_DIR/$user_dir/"
      else
        echo
      fi
    else
      mkdir "$BASE_DIR/$user_dir"
      echo -e "$BASE_DIR/$user_dir ${GREEN}created${NC}"
    fi
  done
}

# Parse options using getops
parse_opts() {
  local OPTIND=1
  local opt
  local rem_args=()
  local a=false

  while getopts ":vf:ar:" opt; do
    case "$opt" in
      v)
        echo "Verbose mode (-$opt)"
        ;;
      f)
        echo "File required (-$opt): $OPTARG"
        ;;
      a)
        a=true
        echo "All mode (-a): $a"
        ;;
      r)
        echo "Recurse files (-r): $OPTARG"
        ;;
      \?) # invalid options
        echo "Invalid option: -$OPTARG" >&2
        ;;
      :) # missing arguments
        echo "Option -$OPTARG requires an argument" >&2
        ;;
    esac
  done
  shift $((OPTIND-1))

  # store and print remaining arguments
  if [[ ! -z "${@}" ]]; then
    rem_args=("${@}")
    echo "Remaining args: ${rem_args[@]}"
  fi
}

# BACK UP A FOLDER WITH POSSIBILITY TO EXCLUDE PREFIX
backup_folder() {
  local OPTIND=1
  local opt
  local rem_args=()
  local a=false
  local EXCLUDE

  while getopts ":e:h" opt; do
    case "$opt" in
      h) # help and usage
        echo "backup_folder -e \"[EXCLUDE PATTERN] [FOLDER]\""
        echo "e.g."
        echo "backup_folder -e \"*BKP*\" ./test_home"
        ;;
      e) # save exclude pattern to variable
        EXCLUDE="$OPTARG"
        ;;
      \?) # invalid options
        echo "Invalid option: -$OPTARG" >&2
        return 1
        ;;
      :) # missing arguments
        echo "Option -$OPTARG requires an argument" >&2
        return 1
        ;;
    esac
  done
  shift $((OPTIND-1))

  # store and print remaining arguments
  if [[ ! -z "${@}" ]]; then
    rem_args=("${@}")
  else
    echo "${ERR}"
  fi
  if [[ ! -z $2 ]]; then
    EXCLUDE="$2*"
  else
    EXCLUDE=""
  fi

  # list backup folder found

  # force excluded backup
  echo "$1"
  ls "$1"
  if [[ -d "$1" ]]; then
    TO_BKP=$(ls -A -I "$EXCLUDE" "$1")
    echo "${TO_BKP[@]}"
    return 0
  else
    echo -e "${RED}Folder does not exist${NC}"
    return 1
  fi
}

check_and_create_file() {
  echo test
}

detect_version () {
  local VERSION
  local MESSAGE
  if [[ "$1" =~ ^[v]?[0-9]+\.[0-9]+\.[0-9]+[\-]?[\-\.0-9a-zA-Z]?+$ ]]; then
    VERSION="$1"
    if [[ "${1:0:1}" != "v" ]]; then
      VERSION="v""$VERSION"
    fi
  else

    return 1
  fi
  if [[ ! -z $2 ]]; then
    MESSAGE=$2
  fi
  echo "Version: $VERSION"
  echo "Message: $MESSAGE"
}


cd $PREV_DIR