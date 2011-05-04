#!/bin/bash

# scup 0.1 - a simple scp uploader
# 04.05.2011 - Tobias Birmili
#
# This script uploads screenshots via scp to a server and puts the
# HTTP location in the OS X clipboard. The local screenshot is then
# moved to a backup directory. It can handle multiple screenshots in
# one run.
#
# You can also specify a file as an argument wich will be uploaded.
#
# Original script by Lysander Trischler <software@lyse.isobeef.org>

CONFIG=$HOME/.scup
[ -f $CONFIG ] && . $CONFIG || {
	echo "$CONFIG not found, generating new one." >&2
	cat > $CONFIG <<EOF
#!/bin/bash
#
# Configuration file for scup

# Local screenshots filter
# should include the files you want to upload if no
# specific file is specified as argument
SCREENSHOTS=~/Desktop/Screen*.png

# Domain and directory for displaying uploaded files
# Please add the trailing slash
DOMAIN=http://example.com/screen/

# SCP host name
HOSTNAME=example.com

# SCP user login name
USERNAME=user

# SCP server directory where to put the files
DIRECTORY=public_html

# scup working directory
# directory in which scup will work and leave a backup of the
# uploading files. No trailing slash please.
TEMPDIR=/tmp/scup
EOF
	${EDITOR:=vim} $CONFIG
	echo "[scup] start $0 again to upload your files"
	exit 2
}

# create temporary folders if they don't exist yet
if [ ! -d "$TEMPDIR" ]; then
	mkdir "$TEMPDIR"
fi

if [ ! -d "$TEMPDIR/backup" ]; then
	mkdir "$TEMPDIR/backup"
fi

if [ ! -d "$TEMPDIR/queue" ]; then
	mkdir "$TEMPDIR/queue"
fi


if [[ ! -n $1 ]]; then
   # no argument, try to upload screenshots
   # move and rename all screenshots into the temp directory
   for SCREENSHOT in $SCREENSHOTS
   do
   	# terminate script when no screenshots are available to upload
   	if [ "$SCREENSHOT" == "$SCREENSHOTS" ]
   	then
   		echo "[scup] no screenshots to upload."
   		exit 3
   	fi
   	# create unique name 
   	NEWNAME=`md5 < "$SCREENSHOT"`
   	# copy screenshot to workingdirectory
   	cp "$SCREENSHOT" "$TEMPDIR/queue/$NEWNAME.png"
   	# keep a backup of the original file
   	mv "$SCREENSHOT" "$TEMPDIR/backup/"
   done; 
else
   cp $1 "$TEMPDIR/queue/"
fi


# build the clipboard content
echo "[scup] building link list"
for FILE in $TEMPDIR/queue/*
do
	FILES="${FILES}${DOMAIN}`basename $FILE`"$'\n'
done

# upload the files with scp
echo "[scup] uploading file"
scp $TEMPDIR/queue/* $USERNAME@$HOSTNAME:$DIRECTORY || exit $?

# remove the uploaded files on local disc
echo "[scup] emptying queue"
rm $TEMPDIR/queue/*

# copy string of files into clipboard if in osx
if [[ $OSTYPE = "darwin10.0" ]]; then
   echo "[scup] copying URL to clipboard"
   echo "$FILES"|pbcopy
fi

# print URLs of uploaded files for convenience
echo -n "$FILES"