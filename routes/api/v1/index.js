'use strict';

const express = require('express'),
  authController = require('./../../../controllers/api/v1/auth.controller.js'),
  fcController = require('./../../../controllers/api/v1/fc.controller.js'),
  servicesController = require('./../../../controllers/api/v1/services.controller.js');

const router = express.Router();

module.exports = function (options) {
  options = options || {};
  const logger = options.logger;
  const FcController = new fcController(options);
  const AuthController = new authController(options);
  const ServicesController = new servicesController(options);
 
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
  router.get('/services/:serviceId/donnees_partagees', AuthController.authorize, ServicesController.getServiceData, ServicesController.getSharedRoutes);

  return router;
};
