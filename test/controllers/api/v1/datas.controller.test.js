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
          res.body.data.should.have.lengthOf(6);
          res.body.data[0].id.should.eql('my_data_id1');
          res.body.data[0].type.should.eql('donnees');
          res.body.data[0].attributes.should.eql({
            field1: 'first string',
            field2: 'second string',
            field3: 12,
            field4: {'key' : 'value'},
            field5: 75
          });
          done();
        });
    });
  
    describe('Filter service', function () {
    
      it('simple filter one field value', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?filter[data.field1]=third')
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
  
      it('simple filter one field $gt NUMERIC', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?filter[data.field3][$gt]=50')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(3);
            res.body.data[0].id.should.eql('my_data_id3');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
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
            res.body.data[2].id.should.eql('my_data_id6');
            res.body.data[2].type.should.eql('donnees');
            res.body.data[2].attributes.should.eql({
              field1: "sixs",
              field2: "test5",
              field3: 125,
              field4: {'key' : 'value'},
              field5: 185
            });
            done();
          });
      });
  
      it('simple filter one field $lt NUMERIC', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?filter[data.field3][$lt]=50')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(3);
            res.body.data[0].id.should.eql('my_data_id1');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
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
            res.body.data[2].id.should.eql('my_data_id4');
            res.body.data[2].type.should.eql('donnees');
            res.body.data[2].attributes.should.eql({
              field1: 'fours',
              field2: 'test3',
              field3: 43,
              field4: {'key' : 'value'},
              field5: 35
            });
            done();
          });
      });
  
      it('simple filter $gte $lte NUMERIC', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?filter[data.field3][$gte]=30&filter[data.field3][$lte]=80')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(3);
            res.body.data[0].id.should.eql('my_data_id3');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
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
            res.body.data[2].id.should.eql('my_data_id5');
            res.body.data[2].type.should.eql('donnees');
            res.body.data[2].attributes.should.eql({
              field1: 'fives',
              field2: 'test4',
              field3: 80,
              field4: {'key' : 'value'},
              field5: 2
            });
            done();
          });
      });
  
      // it('simple filter $in $nin', function (done) {
      //   request()
      //     .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?filter[data.field3][$and][$or][$ne]=70&filter[data.field3][$and][$or][$ne]=43&filter[data.field3][$and][$or][$ne]=80')
      //     .query({access_token: TestHelper.getAccessToken()})
      //     .end(function (err, res) {
      //       TestHelper.checkResponse(res);
      //       res.body.data.should.have.lengthOf(3);
      //       res.body.data[0].id.should.eql('my_data_id3');
      //       res.body.data[0].type.should.eql('donnees');
      //       res.body.data[0].attributes.should.eql({
      //         field1: 'third',
      //         field2: 'test2',
      //         field3: 70,
      //         field4: {'key' : 'value'},
      //         field5: 85
      //       });
      //       res.body.data[1].id.should.eql('my_data_id4');
      //       res.body.data[1].type.should.eql('donnees');
      //       res.body.data[1].attributes.should.eql({
      //         field1: 'fours',
      //         field2: 'test3',
      //         field3: 43,
      //         field4: {'key' : 'value'},
      //         field5: 35
      //       });
      //       res.body.data[2].id.should.eql('my_data_id5');
      //       res.body.data[2].type.should.eql('donnees');
      //       res.body.data[2].attributes.should.eql({
      //         field1: 'fives',
      //         field2: 'test4',
      //         field3: 80,
      //         field4: {'key' : 'value'},
      //         field5: 2
      //       });
      //       done();
      //     });
      // });
      
      it('advanced filter $gte $lte NUMERIC', function (done) {
        request()
          .get('/api/v1/services/my_client_id/relationships/collections/my_route_id1/relationships/donnees?filter[$or][$and][0][$or][field1]=third&filter[$or][$and][0][$or][field1]=fours&filter[$or][$and][1][$or][field2]=test3&filter[$or][$and][1][$or][field2]=test2&filter[$or][$and][field3][$gte]=43&filter[$or][$and][field3][$lte]=80')
          .query({access_token: TestHelper.getAccessToken()})
          .end(function (err, res) {
            TestHelper.checkResponse(res);
            res.body.data.should.have.lengthOf(6);
            res.body.data[0].id.should.eql('my_data_id1');
            res.body.data[0].type.should.eql('donnees');
            res.body.data[0].attributes.should.eql({
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
            res.body.data[2].id.should.eql('my_data_id3');
            res.body.data[2].type.should.eql('donnees');
            res.body.data[2].attributes.should.eql({
              field1: 'third',
              field2: 'test2',
              field3: 70,
              field4: {'key' : 'value'},
              field5: 85
            });
            res.body.data[3].id.should.eql('my_data_id4');
            res.body.data[3].type.should.eql('donnees');
            res.body.data[3].attributes.should.eql({
              field1: 'fours',
              field2: 'test3',
              field3: 43,
              field4: {'key' : 'value'},
              field5: 35
            });
            res.body.data[4].id.should.eql('my_data_id5');
            res.body.data[4].type.should.eql('donnees');
            res.body.data[4].attributes.should.eql({
              field1: 'fives',
              field2: 'test4',
              field3: 80,
              field4: {'key' : 'value'},
              field5: 2
            });
            res.body.data[5].id.should.eql('my_data_id6');
            res.body.data[5].type.should.eql('donnees');
            res.body.data[5].attributes.should.eql({
              field1: 'sixs',
              field2: 'test5',
              field3: 125,
              field4: {'key' : 'value'},
              field5: 185
            });
            done();
          });
      });
      
    });
    
  });
  
  

});
