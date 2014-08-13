This repo contains the source of the Cloudbreak Docker image.
To have a working API/UI, you need several containers. There is a
`start_cloudbreak.sh` script which starts them in this order:

- **postgresql**: db storing Cloudbreak internals
- **cloudbreak**: Cloudbreak API, serving web UI and the cli on the REST interface
- waiter: a docker container which waits for cloudbreak availabilty (we need to
  wait for http://$CB_API_URL/health to be available)
- **uluwatu**: Cloudbreak web UI. It is running in a customized nginx, using
  the same network interface as the **cloudbreak** container (CORS filtering).


### Deploy Cloudbreak API and UI

To have a running cloudbreak instance on your machine (made up of docker
containers hosting a postgres database, the cloudbreak application and a
cloudbreak shell respectively), you can run the script:

```
./start_cloudbreak.sh
```

This will drive you through setting up the required environment variables and
starts the configured Cloudbreak application. It also registers a user based on
the information provided. At this point you'll havea fully functional CLoudbreak
instance running on your host machine; you can start using it by accessing its
 REST interface.

### Cloudbreak logs

Docker starts as daemon. If you want to get insights, watch the logs via:

```
docker logs -f cloudbreak
```

### Using Cloudbreak CLI

If you prefer to use CLI instead of the web UI, start
Cloudbreak shell in a docker container by running the script:

```
./start_cli.sh
```
