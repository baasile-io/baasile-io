'use strict';

const serviceModel = require('../../models/v1/Service.model.js'),
  routeModel = require('../../models/v1/Route.model.js');

module.exports = DocumentationsController;

function DocumentationsController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);
  const RouteModel = new routeModel(options);

  this.index = function(req, res, next) {
    res.render('pages/doc', {
      layout: 'layouts/home',
      page: 'pages/doc',
      query: {},
      data: req.data,
      flash: res._flash
    });
  };

  this.getDocServiceData = function(req, res, next) {
    ServiceModel.io.findOne({
      clientId: options.documentationServiceId
    }, function(err, service) {
      if (err)
        return next({code: 500});
      if (!service)
        return next({code: 404});
      req.data = req.data || {};
      req.data.service = service;
      return next();
    });
  };
}
