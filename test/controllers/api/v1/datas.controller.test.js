'use strict';

const testHelper = require('../../../test.helper.js'),
  TestHelper = new testHelper(),
  request = TestHelper.request,
  dataModel = require('../../../../models/v1/Data.model.js'),
  DataModel = new dataModel(TestHelper.getOptions());

const datadb = {
  my_data_id1: {field1: 'first string', field2: 'second string', field3: 12, field4: {'key': 'value'}, field5: 75},
  my_data_id2: {field1: 'second', field2: 'test1', field3: 1, field4: {'key': 'value'}, field5: 2},
  my_data_id3: {field1: 'third', field2: 'test2', field3: 70, field4: {'key': 'value'}, field5: 85},
  my_data_id4: {field1: 'fours', field2: 'test3', field3: 43, field4: {'key': 'value'}, field5: 35},
  my_data_id5: {field1: 'fives', field2: 'test4', field3: 80, field4: {'key': 'value'}, field5: 2},
  my_data_id6: {field1: 'sixs', field2: 'test5', field3: 125, field4: {'key': 'value'}, field5: 185},
  my_data_id7: {field1: null, field2: null, field3: null, field4: null, field5: null}
};

const SortMulti = [
  { testname: "Multi Sort data.field5 -data.field3", res:["my_data_id7", "my_data_id5", "my_data_id2", "my_data_id4", "my_data_id1", "my_data_id3", "my_data_id6"], sort : "sort=data.field5,-data.field3"},
  { testname: "Multi Sort data.field5 data.field3", res:["my_data_id7", "my_data_id2", "my_data_id5", "my_data_id4", "my_data_id1", "my_data_id3", "my_data_id6"], sort : "sort=data.field5,data.field3"},
]

const SortClassic = [
  { testname: "Sort data.field1", res:["my_data_id7", "my_data_id1", "my_data_id5", "my_data_id4", "my_data_id3", "my_data_id2", "my_data_id6"], sort : "sort=data.field1"},
  { testname: "Sort data.field2", res:["my_data_id7", "my_data_id2", "my_data_id3", "my_data_id4", "my_data_id5", "my_data_id6", "my_data_id1"], sort : "sort=data.field2"},
  { testname: "Sort data.field3", res:["my_data_id7", "my_data_id2", "my_data_id1", "my_data_id4", "my_data_id3", "my_data_id5", "my_data_id6"], sort : "sort=data.field3"},
  { testname: "Sort data.field5", res:["my_data_id7", "my_data_id2", "my_data_id5", "my_data_id4", "my_data_id1", "my_data_id3", "my_data_id6"], sort : "sort=data.field5"},
  { testname: "Sort '+' data.field1", res:["my_data_id7", "my_data_id1", "my_data_id5", "my_data_id4", "my_data_id3", "my_data_id2", "my_data_id6"], sort : "sort=%2Bdata.field1"},
  { testname: "Sort '+' data.field2", res:["my_data_id7", "my_data_id2", "my_data_id3", "my_data_id4", "my_data_id5", "my_data_id6", "my_data_id1"], sort : "sort=%2Bdata.field2"},
  { testname: "Sort '+' data.field3", res:["my_data_id7", "my_data_id2", "my_data_id1", "my_data_id4", "my_data_id3", "my_data_id5", "my_data_id6"], sort : "sort=%2Bdata.field3"},
  { testname: "Sort '+' data.field5", res:["my_data_id7", "my_data_id2", "my_data_id5", "my_data_id4", "my_data_id1", "my_data_id3", "my_data_id6"], sort : "sort=%2Bdata.field5"},
  { testname: "Sort '-' data.field1", res:["my_data_id6", "my_data_id2", "my_data_id3", "my_data_id4", "my_data_id5", "my_data_id1", "my_data_id7"], sort : "sort=-data.field1"},
  { testname: "Sort '-' data.field2", res:["my_data_id1", "my_data_id6", "my_data_id5", "my_data_id4", "my_data_id3", "my_data_id2", "my_data_id7"], sort : "sort=-data.field2"},
  { testname: "Sort '-' data.field3", res:["my_data_id6", "my_data_id5", "my_data_id3", "my_data_id4", "my_data_id1", "my_data_id2", "my_data_id7"], sort : "sort=-data.field3"},
  { testname: "Sort '-' data.field5", res:["my_data_id6", "my_data_id3", "my_data_id1", "my_data_id4", "my_data_id5", "my_data_id2", "my_data_id7"], sort : "sort=-data.field5"},
]

const SortError = [
  { testname: "Sort data.field1", res:["my_data_id7", "my_data_id1", "my_data_id5", "my_data_id4", "my_data_id3", "my_data_id2", "my_data_id6"], sort : "sort=data.field10"},
]
const SortWithFilter = [
  { testname: "test $exists true and Sort data.field1", res:["my_data_id1", "my_data_id5", "my_data_id4", "my_data_id3", "my_data_id2", "my_data_id6"], filter : "filter[data.field1][$exists]=true", sort :"sort=data.field1"},
  { testname: "test $exists false and Sort data.field1", res:["my_data_id7"], filter : "filter[data.field1][$exists]=false", sort :"sort=data.field1"},
  { testname: "test ne + $exists true and Sort '+' data.field2", res:["my_data_id2", "my_data_id3", "my_data_id4", "my_data_id5", "my_data_id6"], filter : "filter[$and][data.field1][$ne]=first string&filter[$and][data.field1][$exists]=true", sort :"sort=%2Bdata.field2"},
  { testname: "test ne + $exists true and Sort '-' data.field2", res:["my_data_id6", "my_data_id5", "my_data_id4", "my_data_id3", "my_data_id2"], filter : "filter[$and][data.field1][$ne]=first string&filter[$and][data.field1][$exists]=true", sort :"sort=-data.field2"},
]

const filterError = [
  { testname: "test Error AND", res:["my_data_id1"], filter : "filter[$and][data.field1]=first string&filter[$and]=12&filter[$and][data.field5][$gt]=72&filter[$and][data.field5][$lt]=90"},
  { testname: "test Error OR", res:["my_data_id1", "my_data_id2", "my_data_id3", "my_data_id5", "my_data_id6"], filter : "filter[$or][data.field1]=second&filter[$or]=12&filter[$or][data.field3]=12&filter[$or][data.field5]=85&filter[$or][data.field1]=sixs&filter[$or][data.field2]=test4"},
  { testname: "test Error inseption AND OR", res:["my_data_id2"], filter : "filter[$and][$or]=second&filter[$and][$or][data.field1]=sixs&filter[$and][$or][data.field1]=fives&filter[$and][data.field3][$lt]=20"},
  { testname: "test Error $gt $lt $gte $lte", res:["my_data_id3", "my_data_id4"], filter : "filter[data.field2][$gt]=42&filter[data.field1][$lt]=71&filter[data.field4][$gte]=35&filter[data.field1][$lte]=85"},
  { testname: "test Error $eq -> $in", res:["my_data_id1", "my_data_id2", "my_data_id3" ], filter : "filter[$eq]=12&filter[data.field4][$eq]=1&filter[data.field1][$eq]=70"},
  { testname: "test Error $ne -> $nin", res:["my_data_id4", "my_data_id5", "my_data_id6"], filter : "filter[$ne]=12&filter[data.field3][$ne]=1&filter[data.field3][$ne]=70"},
  { testname: "test Error $in", res:["my_data_id1", "my_data_id2", "my_data_id3"], filter : "filter[$in]=12&filter[data.field3][$in]=1&filter[data.field3][$in]=70"},
  { testname: "test Error $nin", res:["my_data_id4", "my_data_id5", "my_data_id6"], filter : "filter[$nin]=12&filter[data.field3][$nin]=1&filter[data.field3][$nin]=70"},
  { testname: "test Error simple $regex", res:["my_data_id1", "my_data_id3"], filter : "filter[$regex]=ir"},
  { testname: "test Error multi whith $regex", res:["my_data_id1"], filter : "filter[0][data.field1][$regex]=ir&filter[1][$regex]=st"},
  { testname: "test Error $and whith $regex", res:["my_data_id1"], filter : "filter[$and][0][data.field1][$regex]=ir&filter[$and][1][$regex]=st"},
  { testname: "test Error $or whith $regex", res:["my_data_id1", "my_data_id2", "my_data_id3"], filter : "filter[$or][0][data.field1][$regex]=ir&filter[$or][1][$regex]=se"},
  ]

const filterClassic = [
  { testname: "test $exists true", res:["my_data_id1", "my_data_id2", "my_data_id3", "my_data_id4", "my_data_id5", "my_data_id6"], filter : "filter[data.field1][$exists]=true"},
  { testname: "test $exists false", res:["my_data_id7"], filter : "filter[data.field1][$exists]=false"},
  { testname: "test ne + $exists true", res:["my_data_id2", "my_data_id3", "my_data_id4", "my_data_id5", "my_data_id6"], filter : "filter[$and][data.field1][$ne]=first string&filter[$and][data.field1][$exists]=true"},
  { testname: "test NOT -> NE", res:["my_data_id2", "my_data_id3", "my_data_id4", "my_data_id5", "my_data_id6", "my_data_id7"], filter : "filter[$and][data.field1][$not]=first string"},
  { testname: "test NOt -> NE && NOT 1", res:["my_data_id3", "my_data_id4", "my_data_id5", "my_data_id7"], filter : "filter[$and][0][data.field1][$not]=first string&filter[$and][0][data.field3][$not]=1&filter[$and][0][data.field5][$not][$gt]=90"},
  { testname: "test NOt -> NE && multiple NOT 2", res:["my_data_id3", "my_data_id7"], filter : "filter[$and][0][data.field1][$not]=first string&filter[$and][0][data.field3][$not]=1&filter[$and][0][data.field5][$not][$gt]=90&filter[$and][1][data.field5][$not][$lt]=71"},
  { testname: "test AND", res:["my_data_id1"], filter : "filter[$and][data.field1]=first string&filter[$and][data.field3]=12&filter[$and][data.field5][$gt]=72&filter[$and][data.field5][$lt]=90"},
  { testname: "test OR", res:["my_data_id1", "my_data_id2", "my_data_id3", "my_data_id5", "my_data_id6"], filter : "filter[$or][data.field1]=second&filter[$or][data.field3]=12&filter[$or][data.field3]=12&filter[$or][data.field5]=85&filter[$or][data.field1]=sixs&filter[$or][data.field2]=test4"},
  { testname: "test inseption AND OR", res:["my_data_id2"], filter : "filter[$and][$or][data.field1]=second&filter[$and][$or][data.field1]=sixs&filter[$and][$or][data.field1]=fives&filter[$and][data.field3][$lt]=20"},
  { testname: "test multiple and inseption AND OR", res:["my_data_id2"], filter : "filter[$and][0][$or][data.field1]=second&filter[$and][0][$or][data.field1]=third&filter[$and][0][$or][data.field1]=fours&filter[$and][0][$or][data.field1]=fives&filter[$and][0][$or][data.field1]=sixs&filter[$and][1][$or][data.field3]=12&filter[$and][1][$or][data.field3]=1&filter[$and][1][$or][data.field3]=70&filter[$and][1][$or][data.field3]=125&filter[$and][2][$or][data.field5]=35&filter[$and][2][$or][data.field5]=2&filter[$and][2][$or][data.field5]=75"},
  { testname: "test $gt $lt $gte $lte", res:["my_data_id3", "my_data_id4"], filter : "filter[data.field3][$gt]=42&filter[data.field3][$lt]=71&filter[data.field5][$gte]=35&filter[data.field5][$lte]=85"},
  { testname: "test $eq -> $in", res:["my_data_id1", "my_data_id2", "my_data_id3" ], filter : "filter[data.field3][$eq]=12&filter[data.field3][$eq]=1&filter[data.field3][$eq]=70"},
  { testname: "test $ne -> $nin", res:["my_data_id4", "my_data_id5", "my_data_id6", "my_data_id7"], filter : "filter[data.field3][$ne]=12&filter[data.field3][$ne]=1&filter[data.field3][$ne]=70"},
  { testname: "test $in", res:["my_data_id1", "my_data_id2", "my_data_id3"], filter : "filter[data.field3][$in]=12&filter[data.field3][$in]=1&filter[data.field3][$in]=70"},
  { testname: "test $nin", res:["my_data_id4", "my_data_id5", "my_data_id6", "my_data_id7"], filter : "filter[data.field3][$nin]=12&filter[data.field3][$nin]=1&filter[data.field3][$nin]=70"},
  { testname: "test simple $regex", res:["my_data_id1", "my_data_id3"], filter : "filter[data.field1][$regex]=ir"},
  { testname: "test multi whith $regex", res:["my_data_id1"], filter : "filter[0][data.field1][$regex]=ir&filter[1][data.field1][$regex]=st"},
  { testname: "test $and whith $regex", res:["my_data_id1"], filter : "filter[$and][0][data.field1][$regex]=ir&filter[$and][1][data.field1][$regex]=st"},
  { testname: "test $or whith $regex", res:["my_data_id1", "my_data_id2", "my_data_id3"], filter : "filter[$or][0][data.field1][$regex]=ir&filter[$or][1][data.field1][$regex]=se"},
  { testname: "test simple $regex with option", res:["my_data_id1", "my_data_id3"], filter : "filter[data.field1][$regex]=IR&filter[data.field1][$options]=i"},
  { testname: "test $or $regex with one option", res:["my_data_id1", "my_data_id3"], filter : "filter[$or][0][data.field1][$regex]=IR&filter[$or][0][data.field1][$options]=i&filter[$or][1][data.field1][$regex]=SE"},
  { testname: "test $or $regex with two option", res:["my_data_id1", "my_data_id2", "my_data_id3"], filter : "filter[$or][0][data.field1][$regex]=IR&filter[$or][0][data.field1][$options]=i&filter[$or][1][data.field1][$regex]=SE&filter[$or][1][data.field1][$options]=i"},
  { testname: "test complex inseption $or $and $regex with options", res:["my_data_id1"], filter : "filter[$and][0][$or][0][data.field1][$regex]=IR&filter[$and][0][$or][0][data.field1][$options]=i&filter[$and][0][$or][1][data.field1][$regex]=SE&filter[$and][0][$or][1][data.field1][$options]=i&filter[$and][1][data.field1][$regex]=STR&filter[$and][1][data.field1][$options]=i"},
  { testname: "test complex inseption $or $and $regex with one root options", res:["my_data_id1", "my_data_id2", "my_data_id3"], filter : "filter[$or][0][data.field1][$regex]=SE&filter[$or][1][data.field1][$regex]=IR&filter[$options]=i"},
  { testname: "test multiple and inseption AND OR", res:["my_data_id1", "my_data_id2", "my_data_id3", "my_data_id4", "my_data_id5", "my_data_id6"], filter : "filter[$and][0][$or][data.field1]=second&filter[$and][0][$or][data.field1]=third&filter[$and][0][$or][data.field1]=fours&filter[$and][0][$or][data.field1]=fives&filter[$and][0][$or][data.field1]=sixs&filter[$and][0][$or][data.field3]=12&filter[$and][0][$or][data.field3]=1&filter[$and][0][$or][data.field3]=70&filter[$and][0][$or][data.field3]=125&filter[$and][0][$or][data.field5]=35&filter[$and][0][$or][data.field5]=2&filter[$and][0][$or][data.field5]=75"},
  { testname: "test table ", res:["my_data_id2", "my_data_id3"], filter : "filter[data.field1][$eq]=second&filter[data.field1][$eq]=third"},
  //{ testname: "test table $regex", res:["my_data_id1", "my_data_id3"], filter : "filter[data.field1][$regex]=ir&filter[data.field1][$regex]=st"},
  // { testname: "test $text", res:["my_data_id3"], filter : "filter[$text][$search]=thi"},
   // { testname: "test $text with $search $language $caseSensitive $diacriticSensitive", res:["my_data_id3"], filter : "filter[$text][$search]=THI&filter[$text][$language]=fr&filter[$text][$caseSensitive]=false&filter[$text][$diacriticSensitive]=false"},
]

const filter = [
  "",
  "filter[data.field1]=third",
  "filter[data.field3][$gt]=50",
  "filter[data.field3][$lt]=50",
  "filter[data.field3][$gte]=30&filter[data.field3][$lte]=80",
  "filter[$or][$and][0][$or][data.field1]=third&filter[$or][$and][0][$or][data.field2]=test3&filter[$or][$and][1][$or][data.field2]=test2&filter[$or][$and][2][data.field3][$gte]=56&filter[$or][$and][2][data.field3][$lte]=71",
  "filter[$or][data.field1]=third&filter[$or][data.field2]=test3&filter[$or][data.field3]=90",
  "filter[$or][data.field1]=third&filter[$or][data.field2]=test3&filter[$or][data.field2]=test2",
  "filter[$and][data.field1]=third&filter[$and][data.field2]=test2&filter[$and][data.field3]=70",
  "filter[$and][$or][data.field1]=third&filter[$and][$or][data.field2]=test3&filter[$and][data.field3]=90",
  "filter[$or][$and][0][$or][data.field1]=third&filter[$or][$and][0][$or][data.field2]=test3&filter[$or][$and][1][$or][data.field2]=test2&filter[$or][$and][2][data.field3][$gte]=23&filter[$or][$and][2][data.field3][$lte]=69"
]

describe('Datas', function () {

  before(TestHelper.startServer);
  before(TestHelper.seedDb);
  after(TestHelper.stopServer);

  describe('Authenticated service', function () {

    before(TestHelper.authorize);
  
    it('show list of public data (through services route)', function (done) {
      request()
        .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res);
          res.body.data.should.have.lengthOf(7);
          res.body.data[6].id.should.eql('my_data_id1');
          res.body.data[6].type.should.eql('donnees');
          res.body.data[6].attributes.should.eql({
            field1: 'first string',
            field2: 'second string',
            field3: 12,
            field4: {'key' : 'value'},
            field5: 75
          });
          done();
        });
     });

    it('show list of public data (though collections route)', function (done) {
      request()
        .get('/api/v1/collections/my_route_id1/relationships/donnees')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res);
          res.body.data.should.have.lengthOf(7);
          res.body.data[6].id.should.eql('my_data_id1');
          res.body.data[6].type.should.eql('donnees');
          res.body.data[6].attributes.should.eql({
            field1: 'first string',
            field2: 'second string',
            field3: 12,
            field4: {'key' : 'value'},
            field5: 75
          });
          done();
        });
    });

    describe('Errors', function() {

      it('404', function (done) {
        request()
          .get('/api/v1/collections/my_route_id1/relationships/donnees/hkgdhjqsDGKSQGDKQDS')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isSuccess: false, status: 404});
            done();
          });
      });

    });

    describe('Relationships', function() {

      describe('Collections', function() {

        it('includes route', function (done) {
          request()
            .get('/api/v1/collections/my_route_id1/relationships/donnees?include=collections')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res);
              res.body.data[0].relationships.should.have.property('collections');
              res.body.data[0].relationships.collections.should.eql({
                links: {self: 'http://localhost:3010/api/v1/collections/my_route_id1'},
                data: {
                  type: "collections",
                  id: "my_route_id1"
                }
              });
              done();
            });
        });

        it('includes service', function (done) {
          request()
            .get('/api/v1/collections/my_route_id1/relationships/donnees?include=services')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res);
              res.body.data[0].relationships.should.have.property('services');
              res.body.data[0].relationships.services.should.eql({
                links: {self: 'http://localhost:3010/api/v1/services/my_client_id'},
                data: {
                  type: "services",
                  id: "my_client_id"
                }
              });
              done();
            });
        });

        it('includes route & service', function (done) {
          request()
            .get('/api/v1/collections/my_route_id1/relationships/donnees?include=collections,services')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res);
              res.body.data[0].relationships.should.have.property('collections');
              res.body.data[0].relationships.collections.should.eql({
                links: {self: 'http://localhost:3010/api/v1/collections/my_route_id1'},
                data: {
                  type: "collections",
                  id: "my_route_id1"
                }
              });
              res.body.data[0].relationships.should.have.property('services');
              res.body.data[0].relationships.services.should.eql({
                links: {self: 'http://localhost:3010/api/v1/services/my_client_id'},
                data: {
                  type: "services",
                  id: "my_client_id"
                }
              });
              done();
            });
        });

      });

      describe('Resource', function() {

        it('includes route', function (done) {
          request()
            .get('/api/v1/collections/my_route_id1/relationships/donnees/my_data_id1?include=collections')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isCollection: false});
              res.body.data.relationships.should.have.property('collections');
              res.body.data.relationships.collections.should.eql({
                links: {self: 'http://localhost:3010/api/v1/collections/my_route_id1'},
                data: {
                  type: "collections",
                  id: "my_route_id1"
                }
              });
              done();
            });
        });

        it('includes service', function (done) {
          request()
            .get('/api/v1/collections/my_route_id1/relationships/donnees/my_data_id1?include=services')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isCollection: false});
              res.body.data.relationships.should.have.property('services');
              res.body.data.relationships.services.should.eql({
                links: {self: 'http://localhost:3010/api/v1/services/my_client_id'},
                data: {
                  type: "services",
                  id: "my_client_id"
                }
              });
              done();
            });
        });

        it('includes route & service', function (done) {
          request()
            .get('/api/v1/collections/my_route_id1/relationships/donnees/my_data_id1?include=collections,services')
            .query({access_token: TestHelper.getAccessToken()})
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isCollection: false});
              res.body.data.relationships.should.have.property('collections');
              res.body.data.relationships.collections.should.eql({
                links: {self: 'http://localhost:3010/api/v1/collections/my_route_id1'},
                data: {
                  type: "collections",
                  id: "my_route_id1"
                }
              });
              res.body.data.relationships.should.have.property('services');
              res.body.data.relationships.services.should.eql({
                links: {self: 'http://localhost:3010/api/v1/services/my_client_id'},
                data: {
                  type: "services",
                  id: "my_client_id"
                }
              });
              done();
            });
        });

      });

    });
  
    
    describe('Sort service', function () {
  
      describe('Sort Classic', function () {
  
        SortClassic.forEach(function (objSortClassic) {
          it(objSortClassic.testname, function (done) {
            request()
              .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+ objSortClassic.sort)
              .query({access_token: TestHelper.getAccessToken()})
              .end(function (err, res) {
                TestHelper.checkResponse(res);
                res.body.data.should.have.lengthOf(objSortClassic.res.length);
                for (var j = 0; j < objSortClassic.res.length; ++j) {
                  let exists = false;
                  res.body.data.forEach(function(data) {
                    if (data.id === objSortClassic.res[j]) {
                      exists = true;
                      data.type.should.eql('donnees');
                      //if (objSortClassic.res[j] === "my_data_id7")
                      // console.log(JSON.stringify(data));
                      if (data.attributes !== undefined) {
                        data.attributes.should.eql({
                          field1: datadb[objSortClassic.res[j]].field1,
                          field2: datadb[objSortClassic.res[j]].field2,
                          field3: datadb[objSortClassic.res[j]].field3,
                          field4: datadb[objSortClassic.res[j]].field4,
                          field5: datadb[objSortClassic.res[j]].field5
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
  
      describe('Sort Multi', function () {
  
        SortMulti.forEach(function (objSortMulti) {
          it(objSortMulti.testname, function (done) {
            request()
              .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+ objSortMulti.sort)
              .query({access_token: TestHelper.getAccessToken()})
              .end(function (err, res) {
                TestHelper.checkResponse(res);
                res.body.data.should.have.lengthOf(objSortMulti.res.length);
                for (var j = 0; j < objSortMulti.res.length; ++j) {
                  let exists = false;
                  res.body.data.forEach(function(data) {
                    if (data.id === objSortMulti.res[j]) {
                      exists = true;
                      data.type.should.eql('donnees');
                      if (data.attributes !== undefined) {
                        data.attributes.should.eql({
                          field1: datadb[objSortMulti.res[j]].field1,
                          field2: datadb[objSortMulti.res[j]].field2,
                          field3: datadb[objSortMulti.res[j]].field3,
                          field4: datadb[objSortMulti.res[j]].field4,
                          field5: datadb[objSortMulti.res[j]].field5
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
  
      
  
      
      describe('Sort and filter', function () {
  
        SortWithFilter.forEach(function (objSortWithFilter) {
          it(objSortWithFilter.testname, function (done) {
            request()
              .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+ objSortWithFilter.filter + "&"  + objSortWithFilter.sort)
              .query({access_token: TestHelper.getAccessToken()})
              .end(function (err, res) {
                TestHelper.checkResponse(res);
                res.body.data.should.have.lengthOf(objSortWithFilter.res.length);
                for (var j = 0; j < objSortWithFilter.res.length; ++j) {
                  let exists = false;
                  res.body.data.forEach(function(data) {
                    if (data.id === objSortWithFilter.res[j]) {
                      exists = true;
                      data.type.should.eql('donnees');
                      if (data.attributes !== undefined) {
                        data.attributes.should.eql({
                          field1: datadb[objSortWithFilter.res[j]].field1,
                          field2: datadb[objSortWithFilter.res[j]].field2,
                          field3: datadb[objSortWithFilter.res[j]].field3,
                          field4: datadb[objSortWithFilter.res[j]].field4,
                          field5: datadb[objSortWithFilter.res[j]].field5
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
      describe('Sort ERROR', function () {
        SortError.forEach(function(objSortError) {
          it(objSortError.testname, function (done) {
            request()
              .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?' + objSortError.sort)
              .query({access_token: TestHelper.getAccessToken()})
              .end(function (err, res) {
                err.status.should.eql(400);
                done();
              });
          });
        });
    
      });
      
    });
    
    describe('Filter service', function () {
  
      describe('Filter ERROR', function () {
      
        filterError.forEach(function(objfiltererror) {
          it(objfiltererror.testname, function (done) {
            request()
              .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?' + objfiltererror.filter)
              .query({access_token: TestHelper.getAccessToken()})
              .end(function (err, res) {
                err.status.should.eql(400);
                //TestHelper.checkResponse(res);
                // res.body.data.should.have.lengthOf(0);
                // console.log(JSON.stringify(res.body.data));
                done();
              });
          });
        });
        
      });
  
      describe('Filter TEST', function () {
      
        filterClassic.forEach(function(objfilterclassic) {
          it(objfilterclassic.testname, function (done) {
            request()
              .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?' + objfilterclassic.filter)
              .query({access_token: TestHelper.getAccessToken()})
              .end(function (err, res) {
                TestHelper.checkResponse(res);
                res.body.data.should.have.lengthOf(objfilterclassic.res.length);
                for (var j = 0; j < objfilterclassic.res.length; ++j) {
                  let exists = false;
                  res.body.data.forEach(function(data) {
                    if (data.id === objfilterclassic.res[j]) {
                      exists = true;
                      data.type.should.eql('donnees');
                      //if (objfilterclassic.res[j] === "my_data_id7")
                      // console.log(JSON.stringify(data));
                      if (data.attributes !== undefined) {
                        data.attributes.should.eql({
                          field1: datadb[objfilterclassic.res[j]].field1,
                          field2: datadb[objfilterclassic.res[j]].field2,
                          field3: datadb[objfilterclassic.res[j]].field3,
                          field4: datadb[objfilterclassic.res[j]].field4,
                          field5: datadb[objfilterclassic.res[j]].field5
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
      
      it('simple filter 1', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+filter[1])
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(1);
            res.body.data[0].id.should.eql('my_data_id3');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
              field1: "third",
              field2: "test2",
              field3: 70,
              field4: {'key' : 'value'},
              field5: 85
            });
            done();
          });
      });

      it('simple filter 2', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+filter[2])
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(3);
            res.body.data[2].id.should.eql('my_data_id3');
            res.body.data[2].type.should.eql('donnees');
            res.body.data[2].attributes.should.eql({
              field1: "third",
              field2: "test2",
              field3: 70,
              field4: {'key' : 'value'},
              field5: 85
            });
            res.body.data[1].id.should.eql('my_data_id5');
            res.body.data[1].type.should.eql('donnees');
            res.body.data[1].attributes.should.eql({
              field1: "fives",
              field2: "test4",
              field3: 80,
              field4: {'key' : 'value'},
              field5: 2
            });
            res.body.data[0].id.should.eql('my_data_id6');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
              field1: "sixs",
              field2: "test5",
              field3: 125,
              field4: {'key' : 'value'},
              field5: 185
            });
            done();
          });
      });

      it('simple filter 3', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+filter[3])
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(3);
            res.body.data[2].id.should.eql('my_data_id1');
            res.body.data[2].type.should.eql('donnees');
            res.body.data[2].attributes.should.eql({
              field1: 'first string',
              field2: 'second string',
              field3: 12,
              field4: {'key' : 'value'},
              field5: 75
            });
            res.body.data[1].id.should.eql('my_data_id2');
            res.body.data[1].type.should.eql('donnees');
            res.body.data[1].attributes.should.eql({
              field1: 'second',
              field2: 'test1',
              field3: 1,
              field4: {'key' : 'value'},
              field5: 2
            });
            res.body.data[0].id.should.eql('my_data_id4');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
              field1: 'fours',
              field2: 'test3',
              field3: 43,
              field4: {'key' : 'value'},
              field5: 35
            });
            done();
          });
      });

      it('simple filter 4', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+filter[4])
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(3);
            res.body.data[2].id.should.eql('my_data_id3');
            res.body.data[2].type.should.eql('donnees');
            res.body.data[2].attributes.should.eql({
              field1: 'third',
              field2: 'test2',
              field3: 70,
              field4: {'key' : 'value'},
              field5: 85
            });
            res.body.data[1].id.should.eql('my_data_id4');
            res.body.data[1].type.should.eql('donnees');
            res.body.data[1].attributes.should.eql({
              field1: 'fours',
              field2: 'test3',
              field3: 43,
              field4: {'key' : 'value'},
              field5: 35
            });
            res.body.data[0].id.should.eql('my_data_id5');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
              field1: 'fives',
              field2: 'test4',
              field3: 80,
              field4: {'key' : 'value'},
              field5: 2
            });
            done();
          });
      });

      it('simple filter 5', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+filter[5])
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(1);
            res.body.data[0].id.should.eql('my_data_id3');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
              field1: 'third',
              field2: 'test2',
              field3: 70,
              field4: {'key' : 'value'},
              field5: 85
            });
            done();
          });
      });

      it('simple filter 6', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+filter[6])
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(2);
            res.body.data[1].id.should.eql('my_data_id3');
            res.body.data[1].type.should.eql('donnees');
            res.body.data[1].attributes.should.eql({
              field1: 'third',
              field2: 'test2',
              field3: 70,
              field4: {'key' : 'value'},
              field5: 85
            });
            res.body.data[0].id.should.eql('my_data_id4');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
              field1: 'fours',
              field2: 'test3',
              field3: 43,
              field4: {'key' : 'value'},
              field5: 35
            });
            done();
          });
      });

      it('advanced filter 7', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+filter[7])
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(2);
            res.body.data[1].id.should.eql('my_data_id3');
            res.body.data[1].type.should.eql('donnees');
            res.body.data[1].attributes.should.eql({
              field1: 'third',
              field2: 'test2',
              field3: 70,
              field4: {'key' : 'value'},
              field5: 85
            });
            res.body.data[0].id.should.eql('my_data_id4');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
              field1: 'fours',
              field2: 'test3',
              field3: 43,
              field4: {'key' : 'value'},
              field5: 35
            });
            done();
          });
      });

      it('advanced filter 8', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?'+filter[8])
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(1);
            res.body.data[0].id.should.eql('my_data_id3');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
              field1: 'third',
              field2: 'test2',
              field3: 70,
              field4: {'key' : 'value'},
              field5: 85
            });
            done();
          });
      });

    });

    describe('POST data', function() {

      describe('errors management', function() {

        it('need "data" field to be set', function (done) {
          request()
            .post('/api/v1/collections/my_route_id1/relationships/donnees')
            .send({
              access_token: TestHelper.getAccessToken()
            })
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isSuccess: false, status: 400});
              res.body.errors.should.include('missing_parameter');
              res.body.errors.should.include('"data" is required');
              done();
            });
        });

        it('need "type", "id" and "attributes" fields to be set', function (done) {
          request()
            .post('/api/v1/collections/my_route_id1/relationships/donnees')
            .send({
              access_token: TestHelper.getAccessToken(),
              data: {}
            })
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isSuccess: false, status: 400});
              res.body.errors.should.include('missing_parameter');
              res.body.errors.should.include('"type" is required');
              res.body.errors.should.include('"id" is required');
              res.body.errors.should.include('"attributes" is required');
              done();
            });
        });

        it('need "type" to be equal to "donnees"', function (done) {
          request()
            .post('/api/v1/collections/my_route_id1/relationships/donnees')
            .send({
              access_token: TestHelper.getAccessToken(),
              data: {
                id: "hqgkvcbekhjfbld",
                type: "invalid_type",
                attributes: {}
              }
            })
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isSuccess: false, status: 400});
              res.body.errors.should.include('invalid_paramater');
              res.body.errors.should.include('"type" must be equal to "donnees"');
              done();
            });
        });

        it('need required fields to be set (1)', function (done) {
          request()
            .post('/api/v1/collections/my_route_id1/relationships/donnees')
            .send({
              access_token: TestHelper.getAccessToken(),
              data: {
                id: "hqgkvcbekhjfbld",
                type: "donnees",
                attributes: {}
              }
            })
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isSuccess: false, status: 400});
              res.body.errors.should.include('missing_parameter');
              res.body.errors.should.include('"field1" is required');
              res.body.errors.should.include('"field2" is required');
              res.body.errors.should.include('"field3" is required');
              res.body.errors.should.include('"field4" is required');
              res.body.errors.should.include('"field5" is required');
              done();
            });
        });

        it('need required fields to be set (2)', function (done) {
          request()
            .post('/api/v1/collections/my_route_id1/relationships/donnees')
            .send({
              access_token: TestHelper.getAccessToken(),
              data: {
                id: "hqgkvcbekhjfbld",
                type: "donnees",
                attributes: {
                  field1: "",
                  field2: ""
                }
              }
            })
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isSuccess: false, status: 400});
              res.body.errors.should.include('missing_parameter');
              res.body.errors.should.include('"field1" is required');
              res.body.errors.should.include('"field2" is required');
              res.body.errors.should.include('"field3" is required');
              res.body.errors.should.include('"field4" is required');
              res.body.errors.should.include('"field5" is required');
              done();
            });
        });

        it('need required fields to be the same type', function (done) {
          request()
            .post('/api/v1/collections/my_route_id1/relationships/donnees')
            .send({
              access_token: TestHelper.getAccessToken(),
              data: {
                id: "hqgkvcbekhjfbld",
                type: "donnees",
                attributes: {
                  field1: "STRING",
                  field2: "STRING",
                  field3: "STRING",
                  field4: "STRING",
                  field5: "STRING"
                }
              }
            })
            .end(function (err, res) {
              TestHelper.checkResponse(res, {isSuccess: false, status: 400});
              res.body.errors.should.include('invalid_format');
              res.body.errors.should.include('"field3" must be NUMERIC');
              res.body.errors.should.include('"field4" must be JSON');
              res.body.errors.should.include('"field5" must be AMOUNT');
              done();
            });
        });

      });

      describe('Success create (201) and then update (200)', function() {

        it('save new data', function(done) {
          var attributes = {
            field1: "STRING",
            field2: "STRING",
            field3: 42,
            field4: {test: 'ok'},
            field5: 999.99
          };

          // post trough API
          request()
            .post('/api/v1/collections/my_route_id1/relationships/donnees')
            .send({
              access_token: TestHelper.getAccessToken(),
              data: {
                id: "hqgkvcbekhjfbld",
                type: "donnees",
                attributes: attributes
              }
            })
            .end(function (err, res) {
              if (err)
                return done(err);
              TestHelper.checkResponse(res, {status: 201});

              // get from database
              DataModel.io.findOne({dataId: "hqgkvcbekhjfbld"}, function(err, newObj) {
                if (err)
                  done(err);
                newObj.dataId.should.eq("hqgkvcbekhjfbld");
                newObj.data.should.eql(attributes);

                // update trough API
                attributes.field1 = "NEW STRING1";
                attributes.field2 = "NEW STRING2";
                attributes.field3 = -56;
                attributes.field4 = {};
                attributes.field5 = 12;
                request()
                  .post('/api/v1/collections/my_route_id1/relationships/donnees')
                  .send({
                    access_token: TestHelper.getAccessToken(),
                    data: {
                      id: "hqgkvcbekhjfbld",
                      type: "donnees",
                      attributes: attributes
                    }
                  })
                  .end(function (err, res) {
                    if (err)
                      return done(err);
                    TestHelper.checkResponse(res, {status: 200});

                    // get from database
                    DataModel.io.findOne({dataId: "hqgkvcbekhjfbld"}, function(err, newObj) {
                      if (err)
                        done(err);
                      newObj.dataId.should.eq("hqgkvcbekhjfbld");
                      newObj.data.should.eql(attributes);
                      done();
                    });
                  });
              });
            });
        });
      });


    });

  });
  
  

});
