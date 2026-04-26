source ../lib/test.sh
ERROR_STRING="Err"
LOGGING_STORE=""

# LOGGING_STORE="${LOGGING_STORE}\n$(assert 'No argument passed' $ERROR_STRING $(edit_line))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert '1 argument passed' $ERROR_STRING $(edit_line 'test'))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert '2 argument passed' $ERROR_STRING $(edit_line 'test' 'test2'))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert '3rd argument is not a regular file' $ERROR_STRING $(edit_line 'test' 'test2' 'alpha'))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert 'Search string not in file' 0 $(edit_line 'test' 'test2' 'sc_test'))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert 'Search string in file' 4 $(edit_line 'line' 'test' 'sc_test'))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert 'Search for regex pattern' 1 $(edit_line 's.*me' 'test' 'sc_test'))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert 'Search for basic regex pattern' 1 $(edit_line 'c\(o\+d\?\)e' 'test' 'sc_test'))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert 'Search for basic regex pattern multiple replacements (input 'y' twice)' 2 $(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert 'Search for basic regex pattern multiple replacements (input 'n' once)' 1 $(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v))"
# LOGGING_STORE="${LOGGING_STORE}\n$(assert 'Search for basic regex pattern multiple replacements (input 'n' twice)' 0 $(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v))"
# # LOGGING_STORE="${LOGGING_STORE}\n$(assert 'Search for basic regex pattern single replacement mode (input 'n' once)' 1 $(edit_line 'l\(i\?n\?\)e' 'test' 'sc_test' -s))"
run_assert "Search for basic regex pattern single replacement mode (input 'n' once first)" 1 "$(edit_line 'l\(i\?n\?\)e' 'test' 'sc_test' -s)"

echo
echo -e "${YELLOW}     *****     RESULTS     *****${NC}"
echo -e "${LOGGING_STORE}"
# check for basic regex