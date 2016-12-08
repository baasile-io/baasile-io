# Baasile IO (Ruby on Rails)

[![Build Status](https://travis-ci.org/baasile-io/baasile-io.svg?branch=master)](https://travis-ci.org/baasile-io/baasile-io) [![Dependency Status](https://dependencyci.com/github/baasile-io/baasile-io/badge)](https://dependencyci.com/github/baasile-io/baasile-io)

**Baasile IO** is a light platform that allows you to quickly store and share data between web services and client applications.

![Baasile IO](http://baasile.io/assets/img/github/baasile-io-github.png)

## New local setup instructions

<img align="right" src="http://baasile.io/assets/img/github/basilio-github-topright.png" alt="Basilio - Baasilio IO"/>

Basilio *the little spaceman* explains you how to setup a freshly new platform :-)

#### Pre-requirements

Install xcode:
```
xcode-select --install
```

Install brew:
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install rbenv:
```
brew install rbenv
```

Install ruby-build:
```
brew install ruby-build
```

Install ruby 2.3.1:
```
rbenv install 2.3.1
```

Set local version of Ruby for Baasile IO:
```
rbenv local 2.3.1; rbenv rehash
```

Init rbenv at terminal launch (e.g: append to ~/.bash_profile):
```
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
```

Reinit current session:
```
source ~/.bash_profile
```

Install bundler:
```
gem install bundler
```

Install Rails:
```
gem install rails
```

#### Sources

[TODO]

#### Environment variables

```
#production:
BAASILE_IO_HOSTNAME="baasile-io-demo.net"
```

#### External storage service

[TODO]

#### Local server

[TODO]

## Running localy

Build Docker images with docker-compose:
```
docker-compose build
```

Then run:
```
docker-compose up
```

## Development

Be sure to checkout the `develop` branch:

```
checkout my branch named `develop`
```

Refer to [Baasile IO Wiki](https://github.com/baasile-io/baasile-io/wiki).

## Licence

Baasile IO is licensed under the Open Source licence Apache 2.0.
