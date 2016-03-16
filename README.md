# encrypt-decrypt.sh

   encrypt-decrypt.sh is a simple shell script for encrypting and decrypting files using GPG keys.

# Basic encryption syntax:

   ./encrypt-decrypt.sh [source] [destination] [filename to save as (excluding any extensions)] [recipient's public GPG key or email address] (optional: [any directories/files to exclude]

Sample:

   ./encrypt-decrypt.sh ~/ /tmp/encrypted_files/ my_first_file no@email.com ~/do_not_include_this_dir

   This will tar and encrypt ~/ with no@email.com's public gpg key, exclude the directory ~/do_not_include_this_dir, place it in the /tmp/encrypted_files/ (offering to create it if it doesn't exist) and name it my_first_file.{today's date}.tar.xz.gpg

# Important:

   Make sure your [destination] ends with a / (should only apply if your destination doesn't already exist)

   If you're excluding directories remember to leave the trailing / off of the path to exclude (see example above)

# Basic decryption syntax:

   ./encrypt-decrypt.sh decrypt [source] (Optional: [destination])

# Sample:

   ./encrypt-decrypt.sh decrypt /tmp/encrypted_files/my_first_file_20160316.tar.xz.gpg /tmp/decrypted_files/

   This will offer 2 different options during decryption 1) Decrypt only as tar.xz 2) Decrypt and extract to /tmp/decrypted_files/

   The result will be: my_first_file_20160316.tar.xz.gpg will be decrypted and place into /tmp/decrypted_files/ as either the tar.xz file or fully extracted