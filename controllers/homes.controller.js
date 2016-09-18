'use strict';

const _ = require('lodash'),
  routeModel = require('../models/v1/Route.model.js'),
  serviceModel = require('../models/v1/Service.model.js'),
  flashHelper = require('../helpers/flash.helper.js');

module.exports = HomesController;

function HomesController(options) {
  options = options || {};
  const logger = options.logger;
  const RouteModel = new routeModel(options);
  const ServiceModel = new serviceModel(options);
  const FlashHelper = new flashHelper(options);

  this.services = function(req, res, next) {
    var services = [];
    ServiceModel
      .io
      .find({public: true})
      .cursor()
      .on('data', function (service) {
        var self = this;
        self.pause();
        RouteModel.io.find({public: true, service: service._id}, function (err, routes) {
          if (err)
            return self.destroy();
          services.push({
            name: service.name,
            description: service.description,
            createdAt: service.createdAt,
            routes: routes
          });
          return self.resume();
        });
      })
      .on('error', function (err) {
        return next({code: 500});
      })
      .on('end', function () {
        return res.render('pages/services', {
          layout: 'layouts/home',
          page: 'pages/services',
          data: req.data,
          services: services,
          flash: res._flash
        });
      });
  };
};