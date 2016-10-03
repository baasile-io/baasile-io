# api-cpa

[![Build Status](https://travis-ci.org/api-cpa/api-cpa.svg?branch=master)](https://travis-ci.org/api-cpa/api-cpa) [![Dependency Status](https://dependencyci.com/github/api-cpa/api-cpa/badge)](https://dependencyci.com/github/api-cpa/api-cpa)

## BREW INIT

befor using brew.

export HOMEBREW_CACHE=~/goinfre/mycache ;
export HOMEBREW_TEMP=~/goinfre/mytemp ;
mkdir ~/goinfre/mycache ~/goinfre/mytemp ;
export PATH=$PATH:~/.brew/bin/ ;


use brewup for update:

alias brewup="mkdir -p ~/.brew/Library/Formula/; brew update; cd /tmp; git clone https://github.com/Homebrew/homebrew-core.git; cd -; cp -r /tmp/homebrew-core/Formula/* ~/.brew/Library/Formula/; rm -rf /tmp/homebrew-core;"

install brew

## mongo install

brew install mongodb

## mongo start

mongod --dbpath /tmp

## install server

installer node et npm

mettre la derniere mise a jour de nodejs

npm install

## lanch server

npm start
