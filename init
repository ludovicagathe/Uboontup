#!/bin/bash
# FONT COLORS
RED='\033[1;31m' # Error
YELLOW='\033[1;33m' # Warning
CYAN='\033[0;36m' # In progress
GREEN='\033[1;32m' # Success
NC='\033[0m' # No color
# SET BASE DIRECTORY
if [[ $(basename $PWD) == "setup" ]]; then
  BASE_DIR=$HOME;
else
  BASE_DIR=$PWD/test_home;
fi
PREV_DIR=$(pwd)
cd $BASE_DIR
pwd

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
      echo -e "$BASE_DIR/$user_dir ${RED}already exits${NC}" | tee -a $BASE_DIR/logs/setup_00_init.log
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

# VARIABLES
user_dirs=("logs" "repos" "setup")
user_files=("/logs/init.log" "/logs/errors.log")
# check_and_create_dir "${user_dirs[@]}"
# backup_folder "test" "bkp_"


cd $PREV_DIR