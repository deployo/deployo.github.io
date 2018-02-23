---
title: Install and Manage Dokku on Linode
date: 2018-02-22
slug: install-and-manage-dokku-on-linode
---

I will show you how to install and use Dokku on a Linode instance. I will be using [Deployo](https://deployo.me) to manage the server but you can also just SSH into the server and execute the same commands.

First you need to create a Linode instance. Go to [linode.com](https://www.linode.com/?r=a353c3bb9c2ebc925fe7a565fb81cb5a2378120f) and create an account if you do not already have one. When you login you will be taken to your linode manager view where you will be offered to create a linode instance.

{{< figure src="/img/blog/dokku-on-linode/Selection_738.png" caption="Linode manager" alt="Linode manager" width="740px" >}}

After selecting an instance and clicking "Add this Linode!" button at the bottom of the page, your server will be created.

Initially the server is empty, there is no operating system or anything there at all. To be able run anything on the server we have to install an operating system by deploying an Image. I chose to deploy ubutu 16.04 LTS because it is the most stable ubuntu available at the moment. I chose Ubuntu because there is a huge community of developers using Ubuntu and there is almost no problem that somebody already did not have and has not already fixed.

Now when the OS is installed your server is in "Powered Off" state, click the "Boot" button to start it up.

## Configure Deployo and install Dokku

While your server is starting lets configure it in Deployo. We set up the password for now, but we will configure SSH keys soon.

{{< highlight yaml >}}
servers:
- name: linode_dokku
  host: 198.58.123.61
  port: 22
  user: root
  password: <your root password>
{{< /highlight >}}

You can visit Dokku at http://dokku.viewdocs.io/dokku/ to get the command to install Dokku on your machin. I did this for you, the command is:

{{< highlight bash >}}
$ wget https://raw.githubusercontent.com/dokku/dokku/v0.11.3/bootstrap.sh
$ sudo DOKKU_TAG=v0.11.3 bash bootstrap.sh
{{< /highlight >}}

We will use these commands to configure a Deployo script and will replace the version with a variable. This variable will allow us to switch out versions for the script more easily in the future.

{{< highlight yaml >}}
scripts:
- name: install_dokku
  commands:
  - wget https://raw.githubusercontent.com/dokku/dokku/$VERSION/bootstrap.sh
  - sudo DOKKU_TAG=$VERSION bash bootstrap.sh
  variables:
  - VERSION
{{< /highlight >}}

Now that we have a server and a script let us make a template that rounds all of this up.

{{< highlight yaml >}}
templates:
- name: install_dokku
  description: Install Dokku to linode server
  servers:
  - linode_dokku
  scripts:
  - install_dokku
  variables:
    VERSION: v0.11.3
{{< /highlight >}}

Now go to the Deployo dashboard, you should see your template. The server status should be green (connected). Click the Deploy button of your template and the execution will start.

{{< figure src="/img/blog/dokku-on-linode/Selection_731.png" caption="Install Dokku" alt="Install Dokku" width="740px" >}}

After arround 4 minutes Dokku should be install on your server. Visit you server IP (in my case it is 198.58.123.61) to finish the installation.

{{< figure src="/img/blog/dokku-on-linode/Selection_737.png" caption="Dokku Installation" alt="Dokku Installation" width="740px" >}}

Note: do not use you Deployo generated SSH key for Dokku, this key is going to be used by Deployo to connect to your server. For Dokku you should use your SSH key from your personal laptop/desktop.

#### Optional step - Assign an SSH key to your server

We can configure Deployo to use an SSH key every time it connects to your server. This way you can remove the password from your configuration. To assign an SSH key to your server and use it go to the SSH Keys page and generate SSH keys for the `linode_dokku` server. When the keys get generated you will be provided with a command that you can execute to quickly add this key to you servers `authorized_keys` file. Paste the following script in your terminal window and hit ENTER.

{{< highlight bash >}}
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7pGgHZfFl0+R7w+bjpllwteyI/rUv0Hw+5WpZUwJsE8VvzpTBsOR57SGdv9vSyrzY+o0KaoWOh2t56QUg4Bs4rw/Z8a6F7MfuQS7n1Zp01jj9Ff04eSZ7ljZ+vIIB+cW6Fg98giQU6uDlloR36sBO4y8nRmzli7Lyg54TZI6FPsIFu1NMh+1997CkTlPAJiIb/u4f0bgxD69e2hzFWQ0QpPrufKKz+/kMsXDwA9fX8bgg08gHjA6Gl4K1RKLg5vAxanRqHHCt+uJJt+NCru2MAgNdHSGgElGuH6Tbz7V6mr+z5yHD1ZURJa0obwv645NLfWzcvcTk7//CaxCqRyun root@198.58.123.61" | ssh -p 22 root@198.58.123.61 "[ -d ~/.ssh ] || mkdir ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
{{< /highlight >}}

When asked to continue connecting, choose yes:

{{< highlight text >}}
Are you sure you want to continue connecting (yes/no)? yes
{{< /highlight >}}

You will be prompted for a password, enter the root password you used when creating your linode and that should be it.

Now you can go to your Deployo configuration and remove the password, your freshly generated SSH keys will be used.

## Create a Dokku app

Let's create an app on Dokku. Go to your Deployo configuration and add another script:

{{< highlight yaml >}}
scripts:
- name: create_dokku_app
  commands:
  - dokku apps:create $APP_NAME
  variables:
  - APP_NAME
{{< /highlight >}}

By providing a value for the APP_NAME variable we will be able to choose a name for the app. Click the "New Deploy" button in Deployo Dashboard and select your server, the "create_dokku_app" script and write down the name you would like to use, I chose to use the name from the Dokku documentation "ruby-rails-sample".

{{< figure src="/img/blog/dokku-on-linode/Selection_733.png" caption="New Deploy" alt="New Deploy" width="740px" >}}

Let's now add a couple of more scripts so we can setup a database for our Dokku app:

Install the Postgres plugin:

{{< highlight yaml >}}
scripts:
- name: install_dokku_postgres_plugin
  commands:
  - sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git
{{< /highlight >}}

Create a postgres service with the name rails-database:

{{< highlight yaml >}}
scripts:
- name: create_dokku_postgres_database
  commands:
  - dokku postgres:create $DB_NAME
  variables:
  - DB_NAME
{{< /highlight >}}

Link the application with the database:

{{< highlight yaml >}}
scripts:
- name: link_dokku_postgres_database
  commands:
  - dokku postgres:link $DB_NAME $APP_NAME
  variables:
  - DB_NAME
  - APP_NAME
{{< /highlight >}}

Run these commands from the Deployo dashboard by clicking the "New Deploy" button and filling up the fields. For the name of the database choose "rails-database".

You could also combine all of the scripts in a template:

{{< highlight yaml >}}
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
{{< /highlight >}}

## Deploy Dokku app

Now from you local machine clone the Dokku demo app:

{{< highlight bash >}}
git clone git@github.com:heroku/ruby-rails-sample.git
{{< /highlight >}}

On your local mashine execute the next commands:

{{< highlight bash >}}
cd ruby-rails-sample
git remote add dokku dokku@198.58.123.61:ruby-rails-sample
git push dokku master
{{< /highlight >}}

Dokku will deploy your app now. After it is done you should get an address of your application, it should look something like:

{{< highlight text >}}
=====> Application deployed:
       http://198.58.123.61:59826
{{< /highlight >}}

Open that addres in you browser and you should see your app deployed.

{{< figure src="/img/blog/dokku-on-linode/Selection_734_small.png" caption="Dokku demo app" alt="Dokku demo app" >}}

That is it! You now have a Linode server managed by Deployo.

We used Deployo to prepare your server, install dependencies and create apps. You can see all that we did in History on the Deployo Dashboard.

{{< figure src="/img/blog/dokku-on-linode/Selection_735.png" caption="Deployo History with all of our commands" alt="Deployo History with all of our commands" width="860px" >}}

You can now maintain your server from anywhere just by accessing Deployo!

Happy Deployo-ing!