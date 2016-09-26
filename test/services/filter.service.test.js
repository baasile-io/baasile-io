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
          {'key': {'$eq': 'value1'}},
          {'key': {'$eq': 'value2'}}
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
              {'key': {'$eq': 'value1'}},
              {'key': {'$eq': 'value2'}}
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
              {'key': {'$eq': 'value1'}},
              {'key': {'$eq': 'value2'}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

  });

  describe('Advanced', function () {

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
              {'key': {'$eq': 'value1'}},
              {'key': {'$eq': 'value2'}}
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

    it('multiple dimensions', function (done) {
      var filters = {
        '$or': {
          '$and': [
            {
              '$or': {
                'keyA': ['valueA1', 'valueA2']
              },
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
                      {'keyA': {'$eq': 'valueA1'}},
                      {'keyA': {'$eq': 'valueA2'}}
                    ]
                  },
                  {
                    '$or': [
                      {'keyB': {'$eq': 'valueB1'}},
                      {'keyB': {'$eq': 'valueB2'}}
                    ]
                  }
                ]
              },
              {'keyC': {'$eq': 'valueC'}},
              {'keyD': {'$eq': 'valueD1'}},
              {'keyD': {'$eq': 'valueD2'}},
              {'keyD': {'$eq': 'valueD3'}}
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eql(expected);
      done();
    });

  });

});
