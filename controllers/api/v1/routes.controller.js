'use strict';

const _ = require('lodash'),
  serviceModel = require('../../../models/v1/Service.model.js'),
  routeModel = require('../../../models/v1/Route.model.js'),
  fieldModel = require('../../../models/v1/Field.model.js'),
  dataModel = require('../../../models/v1/Data.model.js'),
  CONFIG = require('../../../config/app.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);
  const RouteModel = new routeModel(options);
  const FieldModel = new fieldModel(options);
  const DataModel = new dataModel(options);

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
    var queryOptions = {
      sort: {name: 1},
      populate: []
    };
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
    RouteModel.io.findOne({
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
    }, function(err, route) {
      if (err)
        return next({code: 500});
      if (!route)
        return next({code: 404, messages: ['not_found', '"' + req.params.routeId + '" is invalid']});
      req.data = req.data || {};
      req.data.route = route;
      return next();
    });
  };
};
