---
title: Manage Dokku on Linode using Deployo
date: 2018-02-22
---

I will show you how to install and use Dokku on a Linode instance and manage all that using Deployo.

First you need to create a Linode instance. I chose the cheapest one which is only 5$ a month.

After selecting an instance and clcking "Add this Linode!" button, your server will be created.
Initially the server is empty, there is no operating system or anything there at all. To be able run anything on the node we have to install an operating system by deploying an Image. I chose to deploy ubutu 16.04 LTS because it is the most stable ubuntu available at the moment. I chose Ubuntu because there is a huge community of developers using Ubuntu and there is almost no problem that somebody already did not have and has not already fixed.

Now when the OS is installed your machine is in "Powered Off" state, click the "Boot" button to start it up.

## Configure Deployo and install Dokku

While the machine is starting configure the server in Deployo. We set up the password for now, but we will configure SSH keys soon.

```yaml
servers:
- name: linode_dokku
  host: 198.58.123.61
  port: 22
  user: root
  password: <your root password>
```

You can visit Dokku at http://dokku.viewdocs.io/dokku/ to get the command to install Dokku on your machin. I did this for you, the command is:

```bash
# for debian systems, installs dokku via apt-get
$ wget https://raw.githubusercontent.com/dokku/dokku/v0.11.3/bootstrap.sh
$ sudo DOKKU_TAG=v0.11.3 bash bootstrap.sh
# go to your server's IP and follow the web installer
```

We will use these commands to configure a Deployo script and will replace the version with a variable. This variable will allow us to switch out versions for the script more easily in the future.

```yaml
scripts:
- name: install_dokku
  commands:
  - wget https://raw.githubusercontent.com/dokku/dokku/$VERSION/bootstrap.sh
  - sudo DOKKU_TAG=$VERSION bash bootstrap.sh
  variables:
  - VERSION
```

Now that we have a server and a script let us make a template that rounds all of this up.

```yaml
templates:
- name: install_dokku
  description: Install Dokku to linode server
  servers:
  - linode_dokku
  scripts:
  - install_dokku
  variables:
    VERSION: v0.11.3
```

Now go to the Deployo dashboard, you should see your template. The server status should be green (connected). Click the Deploy button of your template and the execution will start.

![Install Dokku](/img/blog/manage-dokku-on-linode-using-deployo/Selection_731.png "Deployo dashboard")

After arround 4 minutes Dokku should be install on your server. Visit you server IP (in my case it is 198.58.123.61) to finish the installation.

![Dokku Installation](/img/blog/manage-dokku-on-linode-using-deployo/Selection_737.png "Dokku setup")

Note: do not use you Deployo generated SSH key for Dokku, this key is going to be used by Deployo to connect to your server. For Dokku you should use your SSH key from your personal laptop/desktop.

#### Optional step - Assign an SSH key to your server

We can configure Deployo to use an SSH key every time it connects to your server. This way you can remove the password from your configuration. To assign an SSH key to your server and use it go to the SSH Keys page and generate SSH keys for the `linode_dokku` server. When the keys get generated you will be provided with a command that you can execute to quickly add this key to you servers `authorized_keys` file. Paste the following script in your terminal window and hit ENTER.

```bash
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7pGgHZfFl0+R7w+bjpllwteyI/rUv0Hw+5WpZUwJsE8VvzpTBsOR57SGdv9vSyrzY+o0KaoWOh2t56QUg4Bs4rw/Z8a6F7MfuQS7n1Zp01jj9Ff04eSZ7ljZ+vIIB+cW6Fg98giQU6uDlloR36sBO4y8nRmzli7Lyg54TZI6FPsIFu1NMh+1997CkTlPAJiIb/u4f0bgxD69e2hzFWQ0QpPrufKKz+/kMsXDwA9fX8bgg08gHjA6Gl4K1RKLg5vAxanRqHHCt+uJJt+NCru2MAgNdHSGgElGuH6Tbz7V6mr+z5yHD1ZURJa0obwv645NLfWzcvcTk7//CaxCqRyun root@198.58.123.61" | ssh -p 22 root@198.58.123.61 "[ -d ~/.ssh ] || mkdir ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

When asked to continue connecting, choose yes:

```bash
Are you sure you want to continue connecting (yes/no)? yes
```

You will be prompted for a password, enter the root password you used when creating your linode and that should be it.

Now you can go to your Deployo configuration and remove the password, your freshly generated SSH keys will be used.

## Create a Dokku app

Let's create an app on Dokku. Go to your Deployo configuration and add another script:

```yaml
scripts:
- name: create_dokku_app
  commands:
  - dokku apps:create $APP_NAME
  variables:
  - APP_NAME
```

By providing a value for the APP_NAME variable we will be able to choose a name for the app. Click the "New Deploy" button in Deployo Dashboard and select your server, the "create_dokku_app" script and write down the name you would like to use, I chose to use the name from the Dokku documentation "ruby-rails-sample".

![New Deploy](/img/blog/manage-dokku-on-linode-using-deployo/Selection_733.png "Execute a new Deploy")

Let's now add a couple of more scripts so we can setup a database for our Dokku app:

Install the Postgres plugin:

```yaml
scripts:
- name: install_dokku_postgres_plugin
  commands:
  - sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git
```

Create a postgres service with the name rails-database:

```yaml
scripts:
- name: create_dokku_postgres_database
  commands:
  - dokku postgres:create $DB_NAME
  variables:
  - DB_NAME
```

Link the application with the database:

```yaml
scripts:
- name: link_dokku_postgres_database
  commands:
  - dokku postgres:link $DB_NAME $APP_NAME
  variables:
  - DB_NAME
  - APP_NAME
```

Run these commands from the Deployo dashboard by clicking the "New Deploy" button and filling up the fields. For the name of the database choose "rails-database".

You could also combine all of the scripts in a template:

```yaml
templates:
- name: create_dokku_postgres_app
  description: Create Dokku app with postgres
  servers:
  - linode_dokku
  scripts:
  - install_dokku_postgres_plugin
  - create_dokku_app
  - create_dokku_postgres_database
  - link_dokku_postgres_database
  variables:
    DB_NAME: rails-database
    APP_NAME: ruby-rails-sample
```

## Deploy Dokku app

Now from you local machine clone the Dokku demo app:

```bash
git clone git@github.com:heroku/ruby-rails-sample.git
```

On your local mashine execute the next commands:

```bash
cd ruby-rails-sample
git remote add dokku dokku@198.58.123.61:ruby-rails-sample
git push dokku master
```

Dokku will deploy your app now. After it is done you should get an address of your application, it should look something like:

```bash
=====> Application deployed:
       http://198.58.123.61:59826
```

Open that addres in you browser and you should see your app deployed.

![Recapitulation](/img/blog/manage-dokku-on-linode-using-deployo/Selection_734_small.png "Dokku demo app")

That is it! You now have a Linode server managed by Deployo.

We used Deployo to prepare your server, install dependencies and create apps. You can see all that we did in History on the Deployo Dashboard.

![Recapitulation](/img/blog/manage-dokku-on-linode-using-deployo/Selection_735.png "Deployo History will all of our commands")

You can now maintain your server from anywhere just by accessing Deployo!

Happy Deployo-ing!