#!/bin/sh

#  Copyright (C) 2021 Andriy Dobush <andriyd@nvidia.com>
#
#  SPDX-License-Identifier:     GPL-2.0

#
# Sign file with gpg secret key
#

GPG_SIGN_SECRING=$1
FILE=$2

usage() {
    cat <<EOF
$0: Usage
$0 <gpg secret key file> <file>

Create detached gpg signature for <file> with <gpg secret key>
EOF
}

[ -r $GPG_SIGN_SECRING ] || {
    echo "Error: secret key file is not specified"
    usage
    exit 1
}

[ -r $FILE ] || {
    echo "Error: file for sign is not specified"
    usage
    exit 1
}

# Kill gpg agent to prevent sporadic gpg errors, related to running script in combination with fakeroot
killall gpg-agent

set -e
GPG_KEY_ID=$(gpg --openpgp --import "${GPG_SIGN_SECRING}" 2>&1 | \
	grep -m 1 "gpg: key"| sed -e 's/.*key \(.*\): .*/\1/')
gpg -v --default-key "${GPG_KEY_ID}" --yes --detach-sign --output ${FILE}.sig  ${FILE}
