#!/bin/sh -e

DIRNAME=`dirname $0`
pushd $DIRNAME
USAGE="$0 [ --update ]"
if [ `id -u` != 0 ]; then
echo 'You must be root to run this script'
popd
exit 1
fi

if [ $# -eq 1 ]; then
	if [ "$1" = "--update" ] ; then
		time=`ls -l --time-style="+%x %X" howdy_jessicarod.te | awk '{ printf "%s %s", $6, $7 }'`
		rules=`ausearch --start $time -m avc --raw -se howdy_jessicarod`
		if [ x"$rules" != "x" ] ; then
			echo "Found avc's to update policy with"
			echo -e "$rules" | audit2allow -R
			echo "Do you want these changes added to policy [y/n]?"
			read ANS
			if [ "$ANS" = "y" -o "$ANS" = "Y" ] ; then
				echo "Updating policy"
				echo -e "$rules" | audit2allow -R >> howdy_jessicarod.te
				# Fall though and rebuild policy
			else
				popd
				exit 0
			fi
		else
			echo "No new avcs found"
			popd
			exit 0
		fi
	else
		echo -e $USAGE
		popd
		exit 1
	fi
elif [ $# -ge 2 ] ; then
	echo -e $USAGE
	popd
	exit 1
fi

echo "Building Policy"
set -x
make -f /usr/share/selinux/devel/Makefile howdy_jessicarod.pp || exit
popd

# Fixing the file context on /usr/lib64/security/howdy
# /usr/sbin/semodule -i howdy_jessicarod.pp
# Generate a man page of the installed module
# sepolicy manpage -p . -d howdy_jessicarod_t
# /sbin/restorecon -Rv /usr/lib64/security/howdy/