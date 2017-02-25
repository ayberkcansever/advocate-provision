# Provisioning #

Includes `docker-compose` settings and nginx dockerfile to run Advocate and Advocate Bridge.

## Set up ##

### ENV ###

Set your `$DOCKER_REGISTRY` to the same registry you used for `advocate`, `advocate-bridge`, and `advocate-nginx`.

*Note:* we advise installing `autoenv` (on macOS `brew install autoenv`) which loads `.env` when you `cd` into the project

1. `cp .env.sample .env`
2. Edit `.env` with your settings for postgres, rails/mix envs, and the servers you want to use
3. Edit `/etc/hosts` to point the server names you used in Step 2 (e.g. `advocate.dev`/`bridge.advocate.dev`) to your local machine

These environment variables will all be passed to the appropriate containers by compose.

### Run Compose Locally ###

To run everything together you can us `make run`. This will:

1. start a postgres DB
2. run advocate
3. run advocate bridge
4. run the nginx proxy

Locally, this will be available on port 8080.

### TODO ###

1. Deploy this compose file to a docker swarm in production

## Set up NGINX ##

*Only if you want to run each service individually will you need to do the next phase.*

1. cd advocate-nginx
2. `cp .env.sample .env`
3. Edit each to set the server names you want to use in nginx

### Release ###

`make release`

### Run Locally ###

`make run`

### TODO ###

1. use `--build-arg` with environment variables to create the nginx site config
