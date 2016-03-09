#!/bin/bash
#Purpose = tar and encrypt with a public gpg key
#Created on 03-04-2016
#Author = Cade Torix
#Version 1.2.1
#START

# Set start time
START=$(date +%s)

# Define text formatting variables:
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtrst=$(tput sgr0)       # Text reset

# Set variables
DATE=$(date +%Y%m%d)		# Setting the date
SOURCE="${1}"			# [source dir/file]
EXTENSION="_${DATE}.tar.xz.gpg"	# Setting the file extension

# Check to see if 4 arguments are provided for [source dir/file] [destination dir] [filename (excluding extension)] and [recipient email or key]
if [ $# != 4 ]
then
    echo
    echo "Usage: ${txtbld}${txtred}./encrypt_files.sh [source dir/file] [destination dir] [filename (excluding extension)] (${EXTENSION} will be appended to the end of the supplied FILENAME) [recipient email or key]${txtrst}"
    echo
    exit 1
fi

# Check to see if the {SOURCE} exists
if [ ! -s ${SOURCE} ]
then
    echo
    echo "${txtbld}${txtred}${SOURCE} does not exist or is empty!${txtrst}"
    echo
    exit 1
fi

# Set more variables
DESDIR="${2}"			# [destination dir]
FILENAME="${3}"			# [filename (excluding extension)]
SAVEAS="${2}${3}${EXTENSION}"	# [destination dir]/[filename][extension]
RECIPIENT="${4}"		# Recipient's public GPG key or email address

# Check to see of the {DESDIR} exists and you have write permissions
if [ ! -w ${DESDIR} ]
then
    echo
    echo "${txtbld}${txtred}Destination directory ${DESDIR} does not exist or you do not have write permissions!${txtrst}"
    echo
    echo 'Create it? (Y/n)'
    read answer
    if [ ${answer} = 'Y' ]
    then
        mkdir -p ${DESDIR}
        # Check to see if dir was created successfully
        if [ $? -eq 1 ]
        then
            echo
            echo "${txtbld}${txtred}mkdir of ${txtrst}${DESDIR} ${txtbld}${txtred}failed! Check your permissions.${txtrst}"
            echo
            exit 1
        else
            echo
            echo "mkdir of ${DESDIR} completed successfully"
            echo
        fi
    else
        echo
        echo "${txtbld}${txtred}Creation of ${DESDIR} declined... exiting...${txtrst}"
        echo
        exit 1
    fi
fi

# Check to see if the {SOURCE} is ~/.  If so, assumes to exclude ~/VirtualBox_VMs and ~/Truecrypt_Volumes
if [ ${SOURCE} = ~/ ]
then
    echo
    echo The SOURCE is ~/ so excluding VirtualBox_VMs and Truecrypt_Volumes.
    echo
    echo "All error checking passed, encrypting tarball with ${RECIPIENT} public gpg key"
    echo
    tar -cpJ --exclude ~/VirtualBox_VMs --exclude ~/Truecrypt_Volumes ${SOURCE} | gpg -e -r ${RECIPIENT} -o ${SAVEAS}
else
    echo
    echo The SOURCE is NOT ~/ so no exclusions have been made.
    echo
    echo "All error checking passed, encrypting tarball with ${RECIPIENT} public gpg key"
    echo
    tar -cpJ ${SOURCE} | gpg -e -r ${RECIPIENT} -o ${SAVEAS}
fi

# Check to see if tarball encryption was a success
if [ $? -eq 0 ]
then
    echo
    echo "Encrypted tarball of ${SOURCE} completed successfully and saved as ${SAVEAS}."
    echo 'Sign it with detached signature? (Y/n)'
    # To sign or not to sign that is the detached question
    read answer
    if [ ${answer} = 'Y' ]
    then
        gpg --armor --detach-sig ${SAVEAS}
        # Check to see if signing was successful
        if [ $? -eq 0 ]
        then
            echo
            echo 'GPG signature successful'
            echo
        else
            echo
            echo "${txtbld}${txtred}GPG signature failed!${txtrst}"
            echo
            exit 1
        fi
    else
        exit 0
    fi
else
    echo
    echo "${txtbld}${txtred}Tarball and encryption of ${SOURCE} failed!${txtrst}"
    echo
    exit 1
fi

# Set end time and calculate total script time
END=$(date +%s)
DIFF=$(( ${END} - ${START} ))
TOTALTIME=$(( ${DIFF} / 60 ))
echo
echo "Total time: ${TOTALTIME} minutes."
echo
#END
