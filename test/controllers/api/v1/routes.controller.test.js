'use strict';

const testHelper = require('../../../test.helper.js'),
  TestHelper = new testHelper(),
  request = TestHelper.request,
  routeModel = require('../../../../models/v1/Route.model.js'),
  RouteModel = new routeModel(TestHelper.getOptions());

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

    it('show my own route even if private', function (done) {
      // make my own route to be private
      RouteModel.io.findOne({routeId: 'my_route_id1'}, function(err, own_route) {
        if (err)
          return done(err);
        own_route.public = false;
        own_route.save(function (err) {
          if (err)
            return done(err);

          // then try to request through API
          request()
            .get('/api/v1/services/' + TestHelper.getClientId() + '/relationships/collections/')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res);
              res.body.data.should.have.lengthOf(1);
              res.body.data[0].id.should.eql('my_route_id1');
              res.body.data[0].type.should.eql('collections');
              console.log(res.body.data[0].attributes);
              res.body.data[0].attributes.should.eql({
                alias: 'collection1',
                nom: 'Collection1',
                description: 'description',
                tableau_de_donnees: false,
                jeton_fc_lecture_ectriture: false,
                jeton_fc_lecture_seulement: false,
                public: false
              });

              // make my own service to be public again
              own_route.public = true;
              own_route.save(done);
            });

        });
      });
    });

  });

});
