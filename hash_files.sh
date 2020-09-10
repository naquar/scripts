#! /bin/bash
# Warning: Best read if using a monospaced/fixed-width font and tab width of 4.
# --- This (Bash) script hashes ALL FILES in current directory and output hashes to text file.
# ---
# --- Usage: script.sh <hash_algo>
# --- 	Possible values for 'hash_algo': MD5, SHA1, SHA224, SHA256, SHA384, SHA512, BLAKE2
# ---
# --- Tools needed: tr, find, md5sum, sha1sum, sha224sum, sha256sum, sha384sum, sha512sum, b2sum
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

	echo -n "Checking for 'tr'..."
	if tr --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	echo -n "Checking for 'find'..."
	if find --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	echo -n "Checking for 'md5sum'..."
	if md5sum --version > /dev/null 2>&1; then
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

	echo -n "Checking for 'sha224sum'..."
	if sha224sum --version > /dev/null 2>&1; then
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

	echo -n "Checking for 'sha384sum'..."
	if sha384sum --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	echo -n "Checking for 'sha512sum'..."
	if sha512sum --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	echo -n "Checking for 'b2sum'..."
	if b2sum --version > /dev/null 2>&1; then
		echo 'OK!'
	else
		echo 'NOT FOUND!';
		code=1;
	fi

	exit $code
fi


# if insufficient number of commands were given show help message
if [ $# -eq 0 ]; then
	echo -e 'Usage:'
	echo -e '\tscript.sh <hash_algo>\n'
	echo -e "\t\tPossible values for 'hash_algo': MD5, SHA1, SHA224, SHA256, SHA384, SHA512, BLAKE2\n"

	echo -e '\tExample: script.sh SHA256\n'

	echo -e "Run this script with 'check' to check if your system configuration is able to run this script."
	exit 2
fi


# check if hash algorithm given is valid for this script
hash_tool=$(echo "$1" | tr 'A-Z' 'a-z')

if [ "$hash_tool" != 'md5' ] && [ "$hash_tool" != 'sha1' ] && [ "$hash_tool" != 'sha224' ] && [ "$hash_tool" != 'sha256' ] && [ "$hash_tool" != 'sha384' ] && [ "$hash_tool" != 'sha512' ] ; then
	if [ "$hash_tool" != 'blake2' ]; then
		echo 'Invalid hash tool.'

		exit 2
	else
		# hash tool for BLAKE2 is 'b2sum'
		hash_tool='b2'
	fi
fi

hash_tool=$hash_tool'sum'


# the second line hashes the string 'hello\n' with selected hash tool and runs the next command if successful
rm -f $hash_tool && \
echo 'hello' | $hash_tool > /dev/null && \
find ./ -type f -exec $hash_tool {} + > '/tmp/SwR8bqEBvGSriAXEWsDHPSqKr2NmBcE4.sum' && \
mv '/tmp/SwR8bqEBvGSriAXEWsDHPSqKr2NmBcE4.sum' $hash_tool && \
chmod a+r-wx $hash_tool && \
echo -e "Hashes saved to '$hash_tool'.\nYou can run '$hash_tool --quiet -c $hash_tool' to check files."

