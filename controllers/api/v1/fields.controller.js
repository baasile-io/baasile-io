'use strict';

const fieldModel = require('../../../models/v1/Field.model.js'),
  routeModel = require('../../../models/v1/Route.model.js'),
  serviceModel = require('../../../models/v1/Service.model.js'),
  CONFIG = require('../../../config/app.js'),
  _ = require('lodash');

module.exports = FieldsController;

function FieldsController(options) {
  options = options || {};
  const logger = options.logger;
  const FieldModel = new fieldModel(options);
  const RouteModel = new routeModel(options);
  const ServiceModel = new serviceModel(options);

  this.getFields = function(req, res, next) {
    var query;
    if (req.data.route) {
      query = {route: req.data.route._id};
    } else {
      query = {clientId: res._service.clientId};
    }
    var queryOptions = {
      sort: {name: 1},
      populate: []
    };
    if (Array.isArray(res._request.params.include) === true) {
      if (res._request.params.include.indexOf(CONFIG.api.v1.resources.Route.type) != -1) {
        queryOptions.populate.push({
          path: 'route',
          model: RouteModel.io,
          options: {limit: CONFIG.api.pagination.limit}
        });
      }
    }
    if (Array.isArray(res._request.params.include) === true) {
      if (res._request.params.include.indexOf(CONFIG.api.v1.resources.Service.type) != -1) {
        queryOptions.populate.push({
          path: 'service',
          model: ServiceModel.io,
          options: {limit: CONFIG.api.pagination.limit}
        });
      }
    }
    _.merge(queryOptions, res._paginate);
    FieldModel
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
    return next({code: 200, data: req.data.field.getResourceObject(res._apiuri)});
  };

  this.getFieldData = function(req, res, next) {
    FieldModel.io.findOne({fieldId: req.params.fieldId}, function(err, field) {
      if (err)
        return next({code: 500});
      if (!field)
        return next({code: 404, messages: ['not_found', '"' + req.params.fieldId + '" is invalid']});
      req.data = req.data || {};
      req.data.field = field;
      return next();
    });
  };
};