#!/bin/bash

# open directory and check makefile

yourtest="scripts/b_printf/yourmain.c"
reftest="scripts/b_printf/refmain.c"
dirName="$1"
echo "Make sure your header file is includes/b_printf.h!!!"
if [ -e "$dirName" ] ; then
    sh scripts/norme.sh "$1"
    cp -- "$yourtest" "$dirName"
    cp -- "$reftest" "$dirName"
    cd -- "$dirName"
    if [ -e "author" ] ; then
        echo "found author file"
    else
        echo "missing author file!"
    fi
    if make re >/dev/null ; then
        if make fclean >/dev/null ; then
            echo "passed makefile test"
            make re >/dev/null && make clean >/dev/null
        else
            echo "make fclean error!"
        fi
    else
        echo "make re error!"
        echo "if header not found change include statement in scripts/project/yourmain.c"
        rm -f yourmain.c refmain.c
        exit 1
    fi
else
    echo "Project not found! Use ./run [projName] [projPath]"
fi

# compile and eval main

if gcc -g -fsanitize=address -Wall -Wextra -Werror yourmain.c libftprintf.a -o yourProg ; then
    if ./yourProg | cat -e > yourLog; then
        gcc -g -fsanitize=address -Wall -Wextra -Werror refmain.c -o refProg
        rm -f yourmain.c refmain.c
    else
        echo "runtime error!"
        rm -f yourmain.c refmain.c
        exit 1
    fi
else
    echo "compile error!"
    echo "if header not found change include statement in scripts/project/yourmain.c"
    rm -f yourmain.c refmain.c
    exit 1
fi

# compare your output to the standard functions

./refProg | cat -e > refLog
DIFF=$(diff yourLog refLog)
if [ "$DIFF" == "" ] ; then
    echo "pass! Please manually check %p flag."
else
    echo "Outputs don't match! Check log files in project directory"
fi
rm -f refProg yourProg