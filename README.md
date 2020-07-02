# Jumpbox

Creates a Digital Ocean Droplet to use as a jump host over SSH.
Forward all traffic and proxy DNS queries through remote server.
Upon terminating (ctrl+c) offer to destroy droplet to save that money!

## Requirements

1.  Digital Ocean account - if you do not already have one get [$100 credit for 60 days](https://m.do.co/c/49c621753ed3).
2.  doctl - a command line interface (CLI) for the DigitalOcean API: <https://www.digitalocean.com/docs/apis-clis/doctl/how-to/install/>.
3.  sshuttle - where transparent proxy meets VPN meets ssh[](https://sshuttle.readthedocs.io/en/stable/#sshuttle-where-transparent-proxy-meets-vpn-meets-ssh "Permalink to this headline") <https://github.com/sshuttle/sshuttle> - likely available in your distro's repo. (ie: apt-get install sshuttle)

## Configuration

After installing requirements:
Get your SSH FingerPrint with command:

    doctl compute ssh-key list

Example output:
ID          Name       FingerPrint
12345678    yourname   4d:23:e6:e4:8c:17:d2:cf:89:47:36:b5:c7:33:40:4e
Create config file:

    cp dojump.conf.default dojump.conf

Using your favorite text editor add your FingerPrint for example:

    DROPLET_SSH_KEYS="4d:23:e6:e4:8c:17:d2:cf:89:47:36:b5:c7:33:40:4e"

Some variables for creating Droplets are preset:

    ########################## PRESETS ##########################
    nyc1 is default but you can change to: nyc3 sfo2 sfo3 ams3 sgp1 lon1 fra1 tor1 blr1
    DROPLET_REGION="nyc1"

    You can change this but sshuttle need python3 and debian-10-x64 has it by default
    DROPLET_IMAGE="debian-10-x64"

    Smallest droplet does fine for our purpose $5/mo:
    DROPLET_SIZE="s-1vcpu-1gb"

## Usage

**Important: Make sure you do not have an existing Droplet named 'jumpbox' already**

    ./dojump.sh

When yo get  message:

    The authenticity of host 'xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx)' can't be established.

Type 'yes' to add new server to your known_hosts.

## Exit

Ctrl+c to exit, you will have an opportunity to destroy the droplet:

    client: Keyboard interrupt: exiting.
    Warning: Are you sure you want to delete this Droplet? (y/N) ?

Removes Droplet created (named jumpbox).
\*If you had network issues or your process aborted for some reason, you can try deleting the  Droplet manually:

    doctl compute droplet delete jumpbox

Or by logging in to your account and delete Droplet from there.

**If you choose the keep Droplet next time the script will resume using the same one.**
