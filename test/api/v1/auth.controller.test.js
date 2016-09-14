'use strict';

process.env.NODE_ENV = 'test';

const apiTester = require('../../api.tester.js'),
  ApiTester = new apiTester(),
  request = ApiTester.request;

describe('Auth', function () {

  before(ApiTester.before);
  after(ApiTester.after);

  describe('Authenticated service', function () {

    before(ApiTester.authorize);

    it('access_token is required', function (done) {
      request()
        .get('/api/v1/services')
        .end(function (err, res) {
          ApiTester.checkJsonapiStandard(res, {isSuccess: false, status: 400});
          res.body.errors.should.include('missing_parameter');
          res.body.errors.should.include('"access_token" is required');
          done();
        });
    });

    it('allows access', function (done) {
      request()
        .get('/api/v1/services')
        .query({access_token: ApiTester.getAccessToken()})
        .end(function (err, res) {
          ApiTester.checkJsonapiStandard(res);
          res.body.data.should.have.lengthOf(1);
          done();
        });
    });
  });

});
