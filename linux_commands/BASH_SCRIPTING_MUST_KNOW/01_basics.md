# positional parameters
- $0 
- $1 
- $2
- $@ ( all args )
- $# ( number of args )


# Conditionals

- if [ -f file ]
- if [ -d dir ]
- if [ -z "$var" ]
- if [ -n "$var" ]


# loops
1. for i in {1..5}
2. while read line

# exit codes
1. $?
2. exit 0
3. exit 1

# Redirection

1. > file
2. >> file
3. 2> error.log
4. &> all.log
5. 2>/dev/null
6. 2>&1


# Job control

1. command &
2. $!
3. wait
4. wait -n

# Safety

1. set -e 
2. set -u
3. set -o pipefail


# Traps
1. trap 'cleanup' SIGINT SIGTERM
2. trap '' SIGHUP