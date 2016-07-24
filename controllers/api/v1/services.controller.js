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
    ServiceModel.io.aggregate([
      /*{
        $lookup: {
          from: 'routes',
          localField: '_id',
          foreignField: 'service',
          as: 'shared_routes'
        }
      },*/
      {
        $match: {public: true}
      },
      {
        $project: {
          _id: 0,
          id: "$clientId",
          type: {
            $concat: ["service"]
          },
          attributes: {
            nom: "$name",
            description: "$description",
            site_internet: "$website"
          },
          /*relationships: {
            donnees_partagees: {
              links: {
                self: {
                  $concat: ["/"]
                },
                related: {
                  $concat: ["/"]
                }
              },
              data: "$shared_routes.routeId"
            }
          }*/
        }
      }
    ], function(err, services) {
      if (err)
        return next({code: 500});
      return next({code: 200, data: services});
    });
  };

  this.getSharedRoutes = function(req, res, next) {
    RouteModel.io.aggregate([
      {
        $lookup: {
          from: 'services',
          localField: 'service',
          foreignField: '_id',
          as: 'fournisseur'
        }
      },
      {
        $unwind: '$fournisseur'
      },
      {
        $match: {
          service: req.data.service._id,
          'fournisseur.public': true,
          public: true
        }
      },
      {
        $project: {
          _id: 0,
          id: "$routeId",
          type: {
            $concat: ["donnee_partagee"]
          },
          attributes: {
            nom: "$name",
            description: "$description",
            identifiee: "$fcRequired"
          }
        }
      }
    ], function(err, routes) {
      logger.info('------------');
      logger.warn(err);
      if (err)
        return next({code: 500});
      logger.info('------------');
      return next({code: 200, data: routes});
    });
  };

  this.getServiceData = function(req, res, next) {
    ServiceModel.io.findOne({
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
