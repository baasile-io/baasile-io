'use strict';

const apiTester = require('../../api.tester.js'),
  ApiTester = new apiTester(),
  request = ApiTester.request;

describe('Services', function () {

  before(ApiTester.before);
  after(ApiTester.after);

  describe('Authenticated service', function () {

    before(ApiTester.authorize);

    it('show list of public services', function (done) {
      request()
        .get('/api/v1/services')
        .query({access_token: ApiTester.getAccessToken()})
        .end(function (err, res) {
          ApiTester.checkResponse(res);
          res.body.data.should.have.lengthOf(1);
          res.body.data[0].id.should.eql('my_client_id');
          res.body.data[0].type.should.eql('services');
          res.body.data[0].attributes.should.eql({
            alias: 'test',
            nom: 'Test',
            description: 'Description'
          });
          done();
        });
    });

  });

});
