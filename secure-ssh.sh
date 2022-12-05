#!/usr/bin/env bash

# Run this script from its working directory for relative file paths
# Specify a username using $1, E.G. `sudo ./secure-ssh.sh newuser`

# Create new user using $1
useradd $1

# Create .ssh directory
sshdir="/home/$1/.ssh"
mkdir -p $sshdir

# Add all pubkeys to authorized_keys
for f in ../pubkeys/*; do
	  # Only add key if it isn't current host key
	    if [[ "$(cat $f)" =~ $(hostname)$ ]]; then
		        echo "Skipping $f, current host key..."
			  else
				      echo "Appending $f to authorized_keys"
				          cat $f >> $sshdir/authorized_keys
					    fi
				    done

				    # Fix permissions for .ssh
				    chmod 700 $sshdir
				    chmod 600 $sshdir/authorized_keys
				    chown -R $1:$1 $sshdir

				    # Disable root SSH if not already disabled
				    # This will work regardless of what it is currently set to
				    sed -i "s/^#PermitRootLogin/PermitRootLogin/" /etc/ssh/sshd_config
				    sed -i "/^PermitRootLogin/s/yes/no/" /etc/ssh/sshd_config
