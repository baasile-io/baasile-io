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
      layout: 'layouts/home',
      page: 'pages/index',
      data: {
        user: req.session.user
      }
    });
  });

  /* login / logout / subscribe */
  router
    .get('/login', csrfProtection, UsersController.sessionNew)
    .post('/login', csrfProtection, UsersController.sessionCreate)
    .get('/logout', UsersController.sessionDestroy)
    .get('/subscribe', csrfProtection, UsersController.new)
    .post('/subscribe', csrfProtection, UsersController.create);

  /* dashboard / user area */
  router
    .all('/dashboard*', restrictedArea)
    .get('/dashboard', DashboardController.dashboard)
    .get('/dashboard/account', UsersController.account)
    .get('/dashboard/services/new', csrfProtection, ServicesController.new)
    .get('/dashboard/services', ServicesController.index)
    .post('/dashboard/services', csrfProtection, ServicesController.create)
    .all('/dashboard/services/:serviceName*', ServicesController.getServiceData)
    .get('/dashboard/services/:serviceName', ServicesController.view)
    .get('/dashboard/services/:serviceName/edit', csrfProtection, ServicesController.edit)
    .post('/dashboard/services/:serviceName', csrfProtection, ServicesController.update);

  return router;
};
