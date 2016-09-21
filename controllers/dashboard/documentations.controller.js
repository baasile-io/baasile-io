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
}
