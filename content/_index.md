---
title: Web based shell execution tool
hero:
  subtitle: Simplify your
  typewriter:
    - server management.
    - shell executions.
    - scheduled jobs.
  title: A web based shell execution tool.
  call_to_action: Create Account For Free
meta:
  description: A web based shell execution tool that uses SSH to connect to your servers. Simplify your deployments or remote shell executions.
overview:
  title: Execute commands over SSH with a button click.
  summary: It is perfectly suited for personal projects, freelancers or small companies looking to speed up their remote tasks.
screenshot: /img/frame-chrome-mac.png
call_to_action: Create Account For Free
features:
- title: Configure easily with YAML
  description: All your configuration is stored online in a simple YAML file. Easily edit with syntax highlighting.
  image: /img/configuration.gif
  video: /img/configuration.mp4
  style: light
  inverted: true
- title: Execute shell scripts
  description: Run your scrips easily with live output streamed directly from your server. You can configure multiple servers and multiple scripts.
  image:  /img/deploy.gif
  video:  /img/deploy.mp4
  style: white
- title: Deploy preconfigured templates
  description: Configure templates for your combinations of servers, scripts and variables that you execute most often.
  image: /img/template_multiple_scripts.gif
  video: /img/template_multiple_scripts.mp4
  style: light
  inverted: true
teaser:
  title: Join other freelancers and companies that are already making their life simpler.
  description: Deployo is available on all devices with a browser. With your configuration safely stored online you are able to deploy your software or setup servers easily and conveniently.
  image: /img/demo.gif
more_features:
- title: Keep history
  description: History of all your script executions is shown right on your dashboard. You can access old executions and execute again the same script with same parameters with ease.
  icon: fas fa-book
- title: Access from anywhere
  description: Deployo is a web based solution accessible from any device with a browser. So desktop, tablet or mobile, it is at your fingertips.
  icon: fas fa-mobile-alt
- title: Cronjobs
  description: Schedule your tasks using standard crontab notation. Run your scripts in configured intervals. You can see cronjobs in history and preview the output like with any other execution.
  icon: far fa-clock
- title: Connect using SSH keys
  description: Your SSH keys can be generated and stored online and used everytime you acces your server. Have a private key already? Just upload it!
  icon: fas fa-lock
plans:
    - title: Free
      features:
        - 1 server
        - 2 scripts
        - 10 entries in history
        - Passwords
        - Deploy Templates
        - 5 minutes execution time
      price: $0
      style: info
    - title: Hobbyist
      features:
        - 3 servers
        - 10 scripts
        - 1 000 entries in history
        - Passwords
        - SSH keys
        - Deploy Templates
        - Cronjobs
        - 30 minutes execution time
      price: $14
      style: link
    - title: Professional
      features:
        - 10 servers
        - 50 scripts
        - 10 000 entries in history
        - Passwords
        - SSH keys
        - Deploy Templates
        - Cronjobs
        - 60 minutes execution time
        - Priority Support
        # - Metrics
      price: $24
      style: info
roadmap:
    - title: Webhooks
      description: Run scripts triggered by webhooks from GitHub or Bitbucket.
      icon: fas fa-puzzle-piece
    - title: Slack integration
      description: Run scripts triggered directly from Slack.
      icon: fab fa-slack-hash
    - title: CLI
      description: A command-line tool for running your scripts from your terminal.
      icon: fas fa-terminal
---
