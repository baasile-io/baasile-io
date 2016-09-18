'use strict';

const apiTester = require('../../test.helper.js'),
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
            description: 'Description',
            site_internet: ''
          });
          done();
        });
    });

    it('show public service by id', function (done) {
      request()
        .get('/api/v1/services/my_client_id')
        .query({access_token: ApiTester.getAccessToken()})
        .end(function (err, res) {
          ApiTester.checkResponse(res, {isCollection: false});
          res.body.data.id.should.eql('my_client_id');
          res.body.data.type.should.eql('services');
          res.body.data.attributes.should.eql({
            alias: 'test',
            nom: 'Test',
            description: 'Description',
            site_internet: ''
          });
          done();
        });
    });

  });

});
