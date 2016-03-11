#!/bin/bash
#Purpose = Decrypt files encrypted with a public gpg key
#Created on 03-04-2016
#Author = Cade Torix
#START

# Set start time
START=$(date +%s)

# Define text formatting variables:
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtrst=$(tput sgr0)       # Text reset

# Syntax of simple decryption and extraction
# gpg -d ${DECRYPT} | tar -xpJf - -C ${DESDIR}

# Syntax for decrypt only
# gpg -o ${OUTPUT} -d ${DECRYPT}

# Function to verify previous task completed successfully
verify () {
if [ $? -eq 0 ]
then
    echo
    echo "${SUCCESS}"
    echo
else
    echo
    echo "${FAILED}"
    echo
    exit 1
fi
}

# Function to determine time taken to complete decryption/extraction
time_taken () {
END=$(date +%s)
DIFF=$(( ${END} - ${START} ))
TOTALTIME=$(( ${DIFF} / 60 ))
echo "Total time: ${TOTALTIME} minutes."
echo
}

# Check to see if extract directory was supplied
if [ -z "${2}" ]
then
    DESDIR=$(pwd)
else
    DESDIR="${2}"
fi

# Check to see number of arguments provided for [file to decrypt] and [extract dir]
if [ $# = 1 ]
then
    echo
    echo "${txtbld}${txtred}No extract directory provided!${txtrst}"
    echo "${txtbld}${txtred}Extraction will be to:${txtrst} ${DESDIR}"
    echo
elif [ $# != 2 ]
then
    echo
    echo "Usage: ${txtbld}${txtred}./decrypt_files.sh [file to decrypt] (optional: [extract dir])${txtrst}"
    echo
    exit 1
fi

# Check to see if {DESDIR} exists and is writable
# Variables for success/failure
SUCCESS="Creation of ${DESDIR} successful"
FAILED="${txtbld}${txtred}Creation of${txtrst} ${DESDIR} ${txtbld}${txtred}failed! Check your permissions${txtrst}"
if [ ! -w ${DESDIR} ]
then
    echo
    echo "${DESDIR} ${txtbld}${txtred}does not exist or you do not have write permissions!${txtrst}"
    # Offer to create ${DESDIR}
    echo
    echo 'Attempt to create it? (Y/n)'
    read answer
    if [ ${answer} = 'Y' ]
    then
        mkdir -p ${DESDIR}
        verify
    else
        echo
        echo "${txtbld}${txtred}Creation of${txtrst} ${DESDIR} ${txtbld}${txtred}declined... exiting...${txtrst}"
        echo
        exit 1
    fi
fi

# Set variables
DECRYPT="${1}"	# [file to decrypt]
OUTPUT=$(echo ${DECRYPT} | cut -f -3 -d '.')	#used for Decrypt Only option

# Prompt for decryption only
# Variables for success/failure
SUCCESS="Decrypted ${DECRYPT} successfully and saved it as ${DESDIR}${OUTPUT}"
FAILED="${txtbld}${txtred}Decryption of${txtrst} ${DECRYPT} ${txtbld}${txtred}failed!${txtrst}"
echo
echo "Only decrypt ${DECRYPT} as ${OUTPUT} (no extraction)? (Y/n)"
read answer
if [ ${answer} = 'Y' ]
then
    gpg -o ${DESDIR}${OUTPUT} -d ${DECRYPT}
    verify
    time_taken
    exit 0
fi

# Prompt to delete encrypted tarball after decrypt and extraction
# Variables for success/failure
SUCCESS="Decrypted ${DECRYPT} successfully to ${DESDIR}"
FAILED="${txtbld}${txtred}Decryption of${txtrst} ${DECRYPT} ${txtbld}${txtred}failed!${txtrst}"
echo
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
time_taken
#END