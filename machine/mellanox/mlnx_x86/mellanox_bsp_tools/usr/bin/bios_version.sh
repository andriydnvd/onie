# Copyright (C) 2017 Mellanox Technologies, Ltd. All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# description: Shows BIOS version

#!/bin/sh

log=/var/log/messages

get_bios_version()
{
	ver=$(dmidecode -t0 | grep -m1 Version | awk '{print $2}')

# In new project BIOS Subversion is provided over SMBios type11 OEM String1
# In old project (0ABZS) BIOS Subversion was provided over SMBios type2
	subver=$(dmidecode -t2 | grep -m1 Version | awk '{$1=""; print $0}' | cut -b 2-)
	if echo "$subver" | grep -vq "0ABZS"
	then
		subver=$(dmidecode -t11 | grep -m1 "String 1:" | awk '{$1=""; $2="";print $0}' | cut -b 3-)
		if echo "$subver" | grep -q "O.E.M"
		then
			subver="Official AMI Release"
		fi
	fi

	rel=$(dmidecode -t0 | grep -m 1 'Release Date' | awk '{print $3}')
}

show_version()
{
	echo -e "\nBIOS Version:\t\t" "$ver" | tee -a $log
	echo -e "BIOS Release Date:\t" "$rel" | tee -a $log
	echo -e "BIOS SubVersion:\t" "$subver" | tee -a $log
}

get_bios_version
show_version		

exit 0
