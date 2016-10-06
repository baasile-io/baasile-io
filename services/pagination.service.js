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
    if (res._paginate.limit > CONFIG.api.pagination.max.limit)
      return next({code: 400, messages: ['invalid_pagination', '"limit" has reached the maximum ' + CONFIG.api.pagination.max.limit]});
    if (typeof res._paginate.offset !== 'number' || isNaN(res._paginate.offset) || res._paginate.offset < 0)
      return next({code: 400, messages: ['invalid_pagination', '"offset" must be a non-negative number']});
    if (typeof res._paginate.limit !== 'number' || isNaN(res._paginate.limit) || res._paginate.limit < 1)
      return next({code: 400, messages: ['invalid_pagination', '"limit" must strictly be a positive number']});
    next();
  };

  this.setResponse = function(responseParams, req, res, next) {
    if (typeof responseParams.results !== 'undefined') {
      var link = res._originalUrlObject;
      link.query['page[limit]'] = res._paginate.limit;

      res._meta.total = responseParams.results.total;
      res._meta.total_pages = res._paginate.limit != 0 ? Math.ceil(responseParams.results.total / res._paginate.limit) : 1;
      link.query['page[offset]'] = 0;
      res._links.first = link.toString();
      if (res._paginate.offset > 0 && res._paginate.offset < responseParams.results.total) {
        const offsetPrev = res._paginate.offset - res._paginate.limit;
        link.query['page[offset]'] = (offsetPrev > 0 ? offsetPrev : 0);
        res._links.prev = link.toString();
      }
      if (res._paginate.offset + res._paginate.limit < responseParams.results.total) {
        link.query['page[offset]'] = (res._paginate.offset + res._paginate.limit);
        res._links.next = link.toString();
      }
      if (res._paginate.limit < responseParams.results.total) {
        var offsetLast = res._paginate.limit * (Math.ceil(responseParams.results.total / res._paginate.limit) - 1) + (res._paginate.offset % res._paginate.limit);
        if (offsetLast >= responseParams.results.total)
          offsetLast -= res._paginate.limit;
        link.query['page[offset]'] = offsetLast;
        res._links.last = link.toString();
      }
      link.query['page[offset]'] = res._paginate.offset;
      res._links.self = link.toString();
      res._meta.offset = res._paginate.offset;
      res._meta.limit = res._paginate.limit;
    }
    next(responseParams);
  };

  this.getDashboardPagination = function(res, results) {
    var pagination = {
      total: results.total,
      total_pages: res._paginate.limit != 0 ? Math.ceil(results.total / res._paginate.limit) : 1,
      current_page: Math.ceil(res._paginate.offset / res._paginate.limit),
      links: []
    };

    if (results.total > res._paginate.limit) {
      var link = res._originalUrlObject;
      link.query['page[limit]'] = res._paginate.limit;

      var pageNumber = 1;
      var numberOfBeforePages = 4;
      var numberOfAfterPages = 6;
      if (pagination.current_page - 1 < numberOfBeforePages) {
        numberOfAfterPages += numberOfBeforePages - pagination.current_page + 1;
      } else if(pagination.total_pages - pagination.current_page - 1 < numberOfAfterPages) {
        numberOfBeforePages += numberOfAfterPages - (pagination.total_pages - pagination.current_page);
      }

      while (pageNumber <= pagination.total_pages) {
        if (pagination.total_pages < 12 || pageNumber == 1 || pageNumber == pagination.total_pages || (pageNumber > pagination.current_page - numberOfBeforePages && pageNumber < pagination.current_page + numberOfAfterPages)) {
          link.query['page[offset]'] = (pageNumber - 1) * res._paginate.limit;
          let obj = {
            url: link.toString(),
            name: (pageNumber < 10) ? '0' + pageNumber.toString() : pageNumber.toString(),
            active: (res._paginate.offset >= link.query['page[offset]'] && res._paginate.offset < link.query['page[offset]'] + res._paginate.limit)
          };
          pagination.links.push(obj);
          if (pageNumber == pagination.current_page) {
            obj.active = false;
            pagination.prev = obj;
          }
          if (pageNumber == pagination.current_page + 2) {
            obj.active = false;
            pagination.next = obj;
          }
        }
        pageNumber++;
      }

      /*if (res._paginate.limit < results.total) {
        var offsetLast = res._paginate.limit * (Math.ceil(results.total / res._paginate.limit) - 1) + (res._paginate.offset % res._paginate.limit);
        if (offsetLast >= results.total)
          offsetLast -= res._paginate.limit;
        link.query['page[offset]'] = offsetLast;
        pagination.links.push({
          url: link.toString(),
          name: 'Fin',
          active: (res._paginate.offset >= offsetLast && res._paginate.offset < offsetLast + res._paginate.limit)
        });
      }*/
    }

    /*
    if (res._paginate.offset > 0 && res._paginate.offset < results.total) {
      const offsetPrev = res._paginate.offset - res._paginate.limit;
      var linkPrev = res._originalUrlObject;
      linkPrev.query['page[offset]'] = (offsetPrev > 0 ? offsetPrev : 0);
      linkPrev.query['page[limit]'] = res._paginate.limit;
      res._links.prev = linkPrev.toString();
    }
    if (res._paginate.offset + res._paginate.limit < results.total) {
      var linkNext = res._originalUrlObject;
      linkNext.query['page[offset]'] = (res._paginate.offset + res._paginate.limit);
      linkNext.query['page[limit]'] = res._paginate.limit;
      res._links.next = linkNext.toString();
    }
    if (res._paginate.limit < results.total) {
      var offsetLast = res._paginate.limit * (Math.ceil(results.total / res._paginate.limit) - 1) + (res._paginate.offset % res._paginate.limit);
      if (offsetLast >= results.total)
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
    */
    return pagination;
  };
};
