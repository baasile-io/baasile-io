'use strict';

process.env.NODE_ENV = 'test';

const apiTester = require('../../api.tester.js'),
  ApiTester = new apiTester(),
  request = ApiTester.request;

describe('Auth', function () {

  before(ApiTester.before);
  after(ApiTester.after);

  describe('Unauthorized', function () {
    it('required access_token', function (done) {
      request()
        .get('/api/v1/services')
        .end(function (err, res) {
          res.should.have.status(400);
          res.body.should.be.a('object');
          res.body.should.have.property('errors');
          res.body.errors.should.include('missing_parameter');
          res.body.errors.should.include('"access_token" is required');
          done();
        });
    });
  });

});
