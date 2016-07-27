'use strict';

const express = require('express'),
  authController = require('./../../../controllers/api/v1/auth.controller.js'),
  fcController = require('./../../../controllers/api/v1/fc.controller.js'),
  servicesController = require('./../../../controllers/api/v1/services.controller.js'),
  routesController = require('./../../../controllers/api/v1/routes.controller.js'),
  fieldsController = require('./../../../controllers/api/v1/fields.controller.js'),
  datasController = require('./../../../controllers/api/v1/datas.controller.js');

const router = express.Router();

module.exports = function (options) {
  options = options || {};
  const logger = options.logger;
  const FcController = new fcController(options);
  const AuthController = new authController(options);
  const ServicesController = new servicesController(options);
  const RoutesController = new routesController(options);
  const FieldsController = new fieldsController(options);
  const DatasController = new datasController(options);
 
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
  router.get(['/services/:serviceId/collections', '/services/:serviceId/relationships/collections'], AuthController.authorize, ServicesController.getServiceData, RoutesController.getSharedRoutes);
  router.get(['/services/:serviceId/collections/:routeId', '/services/:serviceId/relationships/collections/:routeId'], AuthController.authorize, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.get);
  router.get(['/services/:serviceId/collections/:routeId/champs', '/services/:serviceId/relationships/collections/:routeId/relationships/champs'], AuthController.authorize, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.getFields);
  router.all(['/services/:serviceId/collections/:routeId/donnees', '/services/:serviceId/relationships/collections/:routeId/relationships/donnees'], AuthController.authorize, ServicesController.getServiceData, RoutesController.getRouteData, DatasController.fcAuthorize, DatasController.processRequest);
  router.get(['/services/:serviceId/collections/:routeId/donnees/:dataId', '/services/:serviceId/relationships/collections/:routeId/relationships/donnees/:dataId'], AuthController.authorize, ServicesController.getServiceData, RoutesController.getRouteData, DatasController.fcAuthorize, DatasController.get);

  return router;
};
