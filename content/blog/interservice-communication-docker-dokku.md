---
title: Interservice communication with Docker and Dokku
date: 2018-06-01
slug: interservice-communication-docker-dokku
author: Miloš Krsmanović
---

Dokku is a wonderfull tool if you want to run you own Heroku-like platform where you can host a number of your applications. It helps you set up your deployment, database connection, nginx configuration and even SSL with Let's Encrypt.

Dokku makes runing your application and connecting it to a database very easy, but what if you have multiple applications that need to talk to each other?

Let's say that you have an application and a database. Your application can talk to your database without a problem using the DATABASE_URL environment variable provided by Dokku, after linking your database to your application. In this case, I wrote everything in Golang just because I like it, but this approach works with any language, of course.

Everything the application, named `db-checker`, is doing is pingin the database to check if it is still available.

{{< highlight golang >}}
package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()
	if err := db.Ping(); err != nil {
		fmt.Printf("DB is not available. Error: %v", err)
		return
	}
	fmt.Println("DB is available")
}
{{< /highlight >}}

We can run this app buy executing `dokku --rm run db-checker` and see if our application can access the database or not.

So far so good.

Now let's make this more interesting by introducing a web application that should expose an http endpoint so we can check if the database is available using the web browser. We will connect our apps and database like this:

{{< figure src="/img/blog/interservice-communication-docker-dokku/diagram.png" caption="A diagram of our apps" alt="A diagram of our apps" width="740px" >}}

We need to change our `db-checker` application so it now exposes an http endpoint called `/ping` which will execute the Ping method like before but this time it will return a status code.

{{< highlight golang >}}
package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	http.Handle("/ping", ping(db))
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func ping(db *sql.DB) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if err := db.Ping(); err != nil {
			w.WriteHeader(http.StatusFailedDependency)
			return
		}
		w.WriteHeader(http.StatusOK)
	})
}
{{< /highlight >}}

We extract the Pinging functionality into an `http.Handler` function that has a pointer to the database that we injected. We initialize the handler and attatch it to the `/ping` endpoint so it is executed every time we call `/ping`.

We introduce a new application, cleverly called `web`.

{{< highlight golang >}}
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	url := os.Getenv("CHECK_DB_URL")
	http.Handle("/check_db", checkDB(url))
	log.Fatal(http.ListenAndServe(":9090", nil))
}

func checkDB(url string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		resp, err := http.Get(url)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			fmt.Fprintf(w, "could not check if DB is available: %v", err)
			return
		}
		if resp.StatusCode != http.StatusOK {
			fmt.Fprint(w, "DB is not available")
			return
		}
		fmt.Fprint(w, "DB is available")
	})
}
{{< /highlight >}}

What the application is doing is exposing an http endpoint called `/check_db` which should contact the `db-checker` and tell us if the database is available or not.

The address of the `db-checker` is provided using an environment variable called `CHECK_DB_URL` which is provided using Dokku command `dokku config:set web CHECK_DB_URL=http://db-checker/ping`.

Now if we ran both of these applications and tried to access `web` and its `/check_db` endpoint it would return an error with something along the lines of: `dial tcp: lookup db-checker on 127.0.0.11:53: no such host`

The reason for this is that our `web` application does not know the address of `db-checker`.

Since both of our applications are actually Docker containers we can create links between `web` and `db-checker` with something like:

{{< highlight golang >}}
dokku docker-options:add web deploy "--link db-checker.web.1:db-checker"
{{< /highlight >}}

This solution works, with one caveat. In case you want to scale the `db-checker` (wich makes no sense in our use-case but let's pretend it does for the sake of this blog post) our link is not good enough because `web` can only to talk to one container (`db-checker.web.1`) and it is not able to access other contaners (ther names would be `db-checker.web.2`, `db-checker.web.3`, ... and so on).

What we can do (if we use a Docker version 1.11 or up) is put all containers in a user defined Docker network and put a Docker network alias on `db-checker` app so that every container of this app running in this network has this alias.
Our `web` application is now able to use this alias to talk to one (any) `db-checker` container. Which `db-checker` container is accessed depends on the internal Docker DNS but they will be load balanced in a round-robin way by Docker (with some limitiations).

What we need to do to make this works is:

{{< highlight bash >}}
#  create a network called "demo"
docker network create demo

# configure application to run in "demo" network 
dokku docker-options:add web deploy "--net demo"
dokku docker-options:add db-checker deploy "--net demo"

# set an alias to "db-checker"
dokku docker-options:add db-checker deploy "--net-alias db-checker"

# add database container to the "demo" network
docker network connect demo dokku.postgres.db
{{< /highlight >}}

With this we create a Docker network called `demo`, we add a docker-option so both our applications are running in this network. We then set an alias for `db-checker` and connect our database container called `dokku.postgres.db` to the `demo` network.

Now if you try to access the `/check_db` endpoint of our `web` application you get status 200 and a message "DB is available".

You only need to execute these commands once because `Dokku` will save them in special files made just for your app called DOCKER_OPTIONS_DEPLOY. You can execute the commands directly in the terminal, have them in a bash script or run them using [Deployo](https://deployo.me). The next time you deploy your app the `Docker` options will be picked up automatically.

Special thanks to Luis and his blog post [Poor man’s load balancing with Docker](https://medium.com/@lherrera/poor-mans-load-balancing-with-docker-2be014983e5) that helped me connect the dots and successfully configure my Dokku  applications to talk to each other.