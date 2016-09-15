'use strict';

const chai = require('chai'),
  should = require('chai').should(),
  chaiHttp = require('chai-http'),
  Server = require('../server.js'),
  userModel = require('../models/v1/User.model.js'),
  serviceModel = require('../models/v1/Service.model.js'),
  tokenModel = require('../models/v1/Token.model.js'),
  routeModel = require('../models/v1/Route.model.js'),
  dataModel = require('../models/v1/Data.model.js'),
  fieldModel = require('../models/v1/Field.model.js');


chai.use(chaiHttp);

module.exports = ApiTester;

function ApiTester(options) {
  options = options || {};
  options.dbHost = options.dbHost || process.env.MONGODB_URI || 'mongodb://localhost:27017/api-cpa-test';
  options.expressSessionSecret = options.expressSessionSecret || 'test';
  options.host = options.host || 'http://localhost:3010';
  options.port = options.port || 3010;

  const server = new Server(options),
    ServiceModel = new serviceModel(options),
    UserModel = new userModel(options),
    TokenModel = new tokenModel(options),
    RouteModel = new routeModel(options),
    FieldModel = new fieldModel(options),
    DataModel = new dataModel(options);

  const userInfo = {
    firstname: 'Firstname',
    lastname: 'Lastname',
    email: 'apicpa@apicpa.apicpa',
    password: 'password10',
    createdAt: new Date()
  };

  const serviceInfo = {
    name: 'Test',
    nameNormalized: 'test',
    description: 'Description',
    public: true,
    users: [],
    clientSecret: 'my_client_secret',
    clientId: 'my_client_id',
    createdAt: new Date(),
    creator: null,
    validated: true
  };

  const collectionsInfo = [{
    name: 'Collection1',
    nameNormalized: 'collection1',
    description: 'description',
    routeId: 'my_route_id1',
    public: true,
    isIdentified: false,
    isCollection: false,
    fields: [{
      name: 'Field1',
      nameNormalized: 'field1',
      required: true,
      fieldId: 'my_field_id1',
      type: 'STRING'
    }, {
      name: 'Field2',
      nameNormalized: 'field2',
      required: true,
      fieldId: 'my_field_id2',
      type: 'STRING'
    }],
    data: [{
      dataId: 'my_data_id1',
      data: {
        field1: 'first string',
        field2: 'second string'
      }
    }]
  }];

  var accessToken;

  this.getAccessToken = function() {
    return accessToken;
  };

  this.getClientSecret = function() {
    return serviceInfo.clientSecret;
  };

  this.getClientId = function() {
    return serviceInfo.clientId;
  };

  this.authorize = function(done) {
    requestFn()
      .post('/api/v1/oauth/token')
      .send({client_id: serviceInfo.clientId, client_secret: serviceInfo.clientSecret})
      .end(function (err, res) {
        accessToken = res.body.data.attributes.access_token;
        done();
      });
  };

  this.expiredToken = function(done) {
    TokenModel.io.findOne({accessToken: accessToken}, function(err, token) {
      if (err)
        return done(err);
      token.accessTokenExpiresOn = new Date();
      token.save(function(err) {
        if (err)
          return done(err);
        done();
      });
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

          FieldModel.io.remove({}, function (err) {
            if (err)
              return done(err);

            RouteModel.io.remove({}, function (err) {
              if (err)
                return done(err);

              DataModel.io.remove({}, function (err) {
                if (err)
                  return done(err);

                UserModel.io.create(userInfo, function (err, user) {
                  if (err)
                    return done(err);

                  serviceInfo.users.push({_id: user._id});
                  serviceInfo.creator = {_id: user._id};
                  ServiceModel.io.create(serviceInfo, function (err, service) {
                    if (err)
                      return done(err);

                    collectionsInfo.forEach(function (el) {
                      el.clientId = serviceInfo.clientId;
                      el.creator = user;
                      el.service = service;
                      el.method = 'POST';
                      el.type = 'DONNEE_PARTAGEE';
                      el.createdAt = new Date();

                      RouteModel.io.create(el, function (err, route) {
                        if (err)
                          return done(err);

                        el.fields.forEach(function(el2) {
                          el2.route = route;
                          el2.creator = user;
                          el2.service = service;
                          el2.clientId = serviceInfo.clientId;
                          el2.routeId = route.routeId;
                          el2.createdAt = new Date();
                          el2.description = 'description';

                          FieldModel.io.create(el2, function(err, data) {
                            if (err)
                              throw new Error(JSON.stringify(err));
                          });
                        });

                        el.data.forEach(function(el2) {
                          el2.route = route;
                          el2.service = service;
                          el2.clientId = serviceInfo.clientId;
                          el2.routeId = route.routeId;
                          el2.createdAt = new Date();

                          DataModel.io.create(el2, function(err, data) {
                            if (err)
                              throw new Error(JSON.stringify(err));
                          });
                        });
                      });
                    });

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

  this.checkResponse = function(res, opt) {
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

  this.now = function() {
    return new Date();
  };

};