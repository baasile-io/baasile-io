'use strict';

const express = require('express'),
  csrf = require('csurf'),
  usersController = require('../../controllers/dashboard/users.controller.js'),
  dashboardController = require('../../controllers/dashboard/dashboard.controller.js'),
  servicesController = require('../../controllers/dashboard/services.controller.js');

const router = express.Router();

module.exports = function (options) {
  options = options || {}
  const logger = options.logger;
  const csrfProtection = csrf({ cookie: true });
  const UsersController = new usersController(options);
  const DashboardController = new dashboardController(options);
  const ServicesController = new servicesController(options);

  function restrictedArea(req, res, next) {
    if (req.session.user == null) {
      logger.info("this area is restricted to members");
      return res.redirect('/login');
    }
    UsersController.getUserData(req, res, next);
  }

  /* public pages */
  router.get('/', function(req, res) {
    res.render('pages/index', {
      layout: 'layouts/home'
    });
  });

  /* login / logout / subscribe */
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
    .post('/login', csrfProtection, UsersController.login);

  router
    .get('/logout', UsersController.logout);

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
    .post('/subscribe', csrfProtection, UsersController.subscribe);

  /* dashboard / user area */
  router
    .all('/dashboard*', restrictedArea)
    .get('/dashboard', DashboardController.dashboard)
    .get('/dashboard/services/new', csrfProtection, ServicesController.new)
    .get('/dashboard/services', ServicesController.index)
    .post('/dashboard/services', csrfProtection, ServicesController.create)
    .all('/dashboard/services/:serviceName*', ServicesController.getServiceData)
    .get('/dashboard/services/:serviceName', ServicesController.view)
    .get('/dashboard/services/:serviceName/edit', csrfProtection, ServicesController.edit)
    .post('/dashboard/services/:serviceName', csrfProtection, ServicesController.update);

  return router;
};
