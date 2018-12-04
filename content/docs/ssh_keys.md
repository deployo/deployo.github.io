---
title: SSH Keys
---
SSH keys allow you to connect to your server without using a password.
If an SSH key is not configured the password will be used.

**In case both a password and an SSH keys have been configured the password will be used first**.

On this page you have a preview of all the keys stored by Deployo. You can see SSH keys connected to a server or keys that are not connected to any servers anymore. You can see following sections:

* Servers with Keys
* Servers without Keys
* Unused Keys
* Upload Private Key

## Servers with Keys

Here you have a list of SSH keys connected to a server, this key will be used to connect to your server alongside with the user that is configured in the configuration for that server.
You can load the keys to see the public key and a convenient command for quickly [adding that key to your server]({{< relref "#adding-a-generated-private-key-to-your-server" >}}).

## Servers without Keys

These servers have no SSH keys connected to them. Deployo will stray to SSH into them using the password.

## Unused Keys

These are the SSH keys connected to server that do not exist anymore. By changing a server name to match the server name used for the key the server will take over the SSH key and will continue to use it.

## Upload Private Key

Here you can upload any private keys you have already generated. This allows you to continue to use your public-private key-pair that you have and that is already configured to work with your server.

## Adding a generated private key to your server

After you uploaded an already existing private key or generated a new one you have to authorize that key on your server. You do this by adding the key to the `authorized_keys` file located in the `.ssh` folder in your home folder. A convenient bash command is displayed next to every private key that allows you to do this easily. The necessary steps are:

* generate or upload a private key
* click `Show keys` button to display the keys for the selected server
* bellow the `Command` label there is a bash command
* copy that command
* open your terminal and paste the command into it
* hit `ENTER`
* you will be prompted to enter a password of the configured user for the server
* enter the password and hit `ENTER`
* your SSH keys should now be authorized and Deployo will now use them every time it connects to the server

Example of the command:

```bash
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6+5JAwOILJlav
+OPtYR2BnckbKUT6MxkTCCxCU09dWZewQLP242bShn7lvuDTu+bsiccBkX0/Sq4T4gXZOM3vkgUlrV6G
+N48V5vMs4XHFoiu5AS3bTit+UvN2REo3XqH5M/uzKQX5b+VbJY/DzU6IBHWvs3xHZu3r+mnsoqGh6ouerk4brVPYd
+DkGMUlltnYN4PJleREKxtLY8NMTP+ut1dreBKchQUwxsMr+moXzIWbV2oVaoVIQ96JDx7
+b6Cu4Iaf3N/esfwo4U0OvPd7pC1pxx2RKzXzBgdwTjBnbzBvhYvXp6HoO/UfSAV95bgnslnjZb4DRjZTFoYGJ5P
root@localhost" | ssh -p 22 user@server "[ -d ~/.ssh ] || mkdir ~/.ssh && cat >>
~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```