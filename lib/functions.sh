# Helper and library functions

# FUNCTIONS
define_font_colours() {
  RED='\033[1;31m' # Error
  YELLOW='\033[1;33m' # Warning
  CYAN='\033[0;36m' # In progress
  GREEN='\033[1;32m' # Success
  NC='\033[0m' # No color
}

critical_error() { # Flag and log a critical error to syslog and exit script
  echo "$0:$1" >&2
  logger -t $(basename "$0") -p user.err $1
  exit 1
}

set_base_dir() { # Set base directory to either $HOME (production) or test_home (development)
  if [[ ! $(basename $PWD) == "uboontup" ]]; then
    BASE_DIR=$PWD/test_home;
  fi
  cd $BASE_DIR
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
  if [[ "$1" =~ ^[v]?[0-9]+(\.[0-9]+){1,2}(\-[a-zA-Z0-9\.\-]+)?$ ]]; then
    VERSION="$1"
    if [[ "${1:0:1}" == "v" ]]; then
      VERSION="${1:1:$(( $#1 - 1 ))}"
    fi
    echo "Version: $VERSION"
  else
    echo -e "${RED}Version could not be determined${NC}" >&2
    return 1
  fi
  if [[ ! -z $2 ]]; then
    echo "Message: $2"
  fi
}

get_version_score() { # Parse the version string and calculate the score, with: major version x1000000, feature version x 1000, fixes x 1, allowing for up to vX.999.999. Ignores alpha, (-alpha), beta (-beta), release candidates (-rc) etc
  if [[ -z "$ERROR_STRING" ]]; then
    ERROR_STRING="Err"
  fi
  local VERSION DIGITS OLDIFS SCORE
  if [[ -z "$1" ]];then # Check for empty or no argument supplied
    echo -e "${RED}Version arguments are missing. You need to provide a version string of form \"v0.0.0\"${NC}" >&2
    echo "$ERROR_STRING"
    return 1
  fi
  if [[ "${#@}" -gt 1 ]];then # Check for more than 1 argument supplied
    echo -e "${RED}Too many version arguments provided. You need to provide only 1 version strings${NC}" >&2
    echo "$ERROR_STRING"
    return 1
  fi
  VERSION="$(cut -d '-' -f 1 <<< $1)"
  if [[ "$VERSION" =~ ^[v]?[0-9]+$ ]]; then
    VERSION="$VERSION"".0.0"
  fi
  if [[ "$VERSION" =~ ^[v]?[0-9]+\.[0-9]+$ ]]; then
    VERSION="$VERSION"".0"
  fi
  if [[ ! "$VERSION" =~ ^[v]?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}You need to provide a version string of form \"v0.0.0\"${NC}" >&2
    echo "$ERROR_STRING"
    return 1
  fi
  if [[ "${1:0:1}" == "v" ]]; then # Check for "v" prefix and ignore
    VERSION="${1:1:$(( ${#1}-1 ))}"
  fi
  OLDIFS=$IFS
  IFS='.'
  read -r -a DIGITS <<< $VERSION
  IFS=$OLDIFS
  SCORE=0 # Initialise and compute score
  SCORE=$(( $SCORE + (( ${DIGITS[0]} * 1000000 )) + (( ${DIGITS[1]} * 1000 )) + (( ${DIGITS[2]} * 1 )) ))
  echo "$SCORE"
  return 0
}

compare_versions() { # Compare two version strings of form "vX.X.X" or "X.X.X" ("X" is a number), the first version argument being the current and base for comparison. Returns "e" if both versions are equal, "g" if first argument is a greater or more recent version and "s" if it is smaller or an older version. Returns error string "Err" if arguments are not appropriate
  if [[ -z "$ERROR_STRING" ]]; then
    ERROR_STRING="Err"
  fi
  local SCORE1 SCORE2
  if [[ -z "$1" || -z "$2" || ${#@} -gt 2 ]];then
    echo -e "${RED}Version arguments are not adequate. You need to provide 2 version strings of form 'vX.X.X' or 'X.X.X'${NC}" >&2
    echo "$ERROR_STRING"
    return 1
  fi
  SCORE1=$(get_version_score $1)
  SCORE2=$(get_version_score $2)
  if [[ "$SCORE1" == "$ERROR_STRING" || "$SCORE2" == "$ERROR_STRING" ]]; then
    echo -e "${RED}Invalid version arguments supplied${NC}" >&2
    echo "$ERROR_STRING"
    return 1
  else
    if [[ "$SCORE1" -eq "$SCORE2" ]];then
      echo "e" # both versions are equal
      return 0
    fi
    if [[ "$SCORE1" -gt "$SCORE2" ]];then
      echo "g" # first version provided is greater ('g') or more recent
      return 0
    fi
    if [[ "$SCORE1" -lt "$SCORE2" ]];then
      echo "s" # first version provided is smaller ('s') or earlier
    fi
  fi
}