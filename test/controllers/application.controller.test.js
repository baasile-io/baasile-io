'use strict';

// INFO
// heroku environment simulated (see testHelper argument and requests header 'X-Forwarded-Proto')
// https://devcenter.heroku.com/articles/http-routing

const testHelper = require('../test.helper.js'),
  TestHelper = new testHelper({nodeEnv: 'heroku'}),
  request = TestHelper.request;

describe('ApplicationController', function () {

  before(TestHelper.startServer);
  before(TestHelper.seedDb);
  after(TestHelper.stopServer);

  describe('heroku environment', function() {

    describe('API', function() {

      describe('restrict HTTP', function() {

        it('forbidden access', function (done) {
          request()
            .get('/api/v1/services')
            .set('X-Forwarded-Proto', 'http')
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isSuccess: false, status: 403});
              res.body.errors.should.include('forbidden_access');
              res.body.errors.should.include('You must use HTTPS protocol');
              done();
            });
        });

        it('allowed access', function (done) {
          request()
            .get('/api/v1/services')
            .set('X-Forwarded-Proto', 'https')
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isSuccess: false, status: 400});
              res.body.errors.should.not.include('forbidden_access');
              done();
            });
        });

      });

    });

    describe('Dashboard', function() {

      describe('restrict HTTP', function() {

        it('forbidden access', function (done) {
          request()
            .get('/login')
            .set('X-Forwarded-Proto', 'http')
            .end(function (err, res) {
              res.should.have.status(403);
              res.text.should.include('Vous devez utiliser une connexion sécurisée (HTTPS) pour accéder au Dashboard');
              done();
            });
        });

        it('allowed access', function (done) {
          request()
            .get('/login')
            .set('X-Forwarded-Proto', 'https')
            .end(function (err, res) {
              res.should.have.status(200);
              done();
            });
        });

      });

    });

  });

});