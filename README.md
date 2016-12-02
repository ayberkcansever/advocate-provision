# Provisioning for Advocate #

## Local Setup ##

1. clone this repo
2. bundle install
3. librarian-chef install
4. # TODO: create data bag with configuration below
5. configure advocate-server and advocate-server-bridge in ~/.ssh/config

## Provision ##

1. `knife solo prepare root@advocate-server`
2. `knife solo cook root@advocate-server`
