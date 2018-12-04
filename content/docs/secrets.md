---
title: Secrets
---
This is a safe way to store sensitive data. Every project has its own dedicated set of secrets that can be used in the configuration file.

All secrets have the same prefix (`SECRET_`) and can be referenced in the commands section of the scripts and as a password for a server.

Secrets will never be exposed in logs or in the execution output of deploys.

Any collaborator can toggle secret visibility in the UI.