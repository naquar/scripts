#! /bin/bash
# Warning: Best read if using a monospaced/fixed-width font and tab width of 4.
# --- This (Bash) script archives, compresses, encrypts, and outputs file to current directory.
# ---
# --- Usage: script.sh <input_file/folder> <compression> <encryption> <operation>
# --- 	Possible values for "compression": none, gzip, bzip2, xz, sz, lz4
# --- 	Possible values for "encryption": 1=blowfish, 2=twofish, 3=aes-256
# ---	Possible values for "operation": archive, extract
# ---
# --- Tools needed: tar, gpg, xz, bzip2, gzip, snzip, lz4
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
	echo -n "Checking for 'tar'..."
	tar --version > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'gpg'..."
	gpg -h > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'xz'..."
	xz --version > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'gzip'..."
	gzip --version > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'bzip2'..."
	bzip2 --version > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'snzip'..."
	snzip -h > /dev/null 2>&1 && echo 'OK!'

	echo -n "Checking for 'lz4'..."
	lz4 -V > /dev/null 2>&1 && echo 'OK!'

	exit 0
fi


if [ "$#" -lt 4 ]; then
	# if number of user given commands is less than 4, show help message
	echo -e 'Usage:'
	echo -e '\tscript.sh <input_file/folder> <compression> <encryption> <operation>\n'

	echo -e '\t\tPossible values for "compression": none, gzip, bzip2, xz, sz, lz4'
	echo -e '\t\tPossible values for "encryption": 1=blowfish, 2=twofish, 3=aes-256'
	echo -e '\t\tPossible values for "operation": archive, extract\n'

	echo -e 'Example:'
	echo -e '\t./script.sh folder gzip 3 archive\n'

	echo -e "Run this script with 'check' to check if your system configuration is able to run this script."
	exit 2
fi


filename=$1	# Input file or folder
suffix=$2	# Compression type
cipher=$3	# To list available ciphers, run: gpg -h
op=$4		# Operation (archive or extract)


# set cipher
if [ $cipher -eq 1 ]; then
	cipher='BLOWFISH'
	else if [ $cipher -eq 2 ]; then
		cipher='TWOFISH'
		else if [ $cipher -eq 3 ]; then
			cipher='AES256'
			# if no valid cipher is given, use AES-256
			else
				echo -n "Invalid cipher specified ($cipher). Using default: ";
				cipher='AES256';
				echo -e "$cipher";
		fi
	fi
fi


# get directory's path of file/folder
directory=$(dirname "$filename")
# get input file/folder name
input_filename=$(basename "$filename")


# archive using specified compression
if [ "$suffix" == 'none' ]; then
	# check for operation...
	if [ "$op" == 'archive' ]; then
		# archive, encrypt, and write to file
		tar -C "$directory" -c -p "$input_filename" --to-stdout | \
		gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > "$input_filename".tar.gpg && echo 'Done!'
	else if [ "$op" == 'extract' ]; then
		# decrypt, and extract files from archive
		gpg -d "$filename" | tar -x && echo 'Done!'
	fi
	fi

	exit
fi


# archive using specified compression
if [ "$suffix" == 'gzip' ]; then
	# check for operation...
	if [ "$op" == 'archive' ]; then
		# archive, compress, encrypt, and write to file
		tar -C "$directory" -c -p "$input_filename" --to-stdout | \
		gzip --best --stdout | \
		gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > "$input_filename".tar.gz.gpg && echo 'Done!'
	else if [ "$op" == 'extract' ]; then
		# decrypt, and extract files from archive
		gpg -d "$filename" | tar -x -z && echo 'Done!'
	fi
	fi

	exit
fi


if [ "$suffix" == 'bzip2' ]; then
	# check for operation...
	if [ "$op" == 'archive' ]; then
		# archive, compress, encrypt, and write to file
		tar -C "$directory" -c -p "$input_filename" --to-stdout | \
		bzip2 --compress --best --stdout | \
		gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > "$input_filename".tar.bz2.gpg && echo 'Done!'
	else if [ "$op" == 'extract' ]; then
		# decrypt, and extract files from archive
		gpg -d "$filename" | tar -x -j && echo 'Done!'
	fi
	fi

	exit
fi


if [ "$suffix" == 'xz' ]; then
	# check for operation...
	if [ "$op" == 'archive' ]; then
		# archive, compress, encrypt, and write to file
		tar -C "$directory" -c -p "$input_filename" --to-stdout | \
		xz '--extreme' '-9' '--threads=0' '-c' '-v' | \
		gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > "$input_filename".tar.xz.gpg && echo 'Done!'
	else if [ "$op" == 'extract' ]; then
		# decrypt, and extract files from archive
		gpg -d "$filename" | tar -x -J && echo 'Done!'
	fi
	fi

	exit
fi


if [ "$suffix" == 'sz' ]; then
	# check for operation...
	if [ "$op" == 'archive' ]; then
		# archive, compress, encrypt, and write to file
		tar -C "$directory" -c -p "$input_filename" --to-stdout | \
		snzip -t framing2 -R $((1024*16)) -W $((1024*12)) -c | \
		gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > "$input_filename".tar.sz.gpg && echo 'Done!'
	else if [ "$op" == 'extract' ]; then
		# decrypt, and extract files from archive
		gpg -d "$filename" | snzip -d -c | tar -x && echo 'Done!'
	fi
	fi

	exit
fi


if [ "$suffix" == 'lz4' ]; then
	# check for operation...
	if [ "$op" == 'archive' ]; then
		# archive, compress, encrypt, and write to file
		tar -C "$directory" -c -p "$input_filename" --to-stdout | \
		lz4 -z -9 | \
		gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > "$input_filename".tar.lz4.gpg && echo 'Done!'
	else if [ "$op" == 'extract' ]; then
		# decrypt, and extract files from archive
		gpg -d "$filename" | lz4 -d | tar -x && echo 'Done!'
	fi
	fi

	exit
fi

