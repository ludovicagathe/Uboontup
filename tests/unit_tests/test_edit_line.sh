source ../lib/test.sh
ERROR_STRING="Err"

assert "No argument passed" "$ERROR_STRING" "$(edit_line)"
assert "1 argument passed" "$ERROR_STRING" "$(edit_line 'test')"
assert "2 arguments passed" "$ERROR_STRING" "$(edit_line 'test' 'test2')"
assert "3rd argument is not a regular file" "$ERROR_STRING" "$(edit_line 'test' 'test2' 'alpha')"
assert "Search string not in file" "0" "$(edit_line 'test' 'test2' 'sc_test')"
assert "Search string in file" "4" "$(edit_line 'line' 'test' 'sc_test')"
assert "Search for regex pattern" "1" "$(edit_line 's.*me' 'test' 'sc_test')"
assert "Search for basic regex pattern" "1" "$(edit_line 'c\(o\+d\?\)e' 'test' 'sc_test')"
assert "Search for basic regex pattern multiple replacements (input 'y' twice)" "2" "$(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v)"
assert "Search for basic regex pattern multiple replacements (input 'n' once)" "1" "$(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v)"
assert "Search for basic regex pattern multiple replacements (input 'n' twice)" "0" "$(edit_line 'c\(o\?d\?\)e' 'test' 'sc_test' -v)"

# check for basic regex