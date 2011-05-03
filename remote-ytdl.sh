#!/bin/bash

# remote-ytdl 0.1
# 03.05.2011 - Tobias Birmili
#
# A very simple wrapper for the awesome youtube-dl script
# http://rg3.github.com/youtube-dl/
#
# It initiates youtube-dl on the remote host, then downloads
# the file via rsync and finally deletes the file on the remote
# host. It's useful if your ISP limits your YouTube bandwidth.
#
# Requirements:
#     - a working youtube-dl script on the remote host
#     - SSH access at the remote host set up to work without
#           interactive password entry
#     - Videos of cats on Youtube


CONFIG=$HOME/.remote-ytdl
[ -f $CONFIG ] && . $CONFIG || {
	echo "[remote-ytdl] $CONFIG not found, generating new file" >&2
	cat > $CONFIG <<EOF
#!/bin/bash
#
# Configuration file for remote-ytdl


# SSH access credentials
# you must have key-authentication set up
REMOTE_SERVER=yourhost.tld
REMOTE_USER=myname

# writable directory on the remote host
REMOTE_TMP="/tmp"

# you may specify the full path to the script
REMOTE_YTDL_SCRIPT="youtube-dl"

EOF
	${EDITOR:=vim} $CONFIG
	echo "[remote-ytdl] created configuration file $CONFIG"
	echo "[remote-ytdl] start $0 again to download the file."
	exit 2
}

if [[ ! -n $1 ]] ; then
   echo "usage: $0 url"
   exit 0
fi

URL=$1
FILENAME=$(youtube-dl --get-filename -t "$URL")

echo "[remote-ytdl] downloading $FILENAME on remote host"
ssh $REMOTE_USER@$REMOTE_SERVER "cd $REMOTE_TMP; $REMOTE_YTDL_SCRIPT -t \"$URL\""

if [[ ! $? -eq 0 ]]; then
   echo "[remote-ytdl] error on remote server while downloading"
   echo "[remote-ytdl] exiting now"
   exit 1;
fi

echo "[remote-ytdl] copying remote file to local host"
rsync --progress $REMOTE_USER@$REMOTE_SERVER:$REMOTE_TMP/$FILENAME ./


echo "[remote-ytdl] deleting file on remote server"
ssh $REMOTE_USER@$REMOTE_SERVER "rm $REMOTE_TMP/$FILENAME"

echo "[remote-ytdl] Success: $FILENAME"