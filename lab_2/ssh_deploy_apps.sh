#!/bin/bash

SERVER_HOST_DIR=./nestjs-rest-api
CLIENT_HOST_DIR=./shop-angular-cloudfront
SERVER_REMOTE_DIR=/var/app/server
CLIENT_REMOTE_DIR=/var/www/client
SSH_ALIAS=ubuntu-sshuser

check_remote_dir_exists() {
  echo "Check if remote directories exist"

  if ssh $SSH_ALIAS "[ ! -d $1 ]"; then
    echo "Creating: $1"
	  ssh -t $SSH_ALIAS "sudo bash -c 'mkdir -p $1 && chown -R sshuser: $1'"
  else
    echo "Clearing: $1"
    ssh $SSH_ALIAS "sudo -S rm -r $1/*"
  fi
}

check_remote_dir_exists $SERVER_REMOTE_DIR
check_remote_dir_exists $CLIENT_REMOTE_DIR

echo "---> Building and copying server files - START <---"
echo $SERVER_HOST_DIR
cd $SERVER_HOST_DIR && npm run build
scp -Cr dist/ package.json $SSH_ALIAS:$SERVER_REMOTE_DIR
echo "---> Building and transfering server - COMPLETE <---"

cd ../

echo "---> Building and transfering client files, cert and ngingx config - START <---"
echo $CLIENT_HOST_DIR
cd $CLIENT_HOST_DIR && npm run build && cd ../
scp -Cr $CLIENT_HOST_DIR/dist/* ssl_cert/ nginx.conf $SSH_ALIAS:$CLIENT_REMOTE_DIR
echo "---> Building and transfering - COMPLETE <---"
