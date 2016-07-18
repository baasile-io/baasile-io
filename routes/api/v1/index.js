'use strict';

const express = require('express'),
  fcController = require('./../../../controllers/v1/fc.controller.js');

const router = express.Router();

module.exports = function (options) {
  const fc = new fcController(options);

  router.get('/fc/formation', fc.getFormation);

  return router;
};
