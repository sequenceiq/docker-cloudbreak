This repo contains the source of the Cloudbreak Docker image.
To have a working API/UI, you need several containers. There is a
`start_cloudbreak.sh` script which starts them in this order:

- **uaadb**: postgresql db storing UAA internals
- **uaa**: Identity server that handles OAuth2 based authentication and authorization. We're using CloudFoundry's open source [UAA](https://github.com/cloudfoundry/uaa).
- **postgresql**: postgresql db storing Cloudbreak internals
- **cloudbreak**: Cloudbreak API, serving web UI and the cli on the REST interface
- waiter: a docker container which waits for cloudbreak availabilty (we need to wait for http://$CB_API_URL/health to be available)
- **sultans**: Custom login and user management service that accesses UAA's resources to register/login users.
- **uluwatu**: Cloudbreak web UI, a small node.js webapp that serves the static Angular.js front-end.


### Deploy Cloudbreak API and UI

To have a running cloudbreak infrastructure on your machine (made up of docker containers hosting the above described components), you can run the script:

```
./start_cloudbreak.sh
```

This will drive you through setting up the required environment variables and
starts the configured Cloudbreak application. It also registers a user based on
the information provided. At this point you'll have a fully functional Cloudbreak
instance running on your host machine; you can start using it by accessing its
 REST interface or the UI.
 
*note:* It is required that the web UI is available on `localhost:3000`. Port 3000 is forwarded from the docker container to the host, but if you're using boot2docker you should also forward the port 3000 to the local machine's port 3000 on VirtualBox's network adapter.

### Cloudbreak logs

Docker starts as daemon. If you want to get insights, watch the logs via:

```
docker logs -f cloudbreak
docker logs -f uaa
docker logs -f uluwatu
docker logs -f sultans
```

### Using Cloudbreak CLI

If you prefer to use CLI instead of the web UI, start
Cloudbreak shell in a docker container by running the script:

```
./start_cli.sh
```
