'use strict';

const express = require('express'),
  csrf = require('csurf'),
  documentationsController = require('../../controllers/dashboard/documentations.controller.js'),
  flashHelper = require('../../helpers/flash.helper.js');

const router = express.Router();

module.exports = function (options) {
  options = options || {}
  const logger = options.logger;
  const csrfProtection = csrf({ cookie: true });
  const DocumentationsController = new documentationsController(options);
  const FlashHelper = new flashHelper(options);

  /* flash messages */
  router.all('/*', function(req, res, next) {
    req.data = req.data || {};
    req.data.user = {
      user: req.session.user
    };
    
    FlashHelper.get(req.session, function(err, flash) {
      if (err)
        next(err);
      res._flash = flash;
      next();
    });
  });

  /* public pages */
  router.get('/*', DocumentationsController.getDocServiceData);
  router.get('/', DocumentationsController.index);

  return router;
};
