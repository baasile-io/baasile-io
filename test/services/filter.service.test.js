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
        .should.eq(defaultFilter);
      done();
    });

    it('add one filter', function (done) {
      var filter = {'key': 'value'};
      var expected = {
        '$and': [
          {'key': {'$eq': 'value'}}
        ]
      };
      FilterService.buildMongoQuery({}, filter).should.eq(expected);
      done();
    });

    it('add one filter with default json', function (done) {
      var filter = {'key': 'value'};
      var expected = {
        '$and': [
          defaultFilter,
          {'key': {'$eq': 'value'}}
        ]
      };
      FilterService.buildMongoQuery(defaultFilter, filter).should.eq(expected);
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
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
      done();
    });

    it('add two filters with default json', function (done) {
      var filters = {
        'key1': 'value1',
        'key2': 'value2'
      };
      var expected = {
        '$and': [
          defaultFilter,
          {'key1': {'$eq': 'value1'}},
          {'key2': {'$eq': 'value2'}}
        ]
      };
      FilterService.buildMongoQuery(defaultFilter, filters).should.eq(expected);
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
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
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
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
      done();
    });

    it('add one filter with two values', function (done) {
      var filters = {
        'key': ['value1', 'value2']
      };
      var expected = {
        '$and': [
          {
            'key': {
              '$and': [
                {'$eq': 'value1'},
                {'$eq': 'value2'}
              ]
            }
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
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
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
      done();
    });

    it('add one filter with two advanced values', function (done) {
      var filters = {
        'key': {
          '$lt': 'value1',
          '$gt': 'value2'
        }
      };
      var expected = {
        '$and': [
          {
            'key': {
              '$and': [
                {'$lt': 'value1'},
                {'$gt': 'value2'}
              ]
            }
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
      done();
    });

    it('add one filter with OR operator with two advanced values', function (done) {
      var filters = {
        'key': {
          '$or': {
            '$lt': 'value1',
            '$gt': 'value2'
          }
        }
      };
      var expected = {
        '$and': [
          {
            'key': {
              '$or': [
                {'$lt': 'value1'},
                {'$gt': 'value2'}
              ]
            }
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
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
              {
                'key': {
                  '$and': [
                    {'$eq': 'value1'},
                    {'$eq': 'value2'}
                  ]
                }
              }
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
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
              {
                'key': {
                  '$and': [
                    {'$eq': 'value1'},
                    {'$eq': 'value2'}
                  ]
                }
              }
            ]
          }
        ]
      };
      FilterService.buildMongoQuery({}, filters).should.eq(expected);
      done();
    });

  });

});
