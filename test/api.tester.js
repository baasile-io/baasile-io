'use strict';

const chai = require('chai'),
  should = require('chai').should(),
  chaiHttp = require('chai-http'),
  Server = require('../server.js'),
  userModel = require('../models/v1/User.model.js'),
  serviceModel = require('../models/v1/Service.model.js'),
  tokenModel = require('../models/v1/Token.model.js');

const clientId = 'my_client_id',
  clientSecret = 'my_client_secret';

chai.use(chaiHttp);

module.exports = ApiTester;

function ApiTester(options) {
  options = options || {};
  options.dbHost = options.dbHost || process.env.MONGODB_URI || 'mongodb://localhost:27017/api-cpa-test';
  options.expressSessionSecret = options.expressSessionSecret || 'test';
  options.host = options.host || 'http://localhost:3010';
  options.port = options.port || 3010;

  const server = new Server(options);
  const ServiceModel = new serviceModel(options);
  const UserModel = new userModel(options);
  const TokenModel = new tokenModel(options);

  var accessToken;

  this.getAccessToken = function() {
    return accessToken;
  };

  this.authorize = function(done) {
    requestFn()
      .post('/api/v1/oauth/token')
      .send({client_id: clientId, client_secret: clientSecret})
      .end(function (err, res) {
        accessToken = res.body.data.attributes.access_token;
        done();
      });
  };

  this.request = requestFn;

  this.before = function(done) {

    TokenModel.io.remove({}, function(err) {
      if (err)
        return done(err);

      UserModel.io.remove({}, function (err) {
        if (err)
          return done(err);

        ServiceModel.io.remove({}, function (err) {
          if (err)
            return done(err);

          const userInfo = {
            firstname: 'Firstname',
            lastname: 'Lastname',
            email: 'apicpa@apicpa.apicpa',
            password: 'password10',
            createdAt: new Date()
          };

          UserModel.io.create(userInfo, function (err, user) {
            if (err)
              return done(err);

            const serviceInfo = {
              name: 'Test',
              nameNormalized: 'test',
              description: 'Description',
              public: true,
              users: [{_id: user._id}],
              clientSecret: 'my_client_secret',
              clientId: 'my_client_id',
              createdAt: new Date(),
              creator: {_id: user._id},
              validated: true
            };

            ServiceModel.io.create(serviceInfo, function (err, service) {
              if (err)
                return done(err);
              server.start(function (err) {
                if (err)
                  return done(err);
                done();
              });
            });
          });
        });
      });
    });
  };

  this.after = function(done) {
    server.stop(done);
  };

  function requestFn(host) {
    host = host || options.host;
    return chai.request(host);
  };

  this.checkJsonapiStandard = function(res, opt) {
    opt = opt || {};
    const isSuccess = opt.isSuccess === undefined || opt.isSuccess;
    const isCollection = opt.isCollection === undefined || opt.isCollection;
    const status = opt.status || 200;
    res.body.should.be.a('object');
    res.body.should.have.property('jsonapi');
    res.body.jsonapi.should.have.property('version');
    res.should.have.status(status);
    if (isSuccess) {
      res.body.should.have.property('data');
      if (isCollection) {
        res.body.data.should.be.a('array');
      } else {
        res.body.data.should.be.a('object');
      }
    } else {
      res.should.not.have.status(200);
      res.should.not.have.status(201);
      res.body.should.have.property('errors');
      res.body.errors.should.be.a('array');
    }
  };

};