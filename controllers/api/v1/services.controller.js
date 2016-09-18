'use strict';

const serviceModel = require('../../../models/v1/Service.model.js'),
  routeModel = require('../../../models/v1/Route.model.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);
  const RouteModel = new routeModel(options);

  this.getServices = function(req, res, next) {
    var services = [];
    var included = [];
    ServiceModel
      .io
      .find({
        public: true
      })
      .sort({name: 1})
      .cursor()
      .on('data', function(service) {
        var self = this;
        self.pause();
        RouteModel.io.find({
          service: service._id,
          public: true
        }, function(err, routes) {
          if (err)
            self.destroy(err);
          var serviceRoutes = [];
          if (routes) {
            routes.forEach(function(route) {
              serviceRoutes.push({
                id: route.routeId,
                type: 'collections'
              });
              included.push({
                id: route.routeId,
                type: 'collections',
                attributes: route.get('attributes'),
                links: {
                  self: res._apiuri + '/services/' + service.clientId + '/relationships/collections/' + route.routeId
                },
                meta: {
                  creation: route.createdAt,
                  modification: route.updatedAt
                }
              });
            });
          }
          var obj = service.getResourceObject(res._apiuri);
          if (serviceRoutes.length > 0) {
            obj.relationships = {
              collections: {
                links: {
                  self: res._apiuri + '/services/' + service.clientId + '/relationships/collections',
                  related: res._apiuri + '/services/' + service.clientId + '/collections'
                },
                data: serviceRoutes
              }
            };
          }
          services.push(obj);
          self.resume();
        });
      })
      .on('error', function(err) {
        next({code: 500, messages: err});
      })
      .on('end', function() {
        next({code: 200, data: services, included: included});
      });
  };

  this.get = function(req, res, next) {
    return next({code: 200, data: req.data.service.getResourceObject(res._apiuri)});
  };

  this.getServiceData = function(req, res, next) {
    ServiceModel.io.findOne({
      $or: [
        {public: true},
        {clientId: res._service.clientId}
      ],
      $or: [
        {nameNormalized: req.params.serviceId},
        {clientId: req.params.serviceId}
      ]
    }, function(err, service) {
      if (err)
        return next({code: 500, messages: err});
      if (!service)
        return next({code: 404, messages: 'Service non trouvé'});
      req.data = req.data || {};
      req.data.service = service;
      return next();
    });
  };
};
