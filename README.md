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

# multi-env options

1. env_file loaded from ENV variable for DEPLOY_ENV=
2. multiple compose files stacked together
3. ...

1. Each dockerfile takes a build arg for build_env
2a. compose can build, passing that build arg
2b. compose only pulls from iamges with a env tag

Small script to switch .env between .env.prod/production and .env.development
Prepends the BUILD_ENV=$1
Write out as .env in current directory
Sources .env

# Setting up the swarm (assuming docker 17.04+ installed)

1. create 2 or 3 nodes (I used digitalocean.com), one manager, one application, and one database
2. `ssh` to manager
3. `docker swarm init --advertise-addr {VPS_PRIVATE_IP}`
4. Copy the command to join the swarm
5. `ssh` to application and database, and paste the `docker swarm join --token ...` command
6. Back on the manager node, assign roles to each hostname e.g.:
7. `docker node update --label-add role=database {DATABASE_SERVER_HOSTNAME}`
8. `docker node update --label-add role=application {APPLICATION_SERVER_HOSTNAME`

# Production Deploy (on Manager node)

1. `curl -O https://raw.githubusercontent.com/tpitale/advocate_provision/master/docker-compose.yml`
2. `curl https://raw.githubusercontent.com/tpitale/advocate_provision/master/.env.sample > .env`
3. `vi .env` to set your variables
4. `set -a; source .env; set +a`
5. `docker login $DOCKER_REGISTRY`
6. `docker stack deploy --with-registry-auth --compose-file=docker-compose.yml advocate` # each time you update

## Run db setup once, or migrations as needed from the Application node:

1. `docker exec advocate_advocate.1.{CONTAINER_ID} bin/rake db:setup --trace`
2. `docker exec advocate_advocate.1.{CONTAINER_ID} bin/rake db:migrate`

# Debugging

## From Manager node

* `docker stack services advocate`
* `docker stack ps advocate`

## From Application node in swarm

* `docker exec advocate_advocate.1.{CONTAINER_ID} tail -f /app/log/puma.stderr.log`
* `docker exec advocate_advocate.1.{CONTAINER_ID} tail -f /app/log/prod.log`
