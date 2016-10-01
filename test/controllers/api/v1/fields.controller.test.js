'use strict';

const testHelper = require('../../../test.helper.js'),
  TestHelper = new testHelper(),
  request = TestHelper.request,
  fieldModel = require('../../../../models/v1/Field.model.js'),
  FieldModel = new fieldModel(TestHelper.getOptions());

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
          res.body.data.should.have.lengthOf(2);
          res.body.data[0].id.should.eql('my_field_id1');
          res.body.data[0].type.should.eql('champs');
          res.body.data[0].attributes.should.eql({
            "description": "description",
            "nom": "field1",
            "position": 0,
            "type": 'STRING'
          });
          res.body.data[1].id.should.eql('my_field_id2');
          res.body.data[1].type.should.eql('champs');
          res.body.data[1].attributes.should.eql({
            "description": "description",
            "nom": "field2",
            "position": 0,
            "type": 'STRING'
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
          res.body.data.should.have.lengthOf(2);
          res.body.data[0].id.should.eql('my_field_id1');
          res.body.data[0].type.should.eql('champs');
          res.body.data[0].attributes.should.eql({
            "description": "description",
            "nom": "field1",
            "position": 0,
            "type": 'STRING'
          });
          res.body.data[1].id.should.eql('my_field_id2');
          res.body.data[1].type.should.eql('champs');
          res.body.data[1].attributes.should.eql({
            "description": "description",
            "nom": "field2",
            "position": 0,
            "type": 'STRING'
          });
          done();
        });
    });

  });

});
