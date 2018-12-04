---
title: Dashboard
---

The dashboard shows all your available servers and recent history.
From here you can execute configured or predefined scripts adn templates.
You are able to execute multiple scripts on multiple servers.

If you are executing on multiple servers at the same time the execution will be done in parallel. 

If you are executing multiple scripts at the same time, they will be execute sequentially in order they were selected.

## Servers

Every time the dashboard is loaded Deployo will try to ping all of your servers.
If it succeds the server will be marked with a label `connected` in case pinging fails the server will be marked with `unreachable`.

Hovering over an `unreachable` label will give you more information about the error.

## History

The history displays the latest executions.

You can see which servers were involved and which scripts are executed alonside any provided variables.

From this view you can go to the execution output, re-execute the scripts or delete the history entry.