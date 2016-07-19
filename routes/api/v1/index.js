'use strict';

const express = require('express'),
  authController = require('./../../../controllers/api/v1/auth.controller.js'),
  fcController = require('./../../../controllers/api/v1/fc.controller.js');

const router = express.Router();

module.exports = function (options) {
  const fc = new fcController(options);
  const AuthController = new authController(options);

  router.all('/*', AuthController.authorize);
  router.get('/fc/formation', fc.getFormation);

  return router;
};
