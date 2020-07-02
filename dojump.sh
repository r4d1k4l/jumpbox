#!/bin/bash

# Fancy error message
show_error() {
  echo -e "\e[01;31m$1\e[0m"
}

# Obtain remote IP
get_droplet_ip(){
  DROPLET_IP=$(doctl compute droplet list | grep jumpbox | awk '{print $3}')
}

# Start sshuttle
sshuttle_start(){
  get_droplet_ip
  if [ -z "$DROPLET_IP" ]; then
    show_error "ERROR: Could not determine Droplet's IP address."
    show_error "Perhaps not enough time to start remote SSH server, try again..."
    exit 1
  fi
  echo "Tunneling all network traffic via $DROPLET_IP";
  sshuttle --dns -r root@$DROPLET_IP 0/0
}

# Check if requirements doctl and sshuttle are installed
if ! command -v doctl &> /dev/null
then
  show_error "ERROR: doctl could not be found. Installation instructions:"
  echo "https://www.digitalocean.com/docs/apis-clis/doctl/how-to/install"
  exit
fi

if ! command -v sshuttle &> /dev/null
then
  show_error "ERROR: sshuttle could not be found. Installation instructions:"
  echo "https://github.com/sshuttle/sshuttle"
  exit
fi

# Read config
PDIR=$(dirname $(readlink -f $0))
CONFIG="$PDIR/dojump.conf"

if [ -e $CONFIG -a -r $CONFIG ]; then
  source $CONFIG
  if [ "$VERBOSE" == "true" ]; then
    echo "Parsing config file..."
  fi
else
  show_error "No configuration file found, creating it for you"
  cp -v $CONFIG.default $CONFIG
  echo "Please edit $CONFIG before running again."
  exit 0
fi

# Remote SSH FingerPrint is a must
# Get it with: doctl compute ssh-key list
if [ -z "$DROPLET_SSH_KEYS" ]; then
  show_error "ERROR: Set up DROPLET_SSH_KEYS in $CONFIG!"
  exit 1
fi

# Check if we are using existing Droplet or creating new one
get_droplet_ip

if [ -z "$DROPLET_IP" ]; then

  echo -n "Creating new Droplet, please wait..."

  doctl compute droplet create \
    --region $DROPLET_REGION \
    --image $DROPLET_IMAGE \
    --size $DROPLET_SIZE \
    --ssh-keys $DROPLET_SSH_KEYS \
    --wait jumpbox > /dev/null 2>&1

  echo " done"
  echo "Just a few more seconds until remote SSH server starts..."

  SECS=15
  while [ $SECS -gt 0 ]; do
    echo -ne "$SECS\033[0K\r"
    sleep 1
    : $((SECS--))
  done

  sshuttle_start

else
  echo "Found existing droplet named 'jumpbox', resuming..."
  sshuttle_start
fi

# Upon exiting (ctrl+c) offer to destroy droplet to save that money!
doctl compute droplet delete jumpbox
