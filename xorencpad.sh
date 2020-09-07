#! /bin/bash
# Warning: Best read if using a monospaced/fixed-width font and tab width of 4.
# --- This (Bash) script can be used to create/edit a "xorenc-encrypted" text file.
# ---
# --- Usage: script.sh <file.txt>
# --- 	If file does not exist, it is created and encrypted, otherwise it is decrypted then opened.
# ---
# --- Tools needed: xorenc, nano, sudo, shred
# ---
# ---
# --- This script is available under the MIT License (MIT).
# ---
# ---
# --- License:
# ---
# --- The MIT License (MIT)
# ---
# --- Copyright (c) 2020 Renan Souza da Motta <renansouzadamotta@yahoo.com>
# ---
# --- Permission is hereby granted, free of charge, to any person obtaining a copy of
# --- this software and associated documentation files (the "Software"), to deal in
# --- the Software without restriction, including without limitation the rights to
# --- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# --- the Software, and to permit persons to whom the Software is furnished to do so,
# --- subject to the following conditions:
# ---
# --- The above copyright notice and this permission notice shall be included in all
# --- copies or substantial portions of the Software.
# ---
# --- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# --- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# --- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# --- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# --- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# --- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
set -e

if [ "$1" == "check" ]; then
	# check for required tools
	echo -n "Checking for 'xorenc'..."
	xorenc --version > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'nano'..."
	nano --help > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'sudo'..."
	sudo --version > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'shred'..."
	shred --version > /dev/null 2>&1 && echo 'OK!'

	exit 0
fi


if [ "$#" -lt 1 ]; then
	# if number of user given commands is less than 1, show help message
	echo -e 'Usage:'
	echo -e '\tscript.sh <file.txt>\n'

	echo -e 'Example:'
	echo -e '\t./script.sh new.txt\n'

	echo -e "Run this script with 'check' to check if your system configuration is able to run this script."
	exit 2
fi


input_file=$1	# Input file
temp_folder="$HOME/.xorencpad"
user=$USER


# get directory's name of file
filedir=$(dirname "$filename")
# get input file name
filename=$(basename "$input_file")


# create a temporary file system (should be created in RAM)
mkdir -p "$temp_folder"
sudo mount -o size=8M -t tmpfs none "$temp_folder"
sudo chown $user:$user "$temp_folder"


# create new file if it does not exist
if [ ! -f "$input_file" ]; then
	# file does not exist, create it
	rm -r -f "$temp_folder/$filename" && touch "$temp_folder/$filename"
	nano -t "$temp_folder/$filename"

	# encrypt file, move it to disk, then delete temporary file system (which should be created in RAM)
	read -s -p 'Password: ' password && echo && \
	xorenc --stdout --key "$password" "$temp_folder/$filename" > "$input_file" 2>/dev/null && \
	shred -u "$temp_folder/$filename"

	sudo umount "$temp_folder" && \
	echo 'Done!'
else
	# file already exists, and it should be decrypted before editing
	read -s -p 'Password: ' password && echo && \
	xorenc --stdout --key "$password" "$input_file" > "$temp_folder/$filename" 2>/dev/null && \
	nano -t "$temp_folder/$filename"

	# encrypt file, move it to disk, then delete temporary file system (which should be created in RAM)
	xorenc --stdout --key "$password" "$temp_folder/$filename" > "$input_file" 2>/dev/null && \
	shred -u "$temp_folder/$filename"

	sudo umount "$temp_folder" && \
	echo 'Done!'
fi

