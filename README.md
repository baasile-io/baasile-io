# Baasile IO (on Rails)

[![Build Status](https://travis-ci.org/baasile-io/baasile-io.svg?branch=master)](https://travis-ci.org/baasile-io/baasile-io) [![Dependency Status](https://dependencyci.com/github/baasile-io/baasile-io/badge)](https://dependencyci.com/github/baasile-io/baasile-io)

**Baasile IO** is a light platform that allows you to quickly store and share data between web services and client applications.

![Baasile IO](http://baasile.io/assets/img/github/baasile-io-github.png)

## New local setup instructions

<img align="right" src="http://baasile.io/assets/img/github/basilio-github-topright.png" alt="Basilio - Baasilio IO"/>

Basilio *the little spaceman* explains you how to setup a freshly new platform :-)

#### Pre-requirements

To allow you working on any platforms, I recommend you to [install Docker Compose](https://docs.docker.com/compose/install/).

#### Sources

Get the sources by cloning my repository:
```
git clone git@github.com:baasile-io/baasile-io.git
cd baasile-io
```

#### Build images

You can now build the images of my platform with the following instructions:
```
docker-compose build    # it can take a few minutes
```

#### Setup database

If you just downloaded my sources, then setup the database:

```
docker-compose run baasile_io  rails db:setup
```

Later you will need to run migrations by running:

```
docker-compose run baasile_io  rails db:migrate
```

#### Run server

```
docker-compose up       # run on localhost at http://localhost:3042
```

#### Change configuration

Any update of my Gemfile requires the docker image to be built again:

```
docker-compose stop && docker-compose build
```

#### Environment variables

Updating my Gemfile requires the the docker image to be built again:

```

```

## Development

Be sure to checkout the `develop` branch:

```
git checkout develop
```

Refer to [Baasile IO Wiki](https://github.com/baasile-io/baasile-io/wiki).

## Licence

Baasile IO is licensed under the Open Source licence Apache 2.0.
