---
title: Force HTTPS on Heroku
date: 2018-06-15
slug: https-heroku
author: Miloš Krsmanović
---

Recently I deployed and app to [Heroku](https://heroku.com) and I wanted to force my users to only access it over HTTPS. I tried finding a  configuration option in the Heroku dashboard but found nothing, then I stumbeled upon [this help page](https://help.heroku.com/J2R1S4T8/can-heroku-force-an-application-to-use-ssl-tls) and the following sentence: "Redirects need to be performed at the application level as the Heroku router does not provide this functionality. You should code the redirect logic into your application".

This does not agree with this [RFC](https://tools.ietf.org/html/rfc2817#section-4.2) which says "A server MAY indicate that a client request can not be completed without TLS using the "426 Upgrade Required" status code, which MUST include an an Upgrade header field specifying the token of the required TLS version". Which would mean that the server to requests made using HTTP should respond with:

```text
HTTP/1.1 426 Upgrade Required
Upgrade: TLS/1.0, HTTP/1.1
Connection: Upgrade
```

Or this [RFC](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.4) that explains the desired behaviour like this: "The server understood the request, but is refusing to fulfill it" and that the server should respond by using the 403 header. Specifically with

```
403.4 - SSL required
```

Since the recommendations of the two RFCs are pretty conflicting about what should be the propper way to handle access with non-https and the fact that Heroku is pretty clear with how it expects your app to behave I opted to just redirect the users to the same URL they requested except I then force HTTPS. I wrote a middleware and pluged it in my handler chain before handling any routes. The middleware looks like this:

{{< highlight go >}}
func forceSSL(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("X-Forwarded-Proto") != "https" {
			url := url.URL{Scheme: "https", Host: r.Host, Path: r.URL.Path, RawQuery: r.URL.RawQuery}
			http.Redirect(w, r, url.String(), http.StatusTemporaryRedirect)
			return
		}
		next.ServeHTTP(w, r)
	})
}
{{< /highlight >}}

You notice that we are using `X-Forwarded-Proto` to check the originating protocol of the HTTP request. This is because "Under the hood, Heroku router (over)writes the X-Forwarded-Proto and the X-Forwarded-Port request headers" ([source](https://help.heroku.com/J2R1S4T8/can-heroku-force-an-application-to-use-ssl-tls)).

In a simple application you can use it like this:

{{< highlight go >}}
package main

import (
	"log"
	"net/http"
	"os"
)

func main() {

	http.Handle("/", forceSSL(handler()))

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}

// dummy handler
func handler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
}
{{< /highlight >}}

That is it.

This was a simple fix but it allowed me to be sure that my users are accessing my app over HTTPS every time.