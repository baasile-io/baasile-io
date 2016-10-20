'use strict';

const testHelper = require('../test.helper.js'),
    TestHelper = new testHelper(),
    filterService = require('../../services/filter.service.js'),
    FilterService = new filterService(TestHelper.getOptions());

var defaultFilter = {'defaultKey': 'defaultValue'};

describe('Filter service', function () {

  describe('Basic', function () {

    it('returns default json', function (done) {
      FilterService.buildMongoQuery(defaultFilter)
        .should.eql(defaultFilter);
      done();
    });

    it('add one filter', function (done) {
      var filter = {'key': 'value'};
      var expected = {
        '$and': [
          {'key': {'$eq': 'value'}}
        ]
      };
      FilterService.buildMongoQuery({}, filter).should.eql(expected);
      done();
    });

    it('add one filter with default json', function (done) {
      var filter = {'key': 'value'};
      var expected = {
        '$and': [
          {'defaultKey': 'defaultValue'},
          {'key': {'$eq': 'value'}}
        ]
      };
      FilterService.buildMongoQuery(defaultFilter, filter).should.eql(expected);
      done();
    });

    it('add two filters', function (done) {
      var filters = {
        'key1': 'value1',
        'key2': 'value2'
      };
      var expected = {
        '$and': [
          {'key1': {'$eq': 'value1'}},
          {'key2': {'$eq': 'value2'}}
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add two filters with default json', function (done) {
      var filters = {
        'key1': 'value1',
        'key2': 'value2'
      };
      var expected = {
        '$and': [
          {'defaultKey': 'defaultValue'},
          {'key1': {'$eq': 'value1'}},
          {'key2': {'$eq': 'value2'}}
        ]
      };
      FilterService.buildMongoQuery(defaultFilter, filters).should.eql(expected);
      done();
    });

    it('add two filters with AND operator', function (done) {
      var filters = {
        '$and': {
          'key1': 'value1',
          'key2': 'value2'
        }
      };
      var expected = {
        '$and': [
          {
            '$and': [
              {'key1': {'$eq': 'value1'}},
              {'key2': {'$eq': 'value2'}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add two filters with OR operator', function (done) {
      var filters = {
        '$or': {
          'key1': 'value1',
          'key2': 'value2'
        }
      };
      var expected = {
        '$and': [
          {
            '$or': [
              {'key1': {'$eq': 'value1'}},
              {'key2': {'$eq': 'value2'}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add two filters with OR operator and default filters', function (done) {
      var filters = {
        '$or': {
          'key1': 'value1',
          'key2': 'value2'
        }
      };
      var expected = {
        '$and': [
          {'defaultKey': 'defaultValue'},
          {
            '$or': [
              {'key1': {'$eq': 'value1'}},
              {'key2': {'$eq': 'value2'}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery(defaultFilter, filters).should.eql(expected);
      done();
    });

    it('add one filter with two values', function (done) {
      var filters = {
        'key': ['value1', 'value2']
      };
      var expected = {
        '$and': [
          {'key': {'$in': ['value1', 'value2']}}
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add one filter with OR operator and two values', function (done) {
      var filters = {
        'key': {
          '$or': ['value1', 'value2']
        }
      };
      var expected = {
        '$and': [
          {
            'key': {
              '$or': [
                {'$eq': 'value1'},
                {'$eq': 'value2'}
              ]
            }
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add one filter with two advanced values', function (done) {
      var filters = {
        'key': {
          '$ne': 'value1',
          '$regex': 'value2'
        }
      };
      var expected = {
        '$and': [
          {
            'key': {
              '$ne': 'value1',
              '$regex': 'value2'
            }
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add one filter with OR operator with two advanced values', function (done) {
      var filters = {
        'key': {
          '$or': {
            '$ne': 'value1',
            '$regex': 'value2'
          }
        }
      };
      var expected = {
        '$and': [
          {
            'key': {
              '$or': [
                {'$ne': 'value1'},
                {'$regex': 'value2'}
              ]
            }
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add AND operator with one filter with two values', function (done) {
      var filters = {
        '$and': {
          'key': ['value1', 'value2']
        }
      };
      var expected = {
        '$and': [
          {
            '$and': [
              {'key': {'$in': ['value1' , 'value2']}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add OR operator with one filter with two values', function (done) {
      var filters = {
        '$or': {
          'key': ['value1', 'value2']
        }
      };
      var expected = {
        '$and': [
          {
            '$or': [
              {'key': {'$in': ['value1', 'value2']}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

  });

  describe('Advanced', function () {
  
    var alradyin = {"route":"57f1fa52f0a9620f445bba67"};
    var whiteFields = [
      {"name":"data.field1","key":"STRING"},
      {"name":"data.field2","key":"STRING"},
      {"name":"data.field3","key":"NUMERIC"},
      {"name":"data.field4","key":"JSON"},
      {"name":"data.field5","key":"AMOUNT"}
      ];
    
    it('array containing 2 conditional structures', function (done) {
      var filters = [
        {
          '$or': {
            'key': ['value1', 'value2']
          }
        },
        {
          '$and': {
            'key1': 'value10',
            'key2': 'value20'
          }
        }
      ];
      var expected = {
        '$and': [
          {
            '$or': [
              {'key': {'$in': ['value1', 'value2']}}
            ]
          },
          {
            '$and': [
              {'key1': {'$eq': 'value10'}},
              {'key2': {'$eq': 'value20'}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('add one filter with multiple dimension after value', function (done) {
      var filters = {
        'key': {
          '$and': [
            {
              '$or': {
                '$ne': ['valueA1', 'valueA2']
              }
            },
            {
              '$or': {
                '$ne': ['valueB1', 'valueB2']
              }
            }
          ]
        }
      };
      var expected = {
        '$and': [
          {
            'key': {
              '$and': [
                {
                  '$or': [
                    {'$nin': ['valueA1', 'valueA2']}
                  ]},
                {
                  '$or': [
                    {'$nin': ['valueB1', 'valueB2']}
                  ]}
              ]
            }
          }]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

    it('multiple dimensions', function (done) {
      // ?filter[$or][$and][0][$or][keyA]=valueA1
      // &filter[$or][$and][0][$or][keyA]=valueA2
      // &filter[$or][$and][1][$or][keyB]=valueB1
      // &filter[$or][$and][1][$or][keyB]=valueB2
      // &filter[$or][keyC]=valueC
      // &filter[$or][keyD]=valueD1
      // &filter[$or][keyD]=valueD2
      // &filter[$or][keyD]=valueD3
      var filters = {
        '$or': {
          '$and': [
            {
              '$or': {
                'keyA': ['valueA1', 'valueA2']
              }
            },
            {
              '$or': {
                'keyB': ['valueB1', 'valueB2']
              }
            }
          ],
          'keyC': 'valueC',
          'keyD': ['valueD1', 'valueD2', 'valueD3']
        }
      };
      var expected = {
        '$and': [
          {
            '$or': [
              {
                '$and': [
                  {
                    '$or': [
                      {'keyA': {'$in': ['valueA1', "valueA2"]}}
                    ]
                  },
                  {
                    '$or': [
                      {'keyB': {'$in': ['valueB1', "valueB2"]}}
                    ]
                  }
                ]
              },
              {'keyC': {'$eq': 'valueC'}},
              {'keyD': {'$in': ['valueD1', "valueD2", "valueD3"]}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });


    it('try functional test 1', function (done) {
      // filter[data.field1]=third
      var filters = {"data.field1":"third"};
      var expected = {"$and": [
        {
          "route":"57f1fa52f0a9620f445bba67"
        },
        {
          "data.field1": {
            "$eq":"third"
          }
        }
        ]};
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });

    it('try functional test 2', function (done) {
      // filter[data.field3][$gt]=50
      var filters = {"data.field3":{"$gt":"50"}};
      var expected = {"$and":[
        {
          "route":"57f1fa52f0a9620f445bba67"
        },{
          "data.field3": {
            "$gt":50
          }
        }
        ]};
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });

    it('try functional test 3', function (done) {
      // filter[data.field3][$lt]=50
      var filters = {"data.field3":{"$lt":"50"}};
      var expected = {"$and":[
        {
          "route":"57f1fa52f0a9620f445bba67"
        },{
          "data.field3": {
            "$lt":50
          }
        }
      ]};
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });

    it('try functional test 4', function (done) {
      // filter[data.field3][$gte]=30&filter[data.field3][$lte]=80
      var filters = {"data.field3":{"$gte":"30","$lte":"80"}};
      var expected = {"$and":[{"route":"57f1fa52f0a9620f445bba67"},{"data.field3":{"$gte":30,"$lte":80}}]};
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });

    it('try functional test 5', function (done) {
      // filter[$or][$and][0][$or][data.field1]=third&filter[$or][$and][0][$or][data.field2]=test3&filter[$or][$and][1][$or][data.field2]=test2&filter[$or][$and][2][data.field3][$gte]=43&filter[$or][$and][2][data.field3][$lte]=80
      var filters = {
        "$or": {
          "$and":[{
            "$or": {
              "data.field1":"third",
              "data.field2":"test3"
            }
          },{
            "$or":{
              "data.field2":"test2"
            }
          },{
            "data.field3":{
              "$gte":"43",
              "$lte":"80"
            }
          }]
        }
      };
      var expected = {
        "$and":[{
          "route":"57f1fa52f0a9620f445bba67"}, {
          "$or": [{
            "$and": [{
              "$or": [{
                "data.field1": {
                  "$eq": "third"
                }
              }, {
                "data.field2": {
                  "$eq": "test3"
                }
              }]
            }, {
              "$or": [{
                "data.field2": {
                  "$eq": "test2"
                }
              }]
            }, {
              "data.field3": {
                "$gte": 43, "$lte": 80
              }
            }]
          }]
        }]
      };
      //console.log("----test 5----");
      //console.log(JSON.stringify(FilterService.buildMongoQuery(alradyin, filters, whiteFields)));
      //console.log("----test 5----");
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });
  
    it('try functional test 6', function (done) {
      // filter[$or][data.field1]=third&filter[$or][data.field2]=test3&filter[$or][data.field3]=90
      var filters = {"$or":{"data.field1":"third","data.field2":"test3","data.field3":90}};
      var expected = {"$and":[
          {"route":"57f1fa52f0a9620f445bba67"},
          {"$or":[
            {"data.field1":{"$eq":"third"}},
            {"data.field2":{"$eq":"test3"}},
            {"data.field3":{"$eq": 90}}
          ]}
        ]}
      // console.log("---test 6-----");
      // console.log("alradyin:"+JSON.stringify(alradyin));
      // console.log("filters:"+JSON.stringify(filters));
      // console.log("whiteFields:"+JSON.stringify(whiteFields));
      // console.log(JSON.stringify(FilterService.buildMongoQuery(alradyin, filters, whiteFields)));
      // console.log("----test 6----");
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });

    it('try functional test 7', function (done) {
      // filter[$or][data.field1]=third&filter[$or][data.field2]=test3&filter[$or][data.field2]=test2
      var filters = {"$or":{"data.field1":"third","data.field2":["test3","test2"]}};
      // var expected = {"$and":[{
      //   "route":"57f1fa52f0a9620f445bba67"}, {
      //     "$or":[{
      //       "data.field1": {
      //         "$eq":"third"
      //       }
      //     }, {
      //       "data.field2":{
      //         "$eq":"test3"
      //       }
      //     },{
      //       "data.field2": {
      //         "$eq":"test2"
      //       }
      //     }]
      //   }]};
      var expected = {"$and":[{
        "route":"57f1fa52f0a9620f445bba67"}, {
        "$or":[{
          "data.field1": {
            "$eq":"third"
          }
        }, {
          "data.field2":{
            "$in": [
              "test3",
              "test2"
              ]
          }
        }]
      }]};
      // console.log("----test 7----");
      // console.log("alradyin:"+JSON.stringify(alradyin));
      // console.log("filters:"+JSON.stringify(filters));
      // console.log("whiteFields:"+JSON.stringify(whiteFields));
      // console.log(JSON.stringify(FilterService.buildMongoQuery(alradyin, filters, whiteFields)));
      // console.log("----test 7----");
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });

    it('try functional test 8', function (done) {
      // filter[$and][data.field1]=third&filter[$and][data.field2]=test3&filter[$and][data.field3]=90
      var filters = {"$and":{"data.field1":"third","data.field2":"test3","data.field3":90}};
      var expected = {"$and":[{
        "route":"57f1fa52f0a9620f445bba67"
      },{
        "$and":[{
          "data.field1":{
            "$eq":"third"
          }
        },{
          "data.field2":{
            "$eq":"test3"
          }
        },{
          "data.field3":{
            "$eq":90
          }
        }]
      }]};
      // console.log("---test 8-----");
      // console.log("alradyin:"+JSON.stringify(alradyin));
      // console.log("filters:"+JSON.stringify(filters));
      // console.log("whiteFields:"+JSON.stringify(whiteFields));
      // console.log(JSON.stringify(FilterService.buildMongoQuery(alradyin, filters, whiteFields)));
      // console.log("---test 8-----");
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });

    it('try functional test 9', function (done) {
      // filter[$and][$or][data.field1]=third&filter[$and][$or][data.field2]=test3&filter[$and][data.field3]=90
      var filters = {"$and":{"$or":{"data.field1":"third","data.field2":"test3"},"data.field3":90}};
      var expected = {"$and":[
        {"route":"57f1fa52f0a9620f445bba67"},
        {"$and":[
          {
            "$or":[{
              "data.field1":{
                "$eq":"third"
              }
            },{
              "data.field2":{
                "$eq":"test3"
              }
            }]
          },
          {
            "data.field3":{
              "$eq":90
            }
          }]
        }]};
      // console.log("----test 9----");
      // console.log("alradyin:"+JSON.stringify(alradyin));
      // console.log("filters:"+JSON.stringify(filters));
      // console.log("whiteFields:"+JSON.stringify(whiteFields));
      // console.log(JSON.stringify(FilterService.buildMongoQuery(alradyin, filters, whiteFields)));
      // console.log("----test 9----");
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });
  
    it('try functional test 10', function (done) {
      //"filter[$or][$and][0][$or][data.field1]=third&filter[$or][$and][0][$or][data.field2]=test3&filter[$or][$and][1][$or][data.field2]=test2&filter[$or][$and][2][data.field3][$gte]=23&filter[$or][$and][2][data.field3][$lte]=69"
      var filters = {"$or":{"$and":[{"$or":{"data.field1":"third","data.field2":"test3"}},{"$or":{"data.field2":"test2"}},{"data.field3":{"$gte":"43","$lte":"80"}}]}};
      var expected = {"$and":[{
        "route":"57f1fa52f0a9620f445bba67"},{
          "$or":[{
            "$and":[{
              "$or":[{
                "data.field1":{
                  "$eq":"third"
                }
              },{
                "data.field2":{
                  "$eq":"test3"
                }
              }]
            },{
              "$or":[{
                "data.field2":{
                  "$eq":"test2"
                }
              }]
            },{
              "data.field3":{
                "$gte":43,"$lte":80
              }
            }]
          }]
        }]
      };
      // console.log("----test 9----");
      // console.log("alradyin:"+JSON.stringify(alradyin));
      // console.log("filters:"+JSON.stringify(filters));
      // console.log("whiteFields:"+JSON.stringify(whiteFields));
      // console.log(JSON.stringify(FilterService.buildMongoQuery(alradyin, filters, whiteFields)));
      // console.log("----test 9----");
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });
  
    it('try functional test 11', function (done) {
      //"filter[$or][$and][0][$or][data.field1]=third&filter[$or][$and][0][$or][data.field2]=test3&filter[$or][$and][1][$or][data.field2]=test2&filter[$or][$and][2][data.field3][$gte]=56&filter[$or][$and][2][data.field3][$lte]=71"
      var filters = {"$or":{"$and":[{"$or":{"data.field1":"third","data.field2":"test3"}},{"$or":{"data.field2":"test2"}},{"data.field3":{"$gte":"56","$lte":"71"}}]}};
      var expected = {"$and":[{"route":"57f1fa52f0a9620f445bba67"},{"$or":[{"$and":[{"$or":[{"data.field1":{"$eq":"third"}},{"data.field2":{"$eq":"test3"}}]},{"$or":[{"data.field2":{"$eq":"test2"}}]},{"data.field3":{"$gte":56,"$lte":71}}]}]}]};
      // console.log("----test 9----");
      // console.log("alradyin:"+JSON.stringify(alradyin));
      // console.log("filters:"+JSON.stringify(filters));
      // console.log("whiteFields:"+JSON.stringify(whiteFields));
      // console.log(JSON.stringify(FilterService.buildMongoQuery(alradyin, filters, whiteFields)));
      // console.log("----test 9----");
      FilterService.buildMongoQuery(alradyin, filters, undefined, whiteFields).should.eql(expected);
      done();
    });
    
    
    
  });

});
