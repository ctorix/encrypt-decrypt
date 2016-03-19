# encrypt-decrypt.sh

   encrypt-decrypt.sh is a simple shell script for encrypting and decrypting files or directories using GPG keys.

# Basic encryption syntax:

   ./encrypt-decrypt.sh encrypt [source] [destination directory] [filename to save as (excluding any extensions)] [recipient's public GPG key or email address] (optional: [any directories/files to exclude])

Sample:

   ./encrypt-decrypt.sh encrypt ~/ /tmp/encrypted_files/ my_first_file no@email.com ~/do_not_include_this_dir

   This will tar and encrypt ~/ (excluding the directory ~/do_not_include_this_dir) with no@email.com's public gpg key, place the encrypted file in /tmp/encrypted_files/ (offering to create it if it doesn't exist) and name it my_first_file_{today's date}.tar.xz.gpg

# Basic decryption syntax:

   ./encrypt-decrypt.sh decrypt [source] (Optional: [destination directory])

Sample:

   ./encrypt-decrypt.sh decrypt /tmp/encrypted_files/my_first_file_20160316.tar.xz.gpg /tmp/decrypted_files/

   This will offer 2 different options during decryption 1) Decrypt only as a tar.xz 2) Decrypt and extract to /tmp/decrypted_files/

   The result: my_first_file_20160316.tar.xz.gpg will be decrypted and placed into /tmp/decrypted_files/ as either the tar.xz file or be fully extracted