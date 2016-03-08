#!/bin/bash
#Purpose = Decrypt files encrypted with a public gpg key
#Created on 03-04-2016
#Author = Cade Torix
#Version 1.2
#START

# Set start time
START=$(date +%s)

# Define text formatting variables:
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtrst=$(tput sgr0)       # Text reset

#Syntax of decryption: gpg -o [output filename] -d [file to decrypt]

# Check to see if extract directory was supplied
if [ -z "${3}" ]
then
    DESDIR=$(pwd)
else
    DESDIR="${3}"
fi

# Check to see if number of arguments provided for [output filename] [file to decrypt] and [dir to extract to]
if [ $# = 2 ]
then
    echo
    echo "${txtbld}${txtred}No extract directory provided!${txtrst}"
    echo "${txtbld}${txtred}Extraction will be to: ${txtrst}${DESDIR}"
    echo
elif [ $# != 3 ]
then
    echo
    echo Usage: "${txtbld}${txtred}./decrypt_files.sh [output filename] [file to decrypt] (optional: [dir to extract to])${txtrst}"
    echo
    exit 1
fi

# Set variables
OUTPUT="${1}"	# [output filename]
INPUT="${2}"	# [file to decrypt]

# Check to see if {OUTPUT} and {INPUT} are the same
if [ ${OUTPUT} = ${INPUT} ]
then
    echo
    echo "${txtbld}${txtred}Um...  Why would you name the new decrypted file the same name of the file you're decrypting!${txtrst}"
    echo
    exit 1
fi

# All error checking passed so far, proceed with decrypting tarball
gpg -o ${OUTPUT} -d ${INPUT}

# Check {OUTPUT} to see if decryption completed successfully
if [ $? -eq 0 ]
then
    echo
    echo "Decryption of tarball ${INPUT} completed successfully as ${OUTPUT}."
    echo "Now run tar -xpJf ${OUTPUT} -C ${DESDIR}? (Y/n)"
    # Extract the decrypted tarball?
    read answer
    if [ ${answer} = 'Y' ]
    then
        tar -xpJf ${OUTPUT} -C ${DESDIR}
        # Check to see if the export succeeded and offer to delete {OUTPUT}
        if [ $? -eq 0 ]
        then
            echo
            echo "Export of ${OUTPUT} to ${DESDIR} completed successfully."
            echo "Delete decrypted tarball ${OUTPUT}? (Y/n)"
            read answer
            if [ ${answer} = 'Y' ]
            then
                rm ${OUTPUT}
                # Did the decrypted tarball get deleted?
                if [ $? -eq 1 ]
                then
                    echo
                    echo "${txtbld}${txtred}Failed to delete ${OUTPUT}!${txtrst}"
                    echo
                else
                    echo
                    echo "${OUTPUT} deleted successfully."
                    echo "Delete encrypted tarball ${INPUT}? (Y/n)"
                    # Delete the encrypted source tarball?
                    read answer
                    if [ ${answer} = 'Y' ]
                    then
                        rm ${INPUT}
                            # Did the encrypted tarball get deleted?
                            if [ $? -eq 1 ]
                            then
                                echo
                                echo "${txtbld}${txtred}Failed to delete ${INPUT}!${txtrst}"
                                echo
                            else
                                echo
                                echo "${INPUT} deleted successfully"
                                echo
                            fi
                    fi
                fi
            fi
        else
            echo "${txtbld}${txtred}Export of ${OUTPUT} to ${DESDIR} failed!${txtrst}"
        fi
    else
        exit 0
    fi
else
    echo
    echo "${txtbld}${txtred}Decryption of tarball ${INPUT} failed!${txtrst}"
    echo "${txtbld}${txtred}Check path and file name.${txtrst}"
    echo
    exit 1
fi

# Set end time and calculate total script time
END=$(date +%s)
DIFF=$(( ${END} - ${START} ))
TOTALTIME=$(( ${DIFF} / 60 ))
echo "Total time: ${TOTALTIME} minutes."
echo
#END
