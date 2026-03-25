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

assert "No version string provided" "e" "$(get_version_score)"
assert "Version string with only alphabets" "e" "$(get_version_score 'abcdef')"
assert "Version string with only digits" "e" "$(get_version_score '101')"
assert "Version string with only 1 '.'" "e" "$(get_version_score '.')"
assert "Version string with only 2 '.'" "e" "$(get_version_score '..')"
assert "Version string with only 3 '.'" "e" "$(get_version_score '...')"
assert "Version string with only 5 '.'" "e" "$(get_version_score '.....')"
assert "Version string with wildcard '*'" "e" "$(get_version_score '*')"
assert "Version string with 2 '*'" "e" "$(get_version_score '**')"
assert "Version string with 3 '*'" "e" "$(get_version_score '***')"
assert "Version string with 5 '*'" "e" "$(get_version_score '*****')"
assert "Version string with wildcard '?'" "e" "$(get_version_score '?')"
assert "Version string with 2 '??'" "e" "$(get_version_score '??')"
assert "Version string with 3 '??'" "e" "$(get_version_score '???')"
assert "Version string with 5 '?????'" "e" "$(get_version_score '?????')"
assert "Version string with space" "e" "$(get_version_score ' ')"
assert "Version string with 2 spaces" "e" "$(get_version_score '  ')"
assert "Version string with 5 spaces" "e" "$(get_version_score '     ')"
assert "Version string with only 2 components" "e" "$(get_version_score ' 1.1')"
assert "Version string, only 2 components, trailing '.'" "e" "$(get_version_score ' 1.1.')"
assert "Version string, only 2 components, trailing '*'" "e" "$(get_version_score ' 1.1*')"
assert "Version string, only 2 components, trailing '.*'" "e" "$(get_version_score ' 1.1.*')"
assert "Version string, only 2 components, trailing '.?'" "e" "$(get_version_score ' 1.1.?')"
assert "Version string, only 2 components, trailing '..'" "e" "$(get_version_score ' 1.1..')"
assert "Version string with leading space" "e" "$(get_version_score ' 1.0.1')"
assert "Version string with trailing space" "e" "$(get_version_score '1.0.1 ')"
assert "Version string with space inside" "e" "$(get_version_score '1. 0.1')"
assert "Version string with inner '*'" "e" "$(get_version_score '1.1*.1')"
assert "Version string with inner '?'" "e" "$(get_version_score '1.1?.1')"
assert "Version string with inner '.'" "e" "$(get_version_score '1.1..1')"
assert "Valid version string 1.1.1" "1001001" "$(get_version_score '1.1.1')"
assert "Valid version string 1.2.3" "1002003" "$(get_version_score '1.2.3')"
assert "Valid version string 0.0.0" "0" "$(get_version_score '0.0.0')"
assert "Valid version string upper bound 999.999.999" "999999999" "$(get_version_score '999.999.999')"
assert "Valid version string with insane version 3333.2222.1111" "3335223111" "$(get_version_score '3333.2222.1111')"