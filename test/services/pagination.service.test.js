'use strict';

const testHelper = require('../test.helper.js'),
  TestHelper = new testHelper(),
  paginationService = require('../../services/pagination.service.js'),
  PaginationService = new paginationService(TestHelper.getOptions()),
  domurl = require('domurl');

var req, res, params;
const originalUrl = 'http://localhost/api/v1/services/';
const defaultLimit = 25;

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

});