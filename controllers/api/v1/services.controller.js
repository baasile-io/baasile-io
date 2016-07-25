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
    ServiceModel.io.find({
      public: true
    }, {
      name: 1,
      nameNormalized: 1,
      description: 1,
      website: 1,
      clientId: 1
    })
      .sort({name: 1})
      .stream()
      .on('data', function(service) {
        var self = this;
        self.pause();
        RouteModel.io.aggregate([
          {
            $match: {
              service: service._id,
              public: true
            }
          },
          {
            $project: {
              _id: 0,
              id: "$routeId",
              type: {
                $concat: ["donnees"]
              }
            }
          }
        ], function(err, routes) {
          if (err)
            self.destroy(err);
          var obj = {
            id: service.clientId,
            type: 'services',
            attributes: {
              alias: service.nameNormalized,
              nom: service.name,
              description: service.description,
              site_internet: service.website
            }
          };
          if (routes && routes.length > 0) {
            obj.relationships = {
              donnees: {
                links: {
                  self: res._apiuri + '/services/' + service.clientId + '/relationships/donnees',
                  related: res._apiuri + '/services/' + service.clientId + '/donnees'
                },
                data: routes
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
        next({code: 200, data: services});
      });
  };

  this.getServiceData = function(req, res, next) {
    ServiceModel.io.findOne({
      $or: [
        {public: true},
        {clientId: res._clientId}
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
