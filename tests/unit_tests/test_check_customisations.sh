source ../lib/test.sh
ERROR_STRING="Err"

assert "No default .bashrc file" "$ERROR_STRING" "$(compare_versions)"