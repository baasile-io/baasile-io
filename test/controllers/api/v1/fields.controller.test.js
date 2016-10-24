'use strict';

const testHelper = require('../../../test.helper.js'),
  TestHelper = new testHelper(),
  request = TestHelper.request,
  fieldModel = require('../../../../models/v1/Field.model.js'),
  FieldModel = new fieldModel(TestHelper.getOptions());


const datadb = {
  my_field_id1: {description: 'description', nom: 'field1', position: 0, type: 'STRING'},
  my_field_id2: {description: 'description', nom: 'field2', position: 0, type: 'STRING'},
  my_field_id3: {description: 'description', nom: 'field3', position: 0, type: 'NUMERIC'},
  my_field_id4: {description: 'description', nom: 'field4', position: 0, type: 'JSON'},
  my_field_id5: {description: 'description', nom: 'field5', position: 0, type: 'AMOUNT'},
};

const filterClassic = [
  { testname: "test simple", res:["my_field_id1"], filter : "filter[name]=Field1"},
  { testname: "test simple 2", res:["my_field_id1", "my_field_id2"], filter : "filter[type]=STRING"},
  { testname: "test whith $or 2 $regex", res:["my_field_id1", "my_field_id2"], filter : "filter[$or][0][name][$regex]=ld1&filter[$or][1][name][$regex]=ld2"},
]

describe('Fields', function () {

  before(TestHelper.startServer);
  before(TestHelper.seedDb);
  after(TestHelper.stopServer);

  describe('Authenticated service', function () {

    before(TestHelper.authorize);

    describe('Errors', function() {

      it('404', function (done) {
        request()
          .get('/api/v1/champs/unknow_field_id')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isSuccess: false, status: 404});
            done();
          });
      });

    });

    it('show list of my own fields (related to my logged service)', function (done) {
      request()
        .get('/api/v1/champs')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res);
          res.body.data.should.have.lengthOf(5);
          res.body.data[0].id.should.eql('my_field_id5');
          res.body.data[0].type.should.eql('champs');
          res.body.data[0].attributes.should.eql({
            description: datadb['my_field_id5'].description,
            nom: datadb['my_field_id5'].nom,
            position: datadb['my_field_id5'].position,
            type: datadb['my_field_id5'].type
          });
          res.body.data[1].id.should.eql('my_field_id4');
          res.body.data[1].type.should.eql('champs');
          res.body.data[1].attributes.should.eql({
            description: datadb['my_field_id4'].description,
            nom: datadb['my_field_id4'].nom,
            position: datadb['my_field_id4'].position,
            type: datadb['my_field_id4'].type
          });
          done();
        });
    });

    it('get single field', function (done) {
      request()
        .get('/api/v1/champs/my_field_id1')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res, {isCollection: false});
          res.body.data.id.should.eql('my_field_id1');
          res.body.data.type.should.eql('champs');
          res.body.data.attributes.should.eql({
            "description": "description",
            "nom": "field1",
            "position": 0,
            "type": 'STRING'
          });
          done();
        });
    });

    it('show list of fields that are related to a collection', function (done) {
      request()
        .get('/api/v1/collections/my_route_id1/relationships/champs')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res);
          res.body.data.should.have.lengthOf(5);
          res.body.data[0].id.should.eql('my_field_id5');
          res.body.data[0].type.should.eql('champs');
          res.body.data[0].attributes.should.eql({
            description: datadb['my_field_id5'].description,
            nom: datadb['my_field_id5'].nom,
            position: datadb['my_field_id5'].position,
            type: datadb['my_field_id5'].type
          });
          res.body.data[1].id.should.eql('my_field_id4');
          res.body.data[1].type.should.eql('champs');
          res.body.data[1].attributes.should.eql({
            description: datadb['my_field_id4'].description,
            nom: datadb['my_field_id4'].nom,
            position: datadb['my_field_id4'].position,
            type: datadb['my_field_id4'].type
          });
          done();
        });
    });
  
    describe('Filter TEST', function () {
    
      filterClassic.forEach(function(objfilterclassic) {
        it(objfilterclassic.testname, function (done) {
          request()
            .get('/api/v1/collections/my_route_id1/relationships/champs?' + objfilterclassic.filter)
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res);
              res.body.data.should.have.lengthOf(objfilterclassic.res.length);
              for (var j = 0; j < objfilterclassic.res.length; ++j) {
                let exists = false;
                res.body.data.forEach(function(data) {
                  if (data.id === objfilterclassic.res[j]) {
                    exists = true;
                    data.type.should.eql('champs');
                    if (data.attributes !== undefined) {
                      data.attributes.should.eql({
                        description: datadb[objfilterclassic.res[j]].description,
                        nom: datadb[objfilterclassic.res[j]].nom,
                        position: datadb[objfilterclassic.res[j]].position,
                        type: datadb[objfilterclassic.res[j]].type
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
