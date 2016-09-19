'use strict';

const apiTester = require('../../test.helper.js'),
  ApiTester = new apiTester(),
  request = ApiTester.request;

describe('Auth', function () {

  before(ApiTester.before);
  after(ApiTester.after);

  it('access denied', function (done) {
    request()
      .get('/api/v1/services')
      .end(function (err, res) {
        ApiTester.checkResponse(res, {isSuccess: false, status: 400});
        res.body.errors.should.include('missing_parameter');
        res.body.errors.should.include('"access_token" is required');
        done();
      });
  });

  describe('Service authentication', function() {

    it('client_id needed', function (done) {
      request()
        .post('/api/v1/oauth/token')
        .end(function (err, res) {
          ApiTester.checkResponse(res, {isSuccess: false, status: 400});
          res.body.errors.should.include('missing_parameter');
          res.body.errors.should.include('"client_id" is required');
          done();
        });
    });

    it('client_secret needed', function (done) {
      request()
        .post('/api/v1/oauth/token')
        .send({client_id: 'id'})
        .end(function (err, res) {
          ApiTester.checkResponse(res, {isSuccess: false, status: 400});
          res.body.errors.should.include('missing_parameter');
          res.body.errors.should.include('"client_secret" is required');
          done();
        });
    });

    it('invalid client_secret', function (done) {
      request()
        .post('/api/v1/oauth/token')
        .send({client_id: ApiTester.getClientId(), client_secret: 'invalid'})
        .end(function (err, res) {
          ApiTester.checkResponse(res, {isSuccess: false, status: 400});
          res.body.errors.should.include('invalid_parameter');
          res.body.errors.should.include('"client_id" and/or "client_secret" are/is invalid');
          done();
        });
    });

    it('invalid client_id', function (done) {
      request()
        .post('/api/v1/oauth/token')
        .send({client_id: 'invalid', client_secret: ApiTester.getClientSecret()})
        .end(function (err, res) {
          ApiTester.checkResponse(res, {isSuccess: false, status: 400});
          res.body.errors.should.include('invalid_parameter');
          res.body.errors.should.include('"client_id" and/or "client_secret" are/is invalid');
          done();
        });
    });

    it('get access_token', function (done) {
      request()
        .post('/api/v1/oauth/token')
        .send({client_id: ApiTester.getClientId(), client_secret: ApiTester.getClientSecret()})
        .end(function (err, res) {
          ApiTester.checkResponse(res, {isCollection: false});
          res.body.data.attributes.should.have.property('access_token');
          res.body.data.attributes.should.have.property('expires_on');
          res.body.data.attributes.access_token.should.be.a('String');
          res.body.data.attributes.access_token.should.have.lengthOf(96);
          const expiresOn = new Date(res.body.data.attributes.expires_on);
          if (new Date(ApiTester.now().getTime() + 20 * 60000) - expiresOn > 60)
            throw new Error('token validity should be around twenty minutes');
          done();
        });
    });

    it('access_token is required', function (done) {
      request()
        .get('/api/v1/services')
        .end(function (err, res) {
          ApiTester.checkResponse(res, {isSuccess: false, status: 400});
          res.body.errors.should.include('missing_parameter');
          res.body.errors.should.include('"access_token" is required');
          done();
        });
    });

  });

  describe('Authenticated service', function () {

    before(ApiTester.authorize);

    it('allowed access', function (done) {
      request()
        .get('/api/v1/services')
        .query({access_token: ApiTester.getAccessToken()})
        .end(function (err, res) {
          ApiTester.checkResponse(res);
          res.body.data.should.have.lengthOf(1);
          done();
        });
    });

    describe('Token expiration', function() {

      before(ApiTester.expiredToken);

      it('expired token', function (done) {
        request()
          .get('/api/v1/services')
          .query({access_token: ApiTester.getAccessToken()})
          .end(function (err, res) {
            ApiTester.checkResponse(res, {isSuccess: false, status: 401});
            res.body.errors.should.include('expired_session');
            done();
          });
      });

    });

  });

});
