---
title: Configuration
---

The configuration page is the main place where you set up your servers and scripts. The entire configuration iss a YAML file where you can configure everything that you need.

# YAML

A basic YAML configuration file would looks something like this:

```yaml
servers:
- name: local
  host: localhost
  port: 2222
  user: root
  password: root
  environment:
    ENV_VAR: var1
scripts:
- name: name
  commands:
  - echo "command"
  - echo $ENV_VAR
  variables:
  - ENV_VAR2
  environment:
    ENV_VAR3: var3
  workdir: /tmp
```

It is consisted of these sections:

* [`servers`]({{< relref "#servers" >}})
* [`scripts`]({{< relref "#scripts" >}})

## Servers

In this section you can configure all the servers you have. The configured servers will appear in the [dashboard]({{< relref "dashboard.md" >}}) where you will be able to execute your [scripts]({{< relref "#scripts" >}}).

The available options are:

Name | Description | Required | Type | Default value
--- |--- |--- |--- |---
name | name of your server to be displayed on the dasboard. Should be all lowercase without special characters. | yes | string | n/a
host | the addrest of your server. Can be IP or a host name. | yes | string | n/a
port | port of the server | no | number | 22
user | user that will be used by Deployo to ssh in the the server. | yes | string | n/a
password | password that will be used by Deployo to ssh in the the server. If there is an SSH key configured for a server the password can be ommited. * | no | string |
environment | a list of environment variable that will be available during execution of scripts. | no | map of string to string |

* In case both SSH key and password are configured the password will be used first.

## Scripts

In this section you can configure all the scripts you have. The configured scripts will appear in the [dashboard]({{< relref "dashboard.md" >}}) where you will be able to execute your them on a selected [server]({{< relref "#servers" >}}).

The available options are:

Name | Description | Required | Type | Default value
--- |--- |--- |--- |---
name | name of your script to be displayed on the dasboard. Should be all lowercase without special characters. | yes | string | n/a
commands | an array of commands that will be executed on a server in the given order. | yes | array of strings | [ ]
variables | a list of variables required from the user for execution of scripts. When a script is triggered from the dashboard a value for every variable will be required. Empty values are allowed. | no | array of strings | [ ]
environment | a list of environment variable that will be available during execution of scripts. | no | map of string to string |
workdir | a directory on the server where the script will start execution. Every command will start from here. | no | string | /

In case both a server and a script have the same environment variable exposed, the value from the script will take precedence. The reason for this is that the server will export the variable first and then the script will export its own after that thus overriding the servers variable.

If a script is requiring a variable to be provided and the name of the variable is the same as an environment variable in the script the script environement variable will take precedance.

Script environment variable > User-provided variable > Server environment variable