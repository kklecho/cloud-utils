#!/bin/bash

# usage: sudo addawsinstanceuser username groupname githublogin
# synopsis: Allows creating new user with ssh access based on github-stored public key
# why: better security 
# why more: 
#  1. After spinning new AWS EC2 instance, by default you have a root user access & it's private key 
#  2. It's more secure if you don't use that default root user for your day-to-day operations with the instance
#  3. It's better to create another user and make it sudoer
#  4. At that point you should hide your root private key some place else.
#  5. This way if your personal computer gets compromised, the thieves will only be able to ssh with your sudoer user
#  6. They will have to know password to make superuser operations
#  7. It's still really really bad if that happens, but the root user is worse.

#validate params
die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "3 arguments required, $# provided"
echo $1 | grep -E -q '^[a-zA-Z]+[a-zA-Z0-9]*$' || die "Valid username required, $1 provided"
echo $2 | grep -E -q '^[a-zA-Z]+[a-zA-Z0-9]*$' || die "Valid groupname required, $2 provided"
echo $3 | grep -E -q '^[a-zA-Z]+[a-zA-Z0-9]*$' || die "Valid github login required, $3 provided"


username=$1
group=$2
githubusername=$3

sudo adduser --disabled-password --gecos "" $username
sudo usermod -aG $group $username

if [ "$githubusername" != "" ] 
then
	sudo mkdir /home/$username/.ssh
	sudo touch /home/$username/.ssh/authorized_keys
	curl https://github.com/$githubusername.keys | sudo tee -a /home/$username/.ssh/authorized_keys
	sudo chown -R kkl /home/$username/.ssh
	sudo chmod 600 /home/$username/.ssh/authorized_keys
fi
