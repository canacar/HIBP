#!/bin/sh
# 
# Copyright (c) 2021 Can Acar
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# 
# pwquery.sh: Query the Pwned Passwords database for each input line.
# 
# The Have I Been Pwned provides a range search interface that protects the
# password being searched.
# The API is described here: https://haveibeenpwned.com/API/v3#PwnedPasswords

# Select your favorite command to make HTTPS requests.
# OpenBSD ftp client in base works without additional packages
# curl and wget are more portable and can also set the padding header. 
FETCH='ftp -Vo -'
#FETCH='wget -q --header="Add-Padding: true" -O -'
#FETCH='curl -s -H "Add-Padding: true" -o -'

# Select the command to compute a SHA-1 hash in "coreutils" format
HASH='sha1'
#HASH='sha1sum'
#HASH='openssl dgst -sha1 -r'

while read l; do
    h=$(echo -n "$l"|$HASH|cut -d\  -f1) # SHA-1 hash of the password
    p=$(printf "%.5s" $h)  # Key: first 5 digits
    s=${h#$p}              # Suffix to search for in the output
    m=$((sh -c "$FETCH https://api.pwnedpasswords.com/range/$p"||echo Failed!) | grep -i "$s" ||echo Not found!)
    n=$(echo $m|sed 's/.*:\([0-9]*\)/\1 instances/')
    echo PW: $l -- $n
    sleep 1.6             # API requires waiting 1500ms between requests
done
