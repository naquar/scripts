#! /bin/bash
# Warning: Best read if using a monospaced/fixed-width font and tab width of 4.
# --- This (Bash) script splits a file into several parts to current folder.
# ---
# --- Usage: script.sh <input_file> <n_parts> <optional:custom_chunk_size?>
# ---
# --- Tools needed: split, cat, sha1sum, sha256sum, openssl
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
	code=0

	echo -n "Checking for 'split'..."
	if split --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	echo -n "Checking for 'cat'..."
	if cat --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	echo -n "Checking for 'sha1sum'..."
	if sha1sum --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	echo -n "Checking for 'sha256sum'..."
	if sha256sum --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	echo -n "Checking for 'openssl'..."
	if openssl version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	exit $code
fi

if [ "$#" -lt 2 ]; then
	# if number of user given commands is less than 2, show help message
	echo -e 'Usage:'
	echo -e '\tscript.sh <input_file> <n_parts>\n'

	echo -e 'Example:'
	echo -e '\t./script.sh big_file.bin 3\n'

	echo -e 'If you prefer to slice the file to a specific maximum size just give the desired size (in bytes) followed by "true" as third option:'
	echo -e '\t./script.sh big_file.bin 25000000 true\n'

	echo -e "Run this script with 'check' to check if your system configuration is able to run this script."
	exit 2
fi


input_file="$1"
filedir=$(dirname "$input_file")
filename=$(basename "$input_file")


# Slice input file in chunks
if [ "$3" != 'true' ]; then
	split -n "$2" -a 3 --numeric-suffixes=1 "$1" "$filename"'.' && \
	echo -e "You can join files back by running:\n\tcat '$filename'.* > '$filename'\n"
else
	split --bytes="$2" -a 3 --numeric-suffixes=1 "$1" "$filename"'.' && \
	echo -e "You can join files back by running:\n\tcat '$filename'.* > '$filename'\n"
fi


# Generate hashes for input file
echo -e 'Generating hashes...'

input_file_sha1sum=$(sha1sum "$input_file" | grep -o -P '^[0-9a-fA-F]*');
echo -e "SHA-1: $input_file_sha1sum"

input_file_sha256sum=$(sha256sum "$input_file" | grep -o -P '^[0-9a-fA-F]*');
echo -e "SHA-256: $input_file_sha256sum"

input_file_ripemd160sum=$(openssl dgst -ripemd160 "$input_file" | grep -o -P '(?<=\s)[0-9a-fA-F]*(?=$)');
echo -e "RIPEMD-160: $input_file_ripemd160sum\n"


echo -e "After joining the file back, check if its checksum matches with the ones specified above."

