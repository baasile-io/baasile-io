'use strict';

const _ = require('lodash'),
  filterservice = require('../../../services/filter.service.js'),
  sortservice = require('../../../services/sort.service.js'),
  CONFIG = require('../../../config/app.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = options.models.ServiceModel;
  const RouteModel = options.models.RouteModel;
  const FieldModel = options.models.FieldModel;
  const DataModel = options.models.DataModel;
  const FilterService = new filterservice(options);
  const SortService = new sortservice(options);

  this.getRoutes = function(req, res, next) {
    var query = {
      '$and': [
        {
          '$or': [
            {public: true},
            {clientId: res._service.clientId}
          ]
        }
      ]
    };
    if (req.data.service) {
      query['$and'].push({service: req.data.service._id});
    }
    if (typeof res._request !== 'undefined' && res._request.params !== 'undefined');
      query = FilterService.buildMongoQuery(query, res._request.params.filter, 'Route');
    var queryOptions = {
      //sort: {name: 1},
      populate: []
    };
    queryOptions = SortService.buildMongoQuery(queryOptions, res._request.params.sort, 'Route');
    if (queryOptions["ERRORS"] !== undefined && queryOptions["ERRORS"].length > 0)
      return next({code: 400, messages: queryOptions["ERRORS"]});
    if (Array.isArray(res._request.params.include) === true) {
      if (res._request.params.include.indexOf(CONFIG.api.v1.resources.Service.type) != -1) {
        queryOptions.populate.push({
          path: 'service',
          model: ServiceModel.io,
          options: {limit: CONFIG.api.pagination.limit}
        });
      }
      if (res._request.params.include.indexOf(CONFIG.api.v1.resources.Field.type) != -1) {
        queryOptions.populate.push({
          path: 'fields',
          model: FieldModel.io,
          options: {limit: CONFIG.api.pagination.limit}
        });
      }
    }
    _.merge(queryOptions, res._paginate);
    RouteModel
      .io
      .paginate(query, queryOptions)
      .then(function(results) {
        return next({code: 200, results: results});
      })
      .catch(function(err) {
        logger.warn(err);
        return next({code: 500});
      });
  };

  this.get = function(req, res, next) {
    return next({code: 200, data: req.data.route.getResourceObject(res._apiuri)});
  };

  this.getRouteData = function(req, res, next) {
    RouteModel
      .io
      .findOne({
        '$and': [
          {
            '$or': [
              {public: true},
              {clientId: res._service.clientId}
            ]
          },
          {
            '$or': [
              {nameNormalized: req.params.routeId},
              {routeId: req.params.routeId}
            ]
          }
        ]
      })
      .populate({
        path: 'service',
        model: ServiceModel.io,
        options: {limit: CONFIG.api.pagination.limit}
      })
      .exec(function(err, route) {
        if (err)
          return next({code: 500});
        if (!route)
          return next({code: 404, messages: ['not_found', '"' + req.params.routeId + '" is invalid']});
        req.data = req.data || {};
        req.data.route = route;
        req.data.service = route.service;
        return next();
      });
  };
};
