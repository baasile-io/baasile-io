'use strict';

const express = require('express'),
  csrf = require('csurf'),
  accountController = require('../../controllers/dashboard/account.controller.js');

const router = express.Router();

module.exports = function (options) {
  options = options || {}
  const logger = options.logger;
  const csrfProtection = csrf({ cookie: true });

  function memberAreaRestriction(req, res, next) {
    if (req.session.user == null) {
      logger.info("this area is restricted to members");
      return res.redirect('/login');
    }
    next();
  }

  /* public pages */
  router.get('/', function(req, res) {
    res.render('pages/index');
  });

  /* login / logout / subscribe */
  const AccountController = new accountController(options);

  router
    .get('/login', csrfProtection, function(req, res) {
      if (req.session.user != null) {
        return res.redirect('/dashboard');
      }
      res.render('pages/login', {
        csrfToken: req.csrfToken()
      });
    })
    .post('/login', csrfProtection, AccountController.login);

  router
    .get('/logout', AccountController.logout);

  router
    .get('/subscribe', csrfProtection, function(req, res) {
      if (req.session.user != null) {
        return res.redirect('/dashboard');
      }
      res.render('pages/subscribe', {
        csrfToken: req.csrfToken()
      });
    })
    .post('/subscribe', csrfProtection, AccountController.subscribe);

  /* member area */
  router
    .get('/dashboard*', memberAreaRestriction)
    .get('/dashboard', function(req, res) {
      res.render('pages/dashboard');
    });

  return router;
};
