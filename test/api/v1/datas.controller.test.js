'use strict';

const apiTester = require('../../api.tester.js'),
  ApiTester = new apiTester(),
  request = ApiTester.request;

describe('Datas', function () {

  before(ApiTester.before);
  after(ApiTester.after);

  describe('Authenticated service', function () {

    before(ApiTester.authorize);

    it('show list of public data', function (done) {
      request()
        .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees')
        .query({access_token: ApiTester.getAccessToken()})
        .end(function (err, res) {
          ApiTester.checkResponse(res);
          res.body.data.should.have.lengthOf(1);
          res.body.data[0].id.should.eql('my_data_id1');
          res.body.data[0].type.should.eql('donnees');
          res.body.data[0].attributes.should.eql({
            field1: "first string",
            field2: "second string"
          });
          done();
        });
    });

  });

});
