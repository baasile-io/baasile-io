'use strict';

const testHelper = require('../../../test.helper.js'),
  TestHelper = new testHelper(),
  request = TestHelper.request;


const datadb = {
  my_client_id: {alias: "test", nom: "Test", description: 'Description', site_internet: 'http://mywebsite.com', public: true},
  my_client_id_private: {alias: "Private_service", nom: "Private service", description: 'Description', site_internet: '', public: false},
  client_id_number_1: {alias: "service_1", nom: "service 1", description: 'Description', site_internet: '', public: true},
  client_id_number_2: {alias: "service_2", nom: "service 2", description: 'Description', site_internet: '', public: true},
  client_id_number_3: {alias: "service_3", nom: "service 3", description: 'Description', site_internet: '', public: true},
  client_id_number_4: {alias: "service_4", nom: "service 4", description: 'Description', site_internet: '', public: true},
};

const filterClassic = [
  { testname: "test simple", res:["my_client_id"], filter : "filter[name]=Test"},
  { testname: "test simple 2", res:["my_client_id", "client_id_number_1", "client_id_number_2", "client_id_number_3", "client_id_number_4"], filter : "filter[public]=true"},
  { testname: "test whith $or 2 $regex", res:["client_id_number_1", "client_id_number_2", "client_id_number_3", "client_id_number_4"], filter : "filter[name][$regex]=service"},
]

describe('Services', function () {

  before(TestHelper.startServer);
  before(TestHelper.seedDb);
  after(TestHelper.stopServer);

  describe('Authenticated service', function () {

    before(TestHelper.authorize);

    describe('Collection', function() {

      it('show list of public services', function (done) {
        request()
          .get('/api/v1/services')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(5);
            res.body.data[0].id.should.eql('my_client_id');
            res.body.data[0].type.should.eql('services');
            res.body.data[0].attributes.should.eql({
              alias: 'test',
              nom: 'Test',
              description: 'Description',
              site_internet: 'http://mywebsite.com',
              public: true
            });
            done();
          });
      });

      it('show my own service even if private', function (done) {
        // make my own service to be private and check if it is really mine
        const own_service = TestHelper.getServiceByClientId('my_client_id');
        own_service.clientId.should.eql(TestHelper.getClientId());
        own_service.public = false;
        own_service.save(function(err) {
          if (err)
            return done(err);

          // then try to request through API
          request()
            .get('/api/v1/services')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res);
              res.body.data.should.have.lengthOf(5);
              res.body.data[0].id.should.eql('my_client_id');
              res.body.data[0].type.should.eql('services');
              res.body.data[0].attributes.should.eql({
                alias: 'test',
                nom: 'Test',
                description: 'Description',
                site_internet: 'http://mywebsite.com',
                public: false
              });

              // make my own service to be public again
              own_service.public = true;
              own_service.save(done);
            });

        });
      });

    });

    describe('Resource', function() {

      it('show public service by id', function (done) {
        request()
          .get('/api/v1/services/my_client_id')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isCollection: false});
            res.body.data.id.should.eql('my_client_id');
            res.body.data.type.should.eql('services');
            res.body.data.attributes.should.eql({
              alias: 'test',
              nom: 'Test',
              description: 'Description',
              site_internet: 'http://mywebsite.com',
              public: true
            });
            done();
          });
      });

      it('do not show private service by id', function (done) {
        // firstly check if 'my_client_id_private' is really a private service
        const private_service = TestHelper.getServiceByClientId('my_client_id_private');
        private_service.public.should.eql(false);

        // then try to request through API
        request()
          .get('/api/v1/services/my_client_id_private')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isSuccess: false, status: 404});
            res.body.errors.should.include('not_found');
            done();
          });
      });

      it('show my own service even if private', function (done) {
        // make my own service to be private and check if it is really mine
        const own_service = TestHelper.getServiceByClientId('my_client_id');
        own_service.clientId.should.eql(TestHelper.getClientId());
        own_service.public = false;
        own_service.save(function(err) {
          if (err)
            return done(err);

          // then try to request through API
          request()
            .get('/api/v1/services/my_client_id')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isCollection: false});
              res.body.data.id.should.eql('my_client_id');
              res.body.data.type.should.eql('services');
              res.body.data.attributes.should.eql({
                alias: 'test',
                nom: 'Test',
                description: 'Description',
                site_internet: 'http://mywebsite.com',
                public: false
              });

              // make my own service to be public again
              own_service.public = true;
              own_service.save(done);
            });

        });
      });

    });
    it('show list of public services', function (done) {
      request()
        .get('/api/v1/services')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res);
          res.body.data.should.have.lengthOf(5);
          res.body.data[0].id.should.eql('my_client_id');
          res.body.data[0].type.should.eql('services');
          res.body.data[0].attributes.should.eql({
            alias: 'test',
            nom: 'Test',
            description: 'Description',
            site_internet: 'http://mywebsite.com',
            public: true
          });
          done();
        });
    });
  
    describe('Filter TEST', function () {
    
      filterClassic.forEach(function(objfilterclassic) {
        it(objfilterclassic.testname, function (done) {
          request()
            .get('/api/v1/services?' + objfilterclassic.filter)
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res);
              res.body.data.should.have.lengthOf(objfilterclassic.res.length);
              for (var j = 0; j < objfilterclassic.res.length; ++j) {
                let exists = false;
                res.body.data.forEach(function(data) {
                  if (data.id === objfilterclassic.res[j]) {
                    exists = true;
                    data.type.should.eql('services');
                    if (data.attributes !== undefined) {
                      data.attributes.should.eql({
                        alias: datadb[objfilterclassic.res[j]].alias,
                        nom: datadb[objfilterclassic.res[j]].nom,
                        description: datadb[objfilterclassic.res[j]].description,
                        site_internet: datadb[objfilterclassic.res[j]].site_internet,
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
