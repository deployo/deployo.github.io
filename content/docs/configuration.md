---
title: Configuration
---

The configuration page is the main place where you set up your servers and scripts. The entire configuration is a YAML file where you can configure everything that you need.

A YAML configuration file looks something like this:

```yaml
servers:
- name: production
  host: prod.deployo.me
  port: 22
  user: root
  password: root
  environment:
    ENV_VAR: var1
scripts:
- name: echo_variable
  commands:
  - echo "command"
  - echo $ENV_VAR
  variables:
  - ENV_VAR2
  environment:
    ENV_VAR3: var3
  workdir: /tmp
templates:
  - name: deploy_prod
    description: Deploy to production
    servers:
    - production
    scripts:
    - echo_variable
    variables:
      ENV_VAR2: value
cronjobs:
- schedule: '* * * * *'
  servers:
  - production
  scripts:
  - echo_variable
  variables:
    ENV_VAR2: value
  notifyOnFailed:
    email:
    - notification@email.com
```

It is consisted of these sections:

* [`servers`]({{< relref "#servers-section" >}})
* [`scripts`]({{< relref "#scripts-section" >}})
* [`templates`]({{< relref "#templates-section" >}})
* [`cronjobs`]({{< relref "#cronjobs-section" >}})

### Servers section

In this section you can configure all the servers you have. The configured servers will appear in the [dashboard]({{< relref "dashboard.md" >}}) where you will be able to execute your [scripts]({{< relref "#scripts" >}}).

The available options are:

Name | Description | Required | Type | Default value
--- |--- |--- |--- |---
name | name of your server to be displayed on the dashboard. Should be all lowercase without special or space characters. | yes | string | n/a
host | the address of your server. Can be IP or a host name. | yes | string | n/a
port | port of the server | no | number | 22
user | user that will be used by Deployo to ssh in the the server. | yes | string | n/a
password | password that will be used by Deployo to ssh in the the server. A [secret]({{< relref "#secrets" >}}) can also be used as a password. If there is an SSH key configured for a server the password can be omitted. * | no | string |
environment | a list of environment variable that will be available during execution of scripts. | no | map of string to string |

* In case both SSH key and password are configured the password will be used first.

### Scripts section

In this section you can configure all the scripts you have. The configured scripts will appear in the [dashboard]({{< relref "dashboard.md" >}}) where you will be able to execute your them on a selected [server]({{< relref "#servers" >}}).

The available options are:

Name | Description | Required | Type | Default value
--- |--- |--- |--- |---
name | name of your script to be displayed on the dashboard. Should be all lowercase without special or space characters. | yes | string | n/a
commands | an array of commands that will be executed on a server in the given order. | yes | array of strings | [ ]
variables | a list of variables required from the user for execution of scripts. When a script is triggered from the dashboard a value for every variable will be required. Empty values are allowed. | no | array of strings | [ ]
environment | a list of environment variable that will be available during execution of scripts. | no | map of string to string |
workdir | a directory on the server where the script will start execution. Every command will start from here. | no | string | /

In case both a server and a script have the same environment variable exposed, the value from the script will take precedence. The reason for this is that the server will export the variable first and then the script will export its own after that thus overriding the servers variable.

If a script is requiring a variable to be provided and the name of the variable is the same as an environment variable in the script the script environment variable will take precedence.

Script environment variable > User-provided variable > Server environment variable

### Templates section

Here you can define templates, or more precisely, combinations of servers, scripts and variables. This is useful if you plan to often execute a certain combination.

Name | Description | Required | Type | Default value
--- |--- |--- |--- |---
name | name of your script to be displayed on the dashboard. Should be all lowercase without special and space characters. | yes | string | n/a
description | User friendly description | no | string | n/a
servers | List of server names | yes | array of strings | n/a
scripts | List of script names | yes | array of strings | n/a
variables | a list of variables required from the user for execution of scripts. When a script is triggered from the dashboard a value for every variable will be required. Empty values are allowed. | no | array of strings | [ ]

### Cronjobs section

Here you can define cronjobs. By using familiar crontab notation you can periodically execute combinations of servers, scripts and variables.

Name | Description | Required | Type | Default value
--- |--- |--- |--- |---
schedule | Definition of when this job should be executed using [Crontab notation](https://en.wikipedia.org/wiki/Cron#Overview). | yes | string | n/a
servers | List of server names | yes | array of strings | n/a
scripts | List of script names | yes | array of strings | n/a
variables | a list of variables required from the user for execution of scripts. When a script is triggered from the dashboard a value for every variable will be required. Empty values are allowed. | no | array of strings | [ ]
notifyOnFailed | An object with a list of emails to receive notification if cronjob fails. | no | object (see example above) | empty object
