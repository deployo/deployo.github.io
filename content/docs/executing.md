---
Title: Executing
---
## Executing scripts

When you run a script you will be prompted for any user input configured for the sctript you are running that will manifest itself as an environment variale. After you enter everything you need Deployo will SSH into the chosen server export all environment variables and run the selected script.

You will be able to follow the execution as Deployo directly streams output from your servers using websockets.

## Viewing output of older executions

By clicking on the output icon on the dashboard you will see the deploy page of the selected deploy.

The deploy page is displaying your deploy parameters like environment variables, data, duration of execution, server.... and most importantly your script execution output.

From this view you can re-run the sscript using the same parameters without having to type them again.