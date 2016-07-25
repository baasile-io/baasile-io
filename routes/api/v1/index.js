'use strict';

const express = require('express'),
  authController = require('./../../../controllers/api/v1/auth.controller.js'),
  fcController = require('./../../../controllers/api/v1/fc.controller.js'),
  servicesController = require('./../../../controllers/api/v1/services.controller.js'),
  routesController = require('./../../../controllers/api/v1/routes.controller.js'),
  fieldsController = require('./../../../controllers/api/v1/fields.controller.js');

const router = express.Router();

module.exports = function (options) {
  options = options || {};
  const logger = options.logger;
  const FcController = new fcController(options);
  const AuthController = new authController(options);
  const ServicesController = new servicesController(options);
  const RoutesController = new routesController(options);
  const FieldsController = new fieldsController(options);
 
  router.all('/*', function(req, res, next) {
    res._jsonapi = {
      version: "1.0"
    };
    res._apiuri = req.protocol + '://' + req.get('host') + '/api/v1';
    return next();
  });
  router.post('/oauth/token', AuthController.authenticate);
  router.get('/fc/formation', AuthController.authorize, FcController.getFormation);
  router.get('/services', AuthController.authorize, ServicesController.getServices);
  router.get(['/services/:serviceId/donnees', '/services/:serviceId/relationships/donnees'], AuthController.authorize, ServicesController.getServiceData, RoutesController.getSharedRoutes);
  router.all(['/services/:serviceId/donnees/:routeId', '/services/:serviceId/relationships/donnees/:routeId'], AuthController.authorize, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.processRequest);
  router.get(['/services/:serviceId/donnees/:routeId/champs', '/services/:serviceId/relationships/donnees/:routeId/relationships/champs'], AuthController.authorize, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.getFields);

  return router;
};
