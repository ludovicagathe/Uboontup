#!/bin/bash

equals() {
  if [[ "$1" == "$2" ]]; then
    return 0
  fi
  return 1
}

contains() {
  if [[ "$1" =~ "$2 " ]]; then
    return 0
  fi
  return 1
}

assert() { # Test function requiring 3 arguments: 1. a string describing the test; 2. the expected result string or number; 3. the actual outcome of a function or other output from $(). Prints expected and result on failure, clipping both to their first 20 characters.
## Todo: make assert accept several possible results
  local DESCRIPTION=$1
  local EXPECTED=$2
  local RESULT=$3
  local EQUALS=$4
  local PASS=0
  local CHAR_LIMIT=50

  if [[ "$EQUALS" != "-c" ]]; then
    EQUALS="-e"
  fi
  if [[ ${#} -gt 4 || ${#} -lt 3 ]]; then
    echo -e "\033[1;31mThe number of arguments provided to the assert function should be 3 or 4\033[0m" >&2
    return 1
  fi
  if [[ "$EQUALS" == "-e" ]]; then
    if [[ "$RESULT" != "$EXPECTED" ]]; then
      PASS=1
    fi
  else
    if [[ ! "$RESULT" =~ "$EXPECTED" ]]; then
      PASS=1
    fi
  fi
  if [[ "$PASS" -eq 1 ]]; then
    if [[ "${#RESULT}" -gt "$CHAR_LIMIT" ]]; then
      RESULT="${RESULT:0:$CHAR_LIMIT} (...)"
    fi
    if [[ "${#EXPECTED}" -gt "$CHAR_LIMIT" ]]; then
      EXPECTED="${EXPECTED:0:$CHAR_LIMIT} (...)"
    fi
    echo -e "\033[1;31mTEST: \033[0m${DESCRIPTION}: \033[1;31mFailed\033[0m"
    echo -e "EXPECTED:\t${EXPECTED}"
    echo -e "RESULT:\t\t${RESULT}"
    return "$PASS"
  fi
  echo -e "\033[1;32mTEST: \033[0m${DESCRIPTION}: \033[1;32mPassed\033[0m"
  return "$PASS"
}

run_assert() { # Wrapper around the assert function, providing pre-test description for user input indication and/or instruction and providing a full test summary, stored in the LOGGING_STORE global variable. The LOGGING_STORE variable MUST be provided in the calling script.
  echo -e "\033[1;33m## TEST:\033[0m $1" >&2
  local RESULT=$(assert "$@")
  LOGGING_STORE="${LOGGING_STORE}\n${RESULT}"
}