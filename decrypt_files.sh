#!/bin/bash
#Purpose = Decrypt files encrypted with a public gpg key
#Created on 03-04-2016
#Author = Cade Torix
#Version 1.3
#START

# Set start time
START=$(date +%s)

# Define text formatting variables:
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtrst=$(tput sgr0)       # Text reset

# Syntax of simple decryption and extraction
# gpg -d ${DECRYPT} | tar -xpJf - -C ${DESDIR}

# Function to verify previous task completed successfully
verify () {
if [ $? -eq 0 ]
then
    echo
    echo 'Successful'
    echo
else
    echo
    echo "${txtbld}${txtred}Failed!${txtrst}"
    echo
    exit 1
fi
}

# Check to see if extract directory was supplied
if [ -z "${2}" ]
then
    DESDIR=$(pwd)
else
    DESDIR="${2}"
fi

# Check to see if {DESDIR} exists and is writable
if [ ! -w ${DESDIR} ]
then
    echo
    echo "${DESDIR} ${txtbld}${txtred}does not exist or you do not have write permissions!${txtrst}"
    echo 'Attempt to create it? (Y/n)'
    # Offer to create ${DESDIR}
    read answer
    if [ ${answer} = 'Y' ]
    then
        mkdir -p ${DESDIR}
        verify
    else
        exit 1
    fi
fi

# Check to see number of arguments provided for [file to decrypt] and [extract dir]
if [ $# = 1 ]
then
    echo
    echo "${txtbld}${txtred}No extract directory provided!${txtrst}"
    echo "${txtbld}${txtred}Extraction will be to: ${txtrst}${DESDIR}"
    echo
elif [ $# != 2 ]
then
    echo
    echo Usage: "${txtbld}${txtred}./decrypt_files.sh [file to decrypt] (optional: [extract dir])${txtrst}"
    echo
    exit 1
fi

# Set variables
DECRYPT="${1}"	# [file to decrypt]

# Prompt to delete encrypted tarball after decrypt and extraction
echo "Delete encrypted tarball ${DECRYPT} after decrypt and extraction? (Y/n)"
read answer
if [ ${answer} = 'Y' ]
then
    gpg -d ${DECRYPT} | tar -xpJf - -C ${DESDIR} && rm ${DECRYPT}
else
    gpg -d ${DECRYPT} | tar -xpJf - -C ${DESDIR}
fi

# Check to see if decrypt/extract & delete (if applicable) completed successfully
verify

# Set end time and calculate total script time
END=$(date +%s)
DIFF=$(( ${END} - ${START} ))
TOTALTIME=$(( ${DIFF} / 60 ))
echo "Total time: ${TOTALTIME} minutes."
echo
#END
