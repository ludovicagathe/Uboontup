# This test script runs tests on the edit_line function. LOGGING_STORE variable is preserved and restored at the end of the tests. 
## REQUIREMENTS:
### 1. The LOGGING_STORE variable is to be provided
### 2. LOGGING_STORE to be echoed to summarise test results
source ../lib/test.sh
ERROR_STRING="Err"
if [[ -n "$LOGGING_STORE" ]]; then
  OLD_LOGGING_STORE="${LOGGING_STORE}"
fi
LOGGING_STORE=""

run_assert 'No argument passed' $ERROR_STRING "$(edit_line)"
run_assert '1 argument passed' $ERROR_STRING "$(edit_line 'test')"
run_assert '2 argument passed' $ERROR_STRING "$(edit_line 'test' 'test2')"
run_assert '3rd argument is not a regular file' $ERROR_STRING "$(edit_line 'test' 'test2' 'alpha')"
run_assert 'Search string not in file' 0 "$(edit_line 'test' 'test2' 'sc_test')"
run_assert 'Search string in file' 2 "$(edit_line 'line' 'test' 'sc_test')"
run_assert 'Search for regex pattern' 1 "$(edit_line 's.*me' 'test' 'sc_test')"
run_assert 'Search for basic regex pattern' 1 "$(edit_line 'c\(o\+d\?\)e' 'test' 'sc_test')"
run_assert 'Search for basic regex pattern multiple replacements (input 'y' twice)' 2 "$(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v)"
run_assert 'Search for basic regex pattern multiple replacements (input 'n' once)' 1 "$(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v)"
run_assert 'Search for basic regex pattern no replacement (input 'n' twice)' 0 "$(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v)"
run_assert 'Search for basic regex pattern single replacement mode (input 'n' once)' 1 "$(edit_line 'li\(n\?\)e' 'test' 'sc_test' -s)"
run_assert "Search for basic regex pattern single replacement mode (input 'n' once first)" 1 "$(edit_line 'li\(n\?\)e' 'test' 'sc_test' -s)"

echo
echo -e "${YELLOW}     *****     RESULTS     *****${NC}"
echo -e "${LOGGING_STORE}"
# check for basic regex
LOGGING_STORE="${OLD_LOGGING_STORE}"