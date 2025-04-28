#!/bin/bash
nflag=
vflag=

if [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [options] pattern [file...]"
    echo ""
    echo "Options:"
    echo "  -n        Prefix each line of output with the line number within its input file."
    echo "  -v        Invert the sense of matching, to select non-matching lines."
    echo "  --help    Display this help and exit."
    exit 0
fi

while getopts "nv" name
do
    case $name in
    n)    nflag=1;;
    v)    vflag=1;;
    ?)    printf "Usage: %s: [-n] [-v] pattern [file...]\n" "$0"
          exit 2;;
    esac
done

shift $((OPTIND - 1))
if [ $# -lt 1 ]; then
    printf "Usage: %s: [-n] [-v] pattern [file...]\n" "$0"
    exit 2
fi

pattern=$1
if [ -z "$pattern" ]; then
    printf "Error: missing search pattern.\n"
    printf "Usage: %s: [-n] [-v] pattern [file...]\n" "$0"
    exit 2
fi

if [ -f "$pattern" ]; then
    printf "Error: missing search pattern (provided a file instead: %s).\n" "$pattern"
    printf "Usage: %s: [-n] [-v] pattern [file...]\n" "$0"
    exit 2
fi

shift
if [ -z "$*" ]; then
    files=-
else
    files="$@"
fi
if [ -z "$nflag" ]; then
    nflag=0
fi
if [ -z "$vflag" ]; then
    vflag=0
fi

for file in $files; do
    if [ "$file" = "-" ]; then
        file=/dev/stdin
    fi
    if [ ! -r "$file" ]; then
        printf "%s: %s: No such file or directory\n" "$0" "$file" >&2
        exit 1
    fi

        while IFS= read -r line; do
        lineno=$((lineno + 1))

        if [ "$vflag" -eq 1 ]; then
            if ! echo "$line" | grep -q -- "$pattern"; then
                if [ "$nflag" -eq 1 ]; then
                    printf "%d:%s\n" "$lineno" "$line"
                else
                    printf "%s\n" "$line"
                fi
            fi
        else
            if echo "$line" | grep -q -- "$pattern"; then
                if [ "$nflag" -eq 1 ]; then
                    printf "%d:%s\n" "$lineno" "$line"
                else
                    printf "%s\n" "$line"
                fi
            fi
        fi
    done < "$file"
done
exit 0
