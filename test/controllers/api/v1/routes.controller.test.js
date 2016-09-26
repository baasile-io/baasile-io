'use strict';

const testHelper = require('../../../test.helper.js'),
  TestHelper = new testHelper(),
  request = TestHelper.request;

describe('Routes', function () {

  before(TestHelper.startServer);
  before(TestHelper.seedDb);
  after(TestHelper.stopServer);

  describe('Authenticated service', function () {

    before(TestHelper.authorize);

    it('show list of public collections', function (done) {
      request()
        .get('/api/v1/services/my_client_id/relationships/collections')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res);
          res.body.data.should.have.lengthOf(1);
          res.body.data[0].id.should.eql('my_route_id1');
          res.body.data[0].type.should.eql('collections');
          res.body.data[0].attributes.should.eql({
            "alias": "collection1",
            "description": "description",
            "jeton_fc_lecture_ectriture": false,
            "jeton_fc_lecture_seulement": false,
            "nom": "Collection1",
            "public": true,
            "tableau_de_donnees": false
          });
          done();
        });
    });

  });

});
