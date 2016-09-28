'use strict';

const _ = require('lodash'),
  CONFIG = require('../../../config/app.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = options.models.ServiceModel;
  const RouteModel = options.models.RouteModel;

  this.getServices = function(req, res, next) {
    const query = {
      '$or': [
        {public: true},
        {clientId: res._service.clientId}
      ]
    };
    const queryOptions = {
      sort: {name: 1},
      populate: {path: 'routes', model: RouteModel.io, options: {limit: CONFIG.api.pagination.limit}}
    };
    _.merge(queryOptions, res._paginate);
    ServiceModel
      .io
      .paginate(query, queryOptions)
      .then(function(results) {
        return next({code: 200, results: results});
      })
      .catch(function(err) {
        logger.warn(JSON.stringify(err));
        return next({code: 500});
      });
  };

  this.get = function(req, res, next) {
    return next({code: 200, data: req.data.service.getResourceObject(res._apiuri)});
  };

  this.getServiceData = function(req, res, next) {
    ServiceModel.io.findOne({
      $and: [
        {
          $or: [
            {public: true},
            {clientId: res._service.clientId}
          ]
        },
        {
          $or: [
            {nameNormalized: req.params.serviceId},
            {clientId: req.params.serviceId}
          ]
        }
      ]
    }, function(err, service) {
      if (err)
        return next({code: 500, messages: err});
      if (!service)
        return next({code: 404, messages: ['not_found', 'Service non trouvé']});
      req.data = req.data || {};
      req.data.service = service;
      return next();
    });
  };
};
