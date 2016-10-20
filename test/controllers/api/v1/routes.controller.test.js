'use strict';

const testHelper = require('../../../test.helper.js'),
  TestHelper = new testHelper(),
  request = TestHelper.request,
  routeModel = require('../../../../models/v1/Route.model.js'),
  RouteModel = new routeModel(TestHelper.getOptions());


const datadb = {
  my_route_id1: {alias: "collection1", description: 'description', jeton_fc_lecture_ecriture: false, jeton_fc_lecture_seulement: false, nom: "Collection1", public: true, tableau_de_donnees: false, donnees_identifiees: false},
};

const filterClassic = [
  { testname: "test simple", res:["my_route_id1"], filter : "filter[name]=Collection1"},
  { testname: "test simple 2", res:["my_route_id1"], filter : "filter[public]=true"},
  { testname: "test whith $or 2 $regex", res:["my_route_id1"], filter : "filter[routeId][$regex]=id1"},
]

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
            "jeton_fc_lecture_ecriture": false,
            "jeton_fc_lecture_seulement": false,
            "nom": "Collection1",
            "public": true,
            "tableau_de_donnees": false,
            "donnees_identifiees": false
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
              res.body.data[0].attributes.should.eql({
                alias: 'collection1',
                nom: 'Collection1',
                description: 'description',
                donnees_identifiees: false,
                tableau_de_donnees: false,
                jeton_fc_lecture_ecriture: false,
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
  
    describe('Filter TEST', function () {
    
      filterClassic.forEach(function(objfilterclassic) {
        it(objfilterclassic.testname, function (done) {
          request()
            .get('/api/v1/services/' + TestHelper.getClientId() + '/relationships/collections?' + objfilterclassic.filter)
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res);
              res.body.data.should.have.lengthOf(objfilterclassic.res.length);
              for (var j = 0; j < objfilterclassic.res.length; ++j) {
                let exists = false;
                res.body.data.forEach(function(data) {
                  if (data.id === objfilterclassic.res[j]) {
                    exists = true;
                    data.type.should.eql('collections');
                    if (data.attributes !== undefined) {
                      data.attributes.should.eql({
                        alias: datadb[objfilterclassic.res[j]].alias,
                        nom: datadb[objfilterclassic.res[j]].nom,
                        description: datadb[objfilterclassic.res[j]].description,
                        tableau_de_donnees: datadb[objfilterclassic.res[j]].tableau_de_donnees,
                        donnees_identifiees: datadb[objfilterclassic.res[j]].donnees_identifiees,
                        jeton_fc_lecture_ecriture: datadb[objfilterclassic.res[j]].jeton_fc_lecture_ecriture,
                        jeton_fc_lecture_seulement: datadb[objfilterclassic.res[j]].jeton_fc_lecture_seulement,
                        public: datadb[objfilterclassic.res[j]].public
                      });
                    }
                  }
                });
                if (!exists)
                  throw new Error('data not found');
              }
              done();
            });
        });
      });
    });

  });

});
