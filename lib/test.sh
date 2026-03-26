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