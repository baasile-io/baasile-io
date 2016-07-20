'use strict';

const express = require('express'),
  authController = require('./../../../controllers/api/v1/auth.controller.js'),
  fcController = require('./../../../controllers/api/v1/fc.controller.js');

const router = express.Router();

module.exports = function (options) {
  const fc = new fcController(options);
  const AuthController = new authController(options);
 
  router.all('/*', function(req, res, next) {
    res._jsonapi = {
      version: "1.0"
    };
    return next();
  });
  router.post('/oauth/token', AuthController.authenticate);
  router.get('/fc/formation', AuthController.authorize, fc.getFormation);

  return router;
};
