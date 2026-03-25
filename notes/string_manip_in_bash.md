# String manipulation in Bash

## Extracting a substring using cut
To pass a string to the cut command in Bash, you can use either a pipe (|) with echo or a here-string (<<<).

### Using a pipe (|)
This is the most common method, where the output of echo is redirected to the standard input of cut.
```bash
STRING="John Doe"
SUBSTRING=$(echo "$STRING" | cut -d ' ' -f 1)
echo "$SUBSTRING"
# Output: John
```
- echo "$STRING": Prints the value of the variable to standard output.
- | cut ...: The pipe operator sends that output to the cut command's standard input.
- -d ' ': Specifies a space (' ') as the delimiter.
- -f 1: Selects the first field (or column). 

### Using a here-string (<<<) 
A here-string is a specific Bash feature that provides the string directly as standard input to the command, often considered a slightly cleaner alternative to echo and a pipe.
```bash
STRING="one:two:three"
SUBSTRING=$(cut -d ':' -f 2 <<< "$STRING")
echo "$SUBSTRING"
# Output: two
```

### Examples of cut options
Description 	        Command	        Output	            Source
Field by delimiter	  `echo "a b c"	  cut -d ' ' -f 2`	  b
Multiple fields	      `echo "1,2,3,4"	cut -d ',' -f 1,3`	1,3
Character position	  `echo "foobar"	cut -c 1-3`	        foo
Specific bytes	      `echo "baz"	    cut -b 1,3`	        bz

### Alternative: Bash Parameter Expansion 
For manipulating a single string in a variable, Bash's built-in parameter expansion is generally faster and doesn't require spawning an external process like cut. 
```bash
VAR="filename.tar.gz"

# Remove the shortest match of '*.gz' from the end
echo ${VAR%.gz}
# Output: filename.tar

# Remove everything before the last '/'
PATH_VAR="/usr/local/bin/my_script.sh"
echo ${PATH_VAR##*/}
# Output: my_script.sh
```
