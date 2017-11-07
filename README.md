# Waldur HomePort Docker Image

## Image building instructions

```bash
# clone repo
mkdir -p ~/repos
cd ~/repos
git clone git@github.com:opennode/waldur-homeport-docker.git

# build image
cd waldur-homeport
make build

# push image to docker hub
# NB! Make sure that you are authenticated via docker login 
# and that you have write access to hub.docker.com/opennode/waldur-homeport repo!
make push
```

## Image usage instructions

Prerequisites:
* App network
* MasterMind API Endpoint

### Preparing environment and configuration

```bash
# pull image from https://hub.docker.com/r/opennode/waldur-homeport/
docker pull opennode/waldur-homeport

# create docker volume for /etc/waldur-homeport configuration overlay (optional)
docker volume create waldur-homeport
# verify
docker volume inspect waldur-homeport

# set REQUIRED ENV variables for HomePort configuration
echo "MASTERMIND_HOST=\"waldur-mastermind-api\"" > homeportrc
echo "MASTERMIND_PORT=\"8080\"" >> homeportrc
echo "MASTERMIND_PROTO=\"http\"" >> homeportrc

# set OPTIONAL ENV variables for Mastermind configuration
# if you want to override any configuration defaults
TODO

```

### Running HomePort service

```bash
source homeportrc && \
docker run -d --name waldur-homeport \
  --network waldur \
  -e MASTERMIND_HOST=$MASTERMIND_HOST \
  -e MASTERMIND_PORT=$MASTERMIND_PORT \
  -e MASTERMIND_PROTO=$MASTERMIND_PROTO \
  -p 80:80 \
  opennode/waldur-homeport

# verify
docker logs -f waldur-homeport
```

