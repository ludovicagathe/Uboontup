source ../lib/test.sh
if [[ -z $ERROR_STRING ]]; then
    ERROR_STRING="Err"
fi

assert "Does not accept more than 1 argument" "$ERROR_STRING" "$(check_bash_customisations $HOME/uboontup/tests/sc_test data)" -e
assert "Accepts a custom .bashrc file as argument" "$ERROR_STRING" "$(check_bash_customisations $HOME/bashrc2.test)" -e
assert "Accepts a custom .bashrc file as argument" "$ERROR_STRING" "$(check_bash_customisations $HOME/bashrc2.test)"
assert "Get Uboontup directory" "$ERROR_STRING" "$(check_bash_customisations)" -e
# assert "Custom .bashrc file exists" "" "$(check_bash_customisations)"
assert "Finds default .bashrc file when no argument is passed" '' "$(check_bash_customisations)" -e