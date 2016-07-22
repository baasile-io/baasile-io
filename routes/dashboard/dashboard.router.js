'use strict';

const express = require('express'),
  csrf = require('csurf'),
  usersController = require('../../controllers/dashboard/users.controller.js'),
  dashboardController = require('../../controllers/dashboard/dashboard.controller.js'),
  servicesController = require('../../controllers/dashboard/services.controller.js'),
  tokensController = require('../../controllers/dashboard/tokens.controller.js');

const router = express.Router();

module.exports = function (options) {
  options = options || {}
  const logger = options.logger;
  const csrfProtection = csrf({ cookie: true });
  const UsersController = new usersController(options);
  const DashboardController = new dashboardController(options);
  const ServicesController = new servicesController(options);
  const TokensController = new tokensController(options);

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
    .get('/dashboard/services/:serviceName', ServicesController.getServiceData, ServicesController.view)
    .get('/dashboard/services/:serviceName/edit', csrfProtection, ServicesController.getServiceData, ServicesController.edit)
    .post('/dashboard/services/:serviceName', csrfProtection, ServicesController.getServiceData, ServicesController.update)
    .get('/dashboard/services/:serviceName/users', csrfProtection, ServicesController.getServiceData, ServicesController.users)
    .post('/dashboard/services/:serviceName/users', csrfProtection, ServicesController.getServiceData, ServicesController.inviteUser)
    .post('/dashboard/services/:serviceName/users/:userEmail/destroy', csrfProtection, ServicesController.getServiceData, ServicesController.revokeUser)
    .get('/dashboard/services/:serviceName/tokens', csrfProtection, ServicesController.getServiceData, TokensController.index)
    .post('/dashboard/services/:serviceName/tokens/generate', csrfProtection, ServicesController.getServiceData, TokensController.generateTokenFromDashboard)
    .post('/dashboard/services/:serviceName/tokens/:accessToken/destroy', csrfProtection, ServicesController.getServiceData, TokensController.getTokenData, TokensController.destroy)
    .post('/dashboard/services/:serviceName/tokens/:accessToken/revoke', csrfProtection, ServicesController.getServiceData, TokensController.getTokenData, TokensController.revoke);

  return router;
};
