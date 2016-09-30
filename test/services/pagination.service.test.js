'use strict';

const testHelper = require('../test.helper.js'),
  TestHelper = new testHelper(),
  paginationService = require('../../services/pagination.service.js'),
  PaginationService = new paginationService(TestHelper.getOptions()),
  domurl = require('domurl'),
  request = TestHelper.request;

var req, res, params;
const originalUrl = 'http://localhost/api/v1/services/';
const defaultLimit = 25;

function checkPaginationLinks(links, expectedQueries) {
  Object.keys(expectedQueries).forEach(function(key) {
    if (links[key]) {
      let link = new domurl(links[key]);
      link.query.should.have.property('page[offset]').eq(expectedQueries[key].offset.toString());
      link.query.should.have.property('page[limit]').eq(expectedQueries[key].limit.toString());
    } else {
      links.should.not.have.property(key);
    }
  });
}

describe('Pagination service', function () {

  before(TestHelper.seedDb);

  beforeEach(function() {
    req = {};
    res = {
      _request: {
        params: {}
      }
    };
  });

  describe('init', function() {

    it('set _paginate property', function (done) {
      PaginationService.init(req, res, function (err) {
        if (err)
          throw new Error('it must not fail');
        res._paginate.should.be.instanceof(Object);
        done();
      });
    });

    it('set default values', function (done) {
      PaginationService.init(req, res, function (err) {
        if (err)
          throw new Error('it must not fail');
        res._paginate.should.eql({limit: defaultLimit, offset: 0});
        done();
      });
    });

    it('get offset value', function (done) {
      res._request.params.page = {offset: 2};
      PaginationService.init(req, res, function (err) {
        if (err)
          throw new Error('it must not fail');
        res._paginate.should.eql({limit: defaultLimit, offset: 2});
        done();
      });
    });

    it('get page number value', function (done) {
      res._request.params.page = {number: 3};
      PaginationService.init(req, res, function (err) {
        if (err)
          throw new Error('it must not fail');
        res._paginate.should.eql({limit: defaultLimit, offset: defaultLimit * 2});
        done();
      });
    });

    it('get limit value', function (done) {
      res._request.params.page = {limit: 10};
      PaginationService.init(req, res, function (err) {
        if (err)
          throw new Error('it must not fail');
        res._paginate.should.eql({limit: 10, offset: 0});
        done();
      });
    });

    it('get page size value', function (done) {
      res._request.params.page = {size: 10};
      PaginationService.init(req, res, function (err) {
        if (err)
          throw new Error('it must not fail');
        res._paginate.should.eql({limit: 10, offset: 0});
        done();
      });
    });

    it('limit is primary over page size', function (done) {
      res._request.params.page = {size: 10, limit: 11};
      PaginationService.init(req, res, function (err) {
        if (err)
          throw new Error('it must not fail');
        res._paginate.should.eql({limit: 11, offset: 0});
        done();
      });
    });

    it('offset is primary over page number', function (done) {
      res._request.params.page = {offset: 10, number: 2};
      PaginationService.init(req, res, function (err) {
        if (err)
          throw new Error('it must not fail');
        res._paginate.should.eql({limit: defaultLimit, offset: 10});
        done();
      });
    });

    describe('errors', function() {

      it('offset must be number positive or zero', function (done) {
        res._request.params.page = {offset: -11};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('offset must be number positive or zero', function (done) {
        res._request.params.page = {offset: 'abc'};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('limit must be number striclty positive', function (done) {
        res._request.params.page = {limit: -11};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('limit must be number striclty positive', function (done) {
        res._request.params.page = {limit: 0};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('limit must be number striclty positive', function (done) {
        res._request.params.page = {limit: 'abc'};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('page number must be number strictly positive', function (done) {
        res._request.params.page = {number: 0};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('page number must be number strictly positive', function (done) {
        res._request.params.page = {number: -11};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('page number must be number strictly positive', function (done) {
        res._request.params.page = {number: 'abc'};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('page size must be number striclty positive', function (done) {
        res._request.params.page = {size: -11};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('page size must be number striclty positive', function (done) {
        res._request.params.page = {size: 0};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

      it('page size must be number striclty positive', function (done) {
        res._request.params.page = {size: 'abc'};
        PaginationService.init(req, res, function (err) {
          if (!err)
            throw new Error('it must have failed');
          err.messages.should.include('invalid_pagination');
          done();
        });
      });

    });

  });

  describe('setResponse', function() {

    beforeEach(function() {
      params = {};
      res._request.params = {};
      res._meta = {};
      res._links = {};
      res._originalUrlObject = new domurl(originalUrl, true);
    });

    it('does nothing when nothing to be done', function(done) {
      PaginationService.setResponse(params, req, res, function (outParams) {
        params.should.eq(outParams);
        req.should.eq(req);
        res.should.eq(res);
        done();
      });
    });

    describe('paginated result', function() {

      describe('empty collection', function() {

        beforeEach(function () {
          params.results = {
            total: 0
          };
        });

        it('set default meta', function (done) {
          PaginationService.init(req, res, function (err) {
            if (err)
              throw new Error('init has failed');
            PaginationService.setResponse(params, req, res, function (outParams) {
              res._meta.should.eql({
                limit: defaultLimit,
                offset: 0,
                total: 0,
                total_pages: 0
              });
              done();
            });
          });
        });

        it('set default links', function (done) {
          PaginationService.init(req, res, function (err) {
            if (err)
              throw new Error('init has failed');
            PaginationService.setResponse(params, req, res, function (outParams) {
              res._links.should.eql({
                self: originalUrl + '?page%5Boffset%5D=' + 0 + '&page%5Blimit%5D=' + defaultLimit,
                first: originalUrl + '?page%5Boffset%5D=' + 0 + '&page%5Blimit%5D=' + defaultLimit
              });
              done();
            });
          });
        });

      });

      describe('collection with docs', function() {

        beforeEach(function () {
          params.results = {
            total: 60
          };
        });

        it('set default meta', function (done) {
          PaginationService.init(req, res, function (err) {
            if (err)
              throw new Error('init has failed');
            PaginationService.setResponse(params, req, res, function (outParams) {
              res._meta.should.eql({
                limit: defaultLimit,
                offset: 0,
                total: 60,
                total_pages: 3
              });
              done();
            });
          });
        });

        it('set default links', function (done) {
          PaginationService.init(req, res, function (err) {
            if (err)
              throw new Error('init has failed');
            PaginationService.setResponse(params, req, res, function (outParams) {
              res._links.should.eql({
                self: originalUrl + '?page%5Boffset%5D=' + 0 + '&page%5Blimit%5D=' + defaultLimit,
                first: originalUrl + '?page%5Boffset%5D=' + 0 + '&page%5Blimit%5D=' + defaultLimit,
                next: originalUrl + '?page%5Boffset%5D=' + defaultLimit + '&page%5Blimit%5D=' + defaultLimit,
                last: originalUrl + '?page%5Boffset%5D=' + (defaultLimit * 2) + '&page%5Blimit%5D=' + defaultLimit
              });
              done();
            });
          });
        });

        it('with positive offset', function (done) {
          res._request.params.page = {offset: 2};
          PaginationService.init(req, res, function (err) {
            if (err)
              throw new Error('init has failed');
            PaginationService.setResponse(params, req, res, function (outParams) {
              res._meta.should.eql({
                limit: defaultLimit,
                offset: 2,
                total: 60,
                total_pages: 3
              });
              res._links.should.eql({
                self: originalUrl + '?page%5Boffset%5D=' + 2 + '&page%5Blimit%5D=' + defaultLimit,
                first: originalUrl + '?page%5Boffset%5D=' + 0 + '&page%5Blimit%5D=' + defaultLimit,
                next: originalUrl + '?page%5Boffset%5D=' + (defaultLimit + 2) + '&page%5Blimit%5D=' + defaultLimit,
                prev: originalUrl + '?page%5Boffset%5D=' + 0 + '&page%5Blimit%5D=' + defaultLimit,
                last: originalUrl + '?page%5Boffset%5D=' + (defaultLimit * 2 + 2) + '&page%5Blimit%5D=' + defaultLimit
              });
              done();
            });
          });
        });

        it('stop setting next link', function (done) {
          res._request.params.page = {offset: 50};
          PaginationService.init(req, res, function (err) {
            if (err)
              throw new Error('init has failed');
            PaginationService.setResponse(params, req, res, function (outParams) {
              res._meta.should.eql({
                limit: defaultLimit,
                offset: 50,
                total: 60,
                total_pages: 3
              });
              res._links.should.eql({
                self: originalUrl + '?page%5Boffset%5D=' + 50 + '&page%5Blimit%5D=' + defaultLimit,
                first: originalUrl + '?page%5Boffset%5D=' + 0 + '&page%5Blimit%5D=' + defaultLimit,
                prev: originalUrl + '?page%5Boffset%5D=' + 25 + '&page%5Blimit%5D=' + defaultLimit,
                last: originalUrl + '?page%5Boffset%5D=' + (defaultLimit * 2) + '&page%5Blimit%5D=' + defaultLimit
              });
              done();
            });
          });
        });

        it('with different limit', function (done) {
          res._request.params.page = {limit: 2, offset: 51};
          PaginationService.init(req, res, function (err) {
            if (err)
              throw new Error('init has failed');
            PaginationService.setResponse(params, req, res, function (outParams) {
              res._meta.should.eql({
                limit: 2,
                offset: 51,
                total: 60,
                total_pages: 30
              });
              res._links.should.eql({
                self: originalUrl + '?page%5Boffset%5D=' + 51 + '&page%5Blimit%5D=' + 2,
                first: originalUrl + '?page%5Boffset%5D=' + 0 + '&page%5Blimit%5D=' + 2,
                next: originalUrl + '?page%5Boffset%5D=' + 53 + '&page%5Blimit%5D=' + 2,
                prev: originalUrl + '?page%5Boffset%5D=' + 49 + '&page%5Blimit%5D=' + 2,
                last: originalUrl + '?page%5Boffset%5D=' + 59 + '&page%5Blimit%5D=' + 2
              });
              done();
            });
          });
        });

      });

    });

  });

  describe('Integration', function() {

    before(TestHelper.startServer);
    before(TestHelper.seedDb);
    before(TestHelper.authorize);
    after(TestHelper.stopServer);

    it('default', function(done) {
      request()
        .get('/api/v1/services')
        .query({access_token: TestHelper.getAccessToken()})
        .end(function (err, res) {
          TestHelper.checkResponse(res);
          res.body.data.should.have.lengthOf(5);

          res.body.meta.should.have.property('limit').eql(25);
          res.body.meta.should.have.property('offset').eql(0);
          res.body.meta.should.have.property('total').eql(5);
          res.body.meta.should.have.property('total_pages').eql(1);
          res.body.meta.should.have.property('count').eql(5);

          checkPaginationLinks(res.body.links, {
            self: {offset: 0, limit: 25},
            first: {offset: 0, limit: 25},
            next: null,
            prev: null,
            last: null
          });

          done();
        });
    });

    it('change limit', function(done) {
      request()
        .get('/api/v1/services')
        .query({access_token: TestHelper.getAccessToken(), page: {limit: 2}})
        .end(function (err, res) {
          TestHelper.checkResponse(res, {status: 206});
          res.body.data.should.have.lengthOf(2);

          res.body.meta.should.have.property('limit').eql(2);
          res.body.meta.should.have.property('offset').eql(0);
          res.body.meta.should.have.property('total').eql(5);
          res.body.meta.should.have.property('total_pages').eql(3);
          res.body.meta.should.have.property('count').eql(2);

          checkPaginationLinks(res.body.links, {
            self: {offset: 0, limit: 2},
            first: {offset: 0, limit: 2},
            next: {offset: 2, limit: 2},
            prev: null,
            last: {offset: 4, limit: 2}
          });

          done();
        });
    });

    it('change limit and offset (prev and next appears)', function(done) {
      request()
        .get('/api/v1/services')
        .query({access_token: TestHelper.getAccessToken(), page: {offset: 2, limit: 2}})
        .end(function (err, res) {
          TestHelper.checkResponse(res, {status: 206});
          res.body.data.should.have.lengthOf(2);

          res.body.meta.should.have.property('limit').eql(2);
          res.body.meta.should.have.property('offset').eql(2);
          res.body.meta.should.have.property('total').eql(5);
          res.body.meta.should.have.property('total_pages').eql(3);
          res.body.meta.should.have.property('count').eql(2);

          checkPaginationLinks(res.body.links, {
            self: {offset: 2, limit: 2},
            first: {offset: 0, limit: 2},
            next: {offset: 4, limit: 2},
            prev: {offset: 0, limit: 2},
            last: {offset: 4, limit: 2}
          });

          done();
        });
    });

    it('change limit and offset (only prev appears)', function(done) {
      request()
        .get('/api/v1/services')
        .query({access_token: TestHelper.getAccessToken(), page: {offset: 4, limit: 2}})
        .end(function (err, res) {
          TestHelper.checkResponse(res, {status: 206});
          res.body.data.should.have.lengthOf(1);

          res.body.meta.should.have.property('limit').eql(2);
          res.body.meta.should.have.property('offset').eql(4);
          res.body.meta.should.have.property('total').eql(5);
          res.body.meta.should.have.property('total_pages').eql(3);
          res.body.meta.should.have.property('count').eql(1);

          checkPaginationLinks(res.body.links, {
            self: {offset: 4, limit: 2},
            first: {offset: 0, limit: 2},
            next: null,
            prev: {offset: 2, limit: 2},
            last: {offset: 4, limit: 2}
          });

          done();
        });
    });

    it('offset too big', function(done) {
      request()
        .get('/api/v1/services')
        .query({access_token: TestHelper.getAccessToken(), page: {offset: 40, limit: 2}})
        .end(function (err, res) {
          TestHelper.checkResponse(res, {status: 206});
          res.body.data.should.have.lengthOf(0);

          res.body.meta.should.have.property('limit').eql(2);
          res.body.meta.should.have.property('offset').eql(40);
          res.body.meta.should.have.property('total').eql(5);
          res.body.meta.should.have.property('total_pages').eql(3);
          res.body.meta.should.have.property('count').eql(0);

          checkPaginationLinks(res.body.links, {
            self: {offset: 40, limit: 2},
            first: {offset: 0, limit: 2},
            next: null,
            prev: null,
            last: {offset: 4, limit: 2}
          });

          done();
        });
    });

    describe('errors', function() {

      it('negative offset', function(done) {
        request()
          .get('/api/v1/services')
          .query({access_token: TestHelper.getAccessToken(), page: {offset: -10}})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isSuccess: false, status: 400});
            res.body.errors.should.include('invalid_pagination');
            done();
          });
      });

      it('string offset', function(done) {
        request()
          .get('/api/v1/services')
          .query({access_token: TestHelper.getAccessToken(), page: {offset: 'abc'}})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isSuccess: false, status: 400});
            res.body.errors.should.include('invalid_pagination');
            done();
          });
      });

      it('negative limit', function(done) {
        request()
          .get('/api/v1/services')
          .query({access_token: TestHelper.getAccessToken(), page: {limit: -10}})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isSuccess: false, status: 400});
            res.body.errors.should.include('invalid_pagination');
            done();
          });
      });

      it('string limit', function(done) {
        request()
          .get('/api/v1/services')
          .query({access_token: TestHelper.getAccessToken(), page: {limit: 'abc'}})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isSuccess: false, status: 400});
            res.body.errors.should.include('invalid_pagination');
            done();
          });
      });

      it('zero limit', function(done) {
        request()
          .get('/api/v1/services')
          .query({access_token: TestHelper.getAccessToken(), page: {limit: 0}})
          .end(function (err, res) {
            TestHelper.checkResponse(res, {isSuccess: false, status: 400});
            res.body.errors.should.include('invalid_pagination');
            done();
          });
      });

    });

  });

});