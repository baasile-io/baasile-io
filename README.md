# api-cpa

[![Build Status](https://travis-ci.org/api-cpa/api-cpa.svg?branch=master)](https://travis-ci.org/api-cpa/api-cpa)

## Installation

Here's what you need to get the project running on your computer, locally.

Please report any problems you may encounter with this setup so we can help you
and update the process for everyone else's benefit.

### Install Mongo DB

We currently use version `3.0`. This also the version of Mongo supported by our
hosting provider, [Heroku](https://www.heroku.com/).

More information available here:
[https://docs.mongodb.com/manual/installation/](https://docs.mongodb.com/manual/installation/)

If you use Docker, you can get Mongo running in a container with:
```sh
docker run -d --name mongo -p '127.0.0.1:27017:27017' mongo:3.0
```

### Install Node JS 6.5

The easiest way to install any Node JS version is with the
[Node Version Manager (NVM)](https://github.com/creationix/nvm).

Here's how that might go for you:
```sh
# Install NVM. More info: https://github.com/creationix/nvm#install-script
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.7/install.sh | bash

# Install Node 6.5
nvm install v6.5
```

### Install project dependencies

```sh
npm install
```

### Run the development server

```sh
npm start
```
