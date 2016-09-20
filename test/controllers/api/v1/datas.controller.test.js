'use strict';

const testHelper = require('../../../test.helper.js'),
  TestHelper = new testHelper(),
  request = TestHelper.request;

describe('Datas', function () {

  before(TestHelper.startServer);
  before(TestHelper.seedDb);
  after(TestHelper.stopServer);

  describe('Authenticated service', function () {

    before(TestHelper.authorize);

    it('show list of public data', function (done) {
      request()
        .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res);
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
