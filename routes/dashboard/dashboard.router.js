'use strict';

const express = require('express'),
  csrf = require('csurf'),
  accountController = require('../../controllers/dashboard/account.controller.js'),
  dashboardController = require('../../controllers/dashboard/dashboard.controller.js'),
  servicesController = require('../../controllers/dashboard/services.controller.js');

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
    res.render('pages/index', {
      layout: 'layouts/home'
    });
  });

  /* login / logout / subscribe */
  const AccountController = new accountController(options);

  router
    .get('/login', csrfProtection, function(req, res) {
      if (req.session.user != null) {
        return res.redirect('/dashboard');
      }
      res.render('pages/login', {
        layout: 'layouts/login',
        csrfToken: req.csrfToken(),
        query: {
          user: {}
        },
        flash: {}
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
        layout: 'layouts/home',
        csrfToken: req.csrfToken(),
        query: {
          user: {}
        },
        flash: {}
      });
    })
    .post('/subscribe', csrfProtection, AccountController.subscribe);

  /* dashboard / member area */
  const DashboardController = new dashboardController(options);
  const ServicesController = new servicesController(options);

  router
    .get('/dashboard', memberAreaRestriction, AccountController.getUserData, DashboardController.dashboard)
    .get('/dashboard/services/new', memberAreaRestriction, AccountController.getUserData, csrfProtection, ServicesController.new)
    .post('/dashboard/services', memberAreaRestriction, AccountController.getUserData, csrfProtection, ServicesController.create);

  return router;
};
