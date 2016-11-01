# Baasile IO

[![Build Status](https://travis-ci.org/baasile-io/baasile-io.svg?branch=master)](https://travis-ci.org/baasile-io/baasile-io) [![Dependency Status](https://dependencyci.com/github/baasile-io/baasile-io/badge)](https://dependencyci.com/github/baasile-io/baasile-io)

**Baasile IO** is a light platform that allows you to quickly store and share data between web services and client applications.

## New setup instructions

<img align="right" src="http://baasile.io/assets/img/github/basilio-github-topright.png" alt="Basilio - Baasilio IO"/>

Basilio *the little spaceman* explains you how to setup a freshly new platform :-)

#### Pre-requirements

My app has the following requirements:

- [NodeJS](https://nodejs.org/en/) version 6
- [MongoDB](https://www.mongodb.com/) version 3

Check your version of NodeJS with `node --version`.  
Check your version of MongoDB with `mongod --version`.

#### Installation

##### Sources

Get my sources from Github and checkout my `develop` branch:

```
git clone git@github.com:baasile-io/baasile-io.git
cd baasile-io
git checkout develop
npm install
```

##### Environment variables

My app requires several parameters to properly run.  
Refer to my wiki page [environment variables](https://github.com/baasile-io/baasile-io/wiki/Environment-variables).

##### External storage service

My app requires an external storage service.  
Get an access on Amazon Web Services and report your secret key and token to your environment.

##### Local server

First ensure that MongoDB is running, and then run:

```
npm start
```

## Development

Refer to [Baasile IO Wiki](https://github.com/baasile-io/baasile-io/wiki).
