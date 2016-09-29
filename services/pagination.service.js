'use strict';

const CONFIG = require('../config/app.js');

module.exports = PaginationService;

function PaginationService(options) {
  options = options || {};
  const logger = options.logger;

  this.init = function(req, res, next) {
    res._paginate = {};
    const isPaginated = typeof res._request.params.page !== 'undefined';
    if (isPaginated && typeof res._request.params.page.limit !== 'undefined') {
      res._paginate.limit = Number(res._request.params.page.limit);
    } else if (isPaginated && typeof res._request.params.page.size !== 'undefined') {
      res._paginate.limit = Number(res._request.params.page.size);
    } else {
      res._paginate.limit = CONFIG.api.pagination.limit;
    }
    if (isPaginated && typeof res._request.params.page.offset !== 'undefined') {
      res._paginate.offset = Number(res._request.params.page.offset);
    } else if (isPaginated && typeof res._request.params.page.number !== 'undefined') {
      res._paginate.offset = (Number(res._request.params.page.number) - 1) * res._paginate.limit;
    } else {
      res._paginate.offset = CONFIG.api.pagination.offset;
    }
    if (typeof res._paginate.offset !== 'number' || isNaN(res._paginate.offset) || res._paginate.offset < 0)
      return next({code: 400, messages: ['invalid_pagination', '"offset" must be a non-negative number']});
    if (typeof res._paginate.limit !== 'number' || isNaN(res._paginate.limit) || res._paginate.limit < 1)
      return next({code: 400, messages: ['invalid_pagination', '"limit" must strictly be a positive number']});
    next();
  };

  this.setResponse = function(responseParams, req, res, next) {
    if (typeof responseParams.results !== 'undefined') {
      res._meta.total = responseParams.results.total;
      res._meta.total_pages = res._paginate.limit != 0 ? Math.ceil(responseParams.results.total / res._paginate.limit) : 1;
      var linkFirst = res._originalUrlObject;
      linkFirst.query['page[offset]'] = 0;
      linkFirst.query['page[limit]'] = res._paginate.limit;
      res._links.first = linkFirst.toString();
      if (res._paginate.offset > 0 && res._paginate.offset < responseParams.results.total) {
        const offsetPrev = res._paginate.offset - res._paginate.limit;
        var linkPrev = res._originalUrlObject;
        linkPrev.query['page[offset]'] = (offsetPrev > 0 ? offsetPrev : 0);
        linkPrev.query['page[limit]'] = res._paginate.limit;
        res._links.prev = linkPrev.toString();
      }
      if (res._paginate.offset + res._paginate.limit < responseParams.results.total) {
        var linkNext = res._originalUrlObject;
        linkNext.query['page[offset]'] = (res._paginate.offset + res._paginate.limit);
        linkNext.query['page[limit]'] = res._paginate.limit;
        res._links.next = linkNext.toString();
      }
      if (res._paginate.limit < responseParams.results.total) {
        var offsetLast = res._paginate.limit * (Math.ceil(responseParams.results.total / res._paginate.limit) - 1) + (res._paginate.offset % res._paginate.limit);
        if (offsetLast >= responseParams.results.total)
          offsetLast -= res._paginate.limit;
        var linkLast = res._originalUrlObject;
        linkLast.query['page[offset]'] = offsetLast;
        linkLast.query['page[limit]'] = res._paginate.limit;
        res._links.last = linkLast.toString();
      }
      var linkSelf = res._originalUrlObject;
      linkSelf.query['page[offset]'] = res._paginate.offset;
      linkSelf.query['page[limit]'] = res._paginate.limit;
      res._links.self = linkSelf.toString();
      res._meta.offset = res._paginate.offset;
      res._meta.limit = res._paginate.limit;
    }
    next(responseParams);
  };
};
