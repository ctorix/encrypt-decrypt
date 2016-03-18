#!/bin/bash
#Purpose = tar/encrypt and decrypt with public gpg keys
#Created on 03-04-2016
#Author = Cade Torix
#START

# Syntax
# Encryption
# encrypt [Source] [Destination directory] [Filename] [Recipient email or hex key] (optional: [Directories/files to exclude])
#
# Decryption
# decrypt [File to decrypt] (optional: [Destination directory])

# Set start time
START=$(date +%s)

# Define text formatting variables:
txtbldred=$(tput bold && tput setaf 1)	# Bold & Red
txtrst=$(tput sgr0)       		# Text reset

# Array loop to add --exclude directories from tar
EXCLUDES=()    				# start with an empty array
for EXCL in "${@:6}"			# for each extra argument...
do
    EXCLUDES+=(--exclude "${EXCL}")    	# add an exclude to the array
done

# Set exclusions variable
EXCLUSIONS="${EXCLUDES[@]}"

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

# Function to check to see if DESDIR ends in / (should only apply to new directories)
desdir_check () {
if [ "${DESDIR: -1}" != "/" ] && [ ! -z ${DESDIR} ]
then
    DESDIR="${DESDIR}/"
fi
}

################## Begin encryption function ##################

encrypt () {
# Set function variables
local DATE=$(date +%Y%m%d)				# Setting the date used in filename extension
local SOURCE="${1}"					# [source dir/file]
local EXTENSION="_${DATE}.tar.xz.gpg"			# Setting the file extension
local DESDIR="${2}"					# [destination directory]
desdir_check						# Check DESDIR for ending /
local FILENAME="${3}"					# [filename (excluding extension)]
local SAVEAS="${DESDIR}${FILENAME}${EXTENSION}"		# [destination dir]/[filename].[extension]
local RECIPIENT="${4}"					# Recipient's public GPG hex key or email address
local NOERRORS="All error checking passed, encrypting tarball with ${RECIPIENT} public gpg key"

# Check to see if at least 4 arguments are provided for [source dir/file] [destination dir] [filename (excluding extensions)] and [recipient email or key]
if [ $# != 4 ]
then
    echo
    echo "Usage: ${txtbldred}./encrypt_files.sh [source dir/file] [destination dir] [filename (excluding extensions)] [recipient email or key] (optional: [dirs/files to exclude])${txtrst}"
    echo
    exit 1
fi

# Check to see if the {SOURCE} exists
if [ ! -s ${SOURCE} ]
then
    echo
    echo "${SOURCE} ${txtbldred}does not exist or is empty!${txtrst}"
    echo
    exit 1
fi

# Check to see of the {DESDIR} exists and you have write permissions
# Variables for success/failure
SUCCESS="${DESDIR} created successfully"
FAILED="${txtbldred}Creation of${txtrst} ${DESDIR} ${txtbldred}failed! Check your permissions.${txtrst}"
if [ ! -w ${DESDIR} ]
then
    echo
    echo "${txtbldred}Destination directory${txtrst} ${DESDIR} ${txtbldred}does not exist or you do not have write permissions!${txtrst}"
    echo
    echo 'Attempt to create it? (y/N)'
    read answer
    if [ "${answer,,}" = 'y' ]
    then
        mkdir -p ${DESDIR}
        # Check to see if directory was created successfully
        verify
    else
        echo
        echo "${txtbldred}Creation of${txtrst} ${DESDIR} ${txtbldred}declined... exiting...${txtrst}"
        echo
        exit 1
    fi
fi

# Check to see if exclude arguments were provided
# Variables for success/failure
SUCCESS="Encrypted tarball of ${SOURCE} completed successfully and saved as ${SAVEAS}."
FAILED="${txtbldred}Tarball and encryption of${txtrst} ${SOURCE} ${txtbldred}failed!${txtrst}"
if [ ! -z "${EXCLUSIONS}" ]
then
    echo
    echo "Running with ${EXCLUSIONS}"
    echo
    echo "${NOERRORS}"
    echo
    tar -cpJ ${EXCLUSIONS} ${SOURCE} | gpg -e -r ${RECIPIENT} -o ${SAVEAS}
else
    echo
    echo 'No directories or files provided to exclude'
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
FAILED="${txtbldred}GPG signature failed!${txtrst}"
echo
echo 'Sign it with detached signature? (Y/n)'
read answer
if [ "${answer,,}" = 'y' ] || [ -z ${answer} ]
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
local DESDIR="${2}"				# [destination directory]
#desdir_check					# Check DESDIR for ending /
local DECRYPTED=${DECRYPT%.*}			# Removes .gpg from encrypted filename leaving .tar.xz (decryption only option)
local FILEOUTPUT=$(basename ${DECRYPTED})	# Removes path from {DECRYPTED} leaving just filename (decryption only option)
local OUTPUT=${DESDIR}${FILEOUTPUT}

# Check to see if destination directory was supplied
if [ -z "${DESDIR}" ]
then
    DESDIR=$(pwd)
fi

# Check to see number of arguments provided for [file to decrypt] and [destination directory]
if [ $# = 1 ]
then
    echo
    echo "${txtbldred}No destination directory provided!${txtrst}"
    echo "${txtbldred}Destination directory will be:${txtrst} ${DESDIR}"
    echo
elif [ $# != 2 ]
then
    echo
    echo "Usage: ${txtbldred}./decrypt_files.sh [file to decrypt] (optional: [destination directory])${txtrst}"
    echo
    exit 1
fi

# Check to see if {DESDIR} exists and is writable
# Variables for success/failure
SUCCESS="Creation of ${DESDIR} successful"
FAILED="${txtbldred}Creation of${txtrst} ${DESDIR} ${txtbldred}failed! Check your permissions${txtrst}"
if [ ! -w ${DESDIR} ]
then
    echo
    echo "${DESDIR} ${txtbldred}does not exist or you do not have write permissions!${txtrst}"
    # Offer to create ${DESDIR}
    echo
    echo 'Attempt to create it? (y/N)'
    read answer
    if [ "${answer,,}" = 'y' ]
    then
        mkdir -p ${DESDIR}
        verify
    else
        echo
        echo "${txtbldred}Creation of${txtrst} ${DESDIR} ${txtbldred}declined... exiting...${txtrst}"
        echo
        exit 1
    fi
fi

# Prompt for decryption only
# Variables for success/failure
SUCCESS="Decrypted ${DECRYPT} successfully and saved it as ${OUTPUT}"
FAILED="${txtbldred}Decryption of${txtrst} ${DECRYPT} ${txtbldred}failed!${txtrst}"
echo
echo "Only decrypt ${DECRYPT} as ${OUTPUT} (no extraction)? (y/N)"
read answer
if [ "${answer,,}" = 'y' ]
then
    # Prompt to delete encrypted tarball ${DECRYPT} after decrypt
    echo
    echo "Delete encrypted tarball ${DECRYPT} after decryption? (y/N)"
    read answer
    if [ "${answer,,}" = 'y' ]
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
FAILED="${txtbldred}Decryption of${txtrst} ${DECRYPT} ${txtbldred}failed!${txtrst}"
echo
echo "Delete encrypted tarball ${DECRYPT} after decrypt and extraction? (y/N)"
read answer
if [ "${answer,,}" = 'y' ]
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
    encrypt ${2} ${3} ${4} ${5}
elif [ "${1}" = 'decrypt' ]
then
    decrypt ${2} ${3}
else
    echo
    echo "${txtbldred}Usage: ./encrypt-decrypt.sh encrypt (to encrypt) or ./encrypt-decrypt.sh decrypt (to decrypt)${txtrst}"
    echo
    exit 1
fi
#END