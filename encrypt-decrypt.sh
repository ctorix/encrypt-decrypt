#!/bin/bash
#Purpose = tar and encrypt with a public gpg key
#Created on 03-04-2016
#Author = Cade Torix
#START

# Syntax
# Encryption
# encrypt {SOURCE} {DESDIR} [Filename] [Recipient email or hex key]
#
# Decryption
# decrypt [file to decrypt] (optional: [extract dir])

# Set start time
START=$(date +%s)

# Define text formatting variables:
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtrst=$(tput sgr0)       # Text reset

# Set global variables
DESDIR="${3}"			# [destination dir]

# Function to verify previous task completed successfully
verify () {
if [ $? -eq 0 ]
then
    echo
    echo "${SUCCESS}"
    echo
else
    echo
    echo "${FAILED}}"
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

################## Begin encryption function ##################

encrypt () {
# Set function variables
local DATE=$(date +%Y%m%d)				# Setting the date used in filename extension
local SOURCE="${1}"					# [source dir/file]
local EXTENSION="_${DATE}.tar.xz.gpg"			# Setting the file extension
local FILENAME="${2}"					# [filename (excluding extension)]
local SAVEAS="${DESDIR}${FILENAME}${EXTENSION}"		# [destination dir]/[filename].[extension]
local RECIPIENT="${3}"					# Recipient's public GPG hex key or email address
local NOERRORS="All error checking passed, encrypting tarball with ${RECIPIENT} public gpg key"

# Check to see if 4 arguments are provided for [source dir/file] [destination dir] [filename (excluding extension)] and [recipient email or key]
if [ $# != 3 ]
then
    echo
    echo "Usage: ${txtbld}${txtred}./encrypt_files.sh [source dir/file] [destination dir] [filename (excluding extension)] [recipient email or key]${txtrst}"
    echo
    exit 1
fi

# Check to see if the {SOURCE} exists
if [ ! -s ${SOURCE} ]
then
    echo
    echo "${SOURCE} ${txtbld}${txtred}does not exist or is empty!${txtrst}"
    echo
    exit 1
fi

# Check to see of the {DESDIR} exists and you have write permissions
# Variables for success/failure
SUCCESS="${DESDIR} created successfully"
FAILED="${txtbld}${txtred}Creation of${txtrst} ${DESDIR} ${txtbld}${txtred}failed! Check your permissions.${txtrst}"
if [ ! -w ${DESDIR} ]
then
    echo
    echo "${txtbld}${txtred}Destination directory${txtrst} ${DESDIR} ${txtbld}${txtred}does not exist or you do not have write permissions!${txtrst}"
    echo
    echo 'Attempt to create it? (Y/n)'
    read answer
    if [ ${answer} = 'Y' ]
    then
        mkdir -p ${DESDIR}
        # Check to see if directory was created successfully
        verify
    else
        echo
        echo "${txtbld}${txtred}Creation of${txtrst} ${DESDIR} ${txtbld}${txtred}declined... exiting...${txtrst}"
        echo
        exit 1
    fi
fi

# Check to see if the {SOURCE} is ~/.  If so, assumes to exclude ~/VirtualBox_VMs and ~/Truecrypt_Volumes
# Variables for success/failure
SUCCESS="Encrypted tarball of ${SOURCE} completed successfully and saved as ${SAVEAS}."
FAILED="${txtbld}${txtred}Tarball and encryption of${txtrst} ${SOURCE} ${txtbld}${txtred}failed!${txtrst}"
if [ ${SOURCE} = ~/ ]
then
    echo
    echo The SOURCE is ~/ so excluding ~/VirtualBox_VMs and ~/Truecrypt_Volumes.
    echo
    echo "${NOERRORS}"
    echo
    tar -cpJ --exclude ~/VirtualBox_VMs --exclude ~/Truecrypt_Volumes ${SOURCE} | gpg -e -r ${RECIPIENT} -o ${SAVEAS}
else
    echo
    echo The SOURCE is NOT ~/ so no exclusions have been made.
    echo
    echo "${NOERRORS}"
    echo
    tar -cpJ ${SOURCE} | gpg -e -r ${RECIPIENT} -o ${SAVEAS}
fi

# Check to see if tarball encryption was a success
verify

# Prompt to sign with detached signature
# Variables for success/failure
SUCCESS='GPG signature successful'
FAILED="${txtbld}${txtred}GPG signature failed!${txtrst}"
echo
echo 'Sign it with detached signature? (Y/n)'
read answer
if [ ${answer} = 'Y' ]
then
    gpg --armor --detach-sig ${SAVEAS}
    # Check to see if signing succeeded
    verify
    time_taken
else
    echo
    time_taken
    exit 0
fi

}

################## End encryption function   ##################
################## Begin decryption function ##################

decrypt () {

# Set function variables
local DECRYPT="${1}"				# [file to decrypt]
local DECRYPTED=${DECRYPT%.*}			# Removes .gpg from encrypted filename leaving .tar.xz (decryption only option)
local FILEOUTPUT=$(basename ${DECRYPTED})	# Removes path from {DECRYPTED} leaving just filename (decryption only option)
local OUTPUT=${DESDIR}${FILEOUTPUT}

# Check to see if extract directory was supplied

# Syntax of simple decryption and extraction
# gpg -d ${DECRYPT} | tar -xpJf - -C ${DESDIR}

# Syntax for decrypt only
# gpg -o ${OUTPUT} -d ${DECRYPT}

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

# Prompt for decryption only
# Variables for success/failure
SUCCESS="Decrypted ${DECRYPT} successfully and saved it as ${OUTPUT}"
FAILED="${txtbld}${txtred}Decryption of${txtrst} ${DECRYPT} ${txtbld}${txtred}failed!${txtrst}"
echo
echo "Only decrypt ${DECRYPT} as ${OUTPUT} (no extraction)? (Y/n)"
read answer
if [ ${answer} = 'Y' ]
then
    # Prompt to delete encrypted tarball ${DECRYPT} after decrypt
    echo
    echo "Delete encrypted tarball ${DECRYPT} after decryption? (Y/n)"
    read answer
    if [ ${answer} = 'Y' ]
    then
        gpg -o ${OUTPUT} -d ${DECRYPT} && rm ${DECRYPT}
    else
        gpg -o ${OUTPUT} -d ${DECRYPT}
    fi    
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

}

################## End decryption function ##################

# Begin Encryption or Decryption
if [ "${1}" = 'encrypt' ]
then
    encrypt ${2} ${4} ${5}
elif [ "${1}" = 'decrypt' ]
then
    decrypt ${2} ${3}
else
    echo
    echo "${txtbld}${txtred}Usage: ./encrypt-decrypt.sh encrypt (to encrypt) or ./encrypt-decrypt.sh decrypt (to decrypt)${txtrst}"
    echo
    exit 1
fi
#END