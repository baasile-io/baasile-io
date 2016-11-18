# Baasile IO

[![Build Status](https://travis-ci.org/baasile-io/baasile-io.svg?branch=master)](https://travis-ci.org/baasile-io/baasile-io) [![Dependency Status](https://dependencyci.com/github/baasile-io/baasile-io/badge)](https://dependencyci.com/github/baasile-io/baasile-io)

**Baasile IO** is a light platform that allows you to quickly store and share data between web services and client applications.

![Baasile IO](http://baasile.io/assets/img/github/baasile-io-github.png)

## New setup instructions

<img align="right" src="http://baasile.io/assets/img/github/basilio-github-topright.png" alt="Basilio - Baasilio IO"/>

Basilio *the little spaceman* explains you how to setup a freshly new platform :-)

#### Pre-requirements

My app has the following requirements:

- [NodeJS](https://nodejs.org/en/) version 6
- [MongoDB](https://www.mongodb.com/) version 3

Check your version of NodeJS with `node --version`.  
Check your version of MongoDB with `mongod --version`.

#### Sources

Get my sources from Github and install the dependencies:

```
git clone git@github.com:baasile-io/baasile-io.git
cd baasile-io
npm install
```

#### Environment variables

This is an important step as my app requires several parameters to run.  
Refer to my wiki page about [environment variables](https://github.com/baasile-io/baasile-io/wiki/Environment-variables) to setup the parameters.

#### External storage service

I decided to not serve static files through the application router, so that you need an external storage service to be setup. Get an account on Amazon Web Services and report your secret key and token to your environment.

#### Local server

If it is your first run, you need to upload assets to the external storage service:

```
node bin/www.js s3.task
```

Then ensure that MongoDB is running and start the server:

```
npm start
```

## Development

Be sure to checkout the `develop` branch:

```
checkout my branch named `develop`
```

Refer to [Baasile IO Wiki](https://github.com/baasile-io/baasile-io/wiki).

## Licence

Baasile IO is licensed under the Open Source licence Apache 2.0.