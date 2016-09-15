'use strict';

const apiTester = require('../../api.tester.js'),
  ApiTester = new apiTester(),
  request = ApiTester.request;

describe('Routes', function () {

  before(ApiTester.before);
  after(ApiTester.after);

  describe('Authenticated service', function () {

    before(ApiTester.authorize);

    it('show list of public collections', function (done) {
      request()
        .get('/api/v1/services/my_client_id/relationships/collections')
        .query({access_token: ApiTester.getAccessToken()})
        .end(function (err, res) {
          ApiTester.checkResponse(res);
          res.body.data.should.have.lengthOf(1);
          res.body.data[0].id.should.eql('my_route_id1');
          res.body.data[0].type.should.eql('collections');
          res.body.data[0].attributes.should.eql({
            "alias": "collection1",
            "description": "description",
            "jeton_fc_lecture_ectriture": false,
            "jeton_fc_lecture_seulement": false,
            "nom": "Collection1",
            "tableau_de_donnees": false
          });
          done();
        });
    });

  });

});
