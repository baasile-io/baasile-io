'use strict';

const express = require('express'),
  csrf = require('csurf'),
  flashHelper = require('../../helpers/flash.helper.js');

const router = express.Router();

module.exports = function (options) {
  options = options || {}
  const logger = options.logger;
  const csrfProtection = csrf({ cookie: true });
  const FlashHelper = new flashHelper(options);

  /* flash messages */
  router.all('/*', function(req, res, next) {
    FlashHelper.get(req.session, function(err, flash) {
      if (err)
        next(err);
      res._flash = flash;
      next();
    });
  });

  /* public pages */
  router.get('/', function(req, res) {
    res.render('pages/doc', {
      layout: 'layouts/home',
      page: 'pages/doc',
      data: {
        user: req.session.user
      }
    });
  });

  return router;
};
