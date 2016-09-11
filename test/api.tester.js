'use strict';

const chai = require('chai'),
  should = require('chai').should(),
  chaiHttp = require('chai-http'),
  Server = require('../server.js');

chai.use(chaiHttp);

module.exports = ApiTester;

function ApiTester(options) {
  options = options || {};
  options.dbHost = options.dbHost || 'mongodb://localhost:27017/api-cpa-test';
  options.expressSessionSecret = options.expressSessionSecret || 'test';
  options.host = options.host || 'http://localhost:3010';
  options.port = options.port || 3010;

  const server = new Server(options);

  this.request = function(host) {
    host = host || options.host;
    return chai.request(host);
  };

  this.before = function(done) {
    server.start(function (err) {
      if (err)
        return done(err);
      done();
    });
  };

  this.after = function(done) {
    server.stop(done);
  };

};