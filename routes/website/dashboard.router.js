'use strict';

const express = require('express'),
  csrf = require('csurf'),
  usersController = require('../../controllers/dashboard/users.controller.js'),
  dashboardController = require('../../controllers/dashboard/dashboard.controller.js'),
  servicesController = require('../../controllers/dashboard/services.controller.js'),
  tokensController = require('../../controllers/dashboard/tokens.controller.js'),
  routesController = require('../../controllers/dashboard/routes.controller.js'),
  fieldsController = require('../../controllers/dashboard/fields.controller.js'),
  pagesController = require('../../controllers/dashboard/pages.controller.js'),
  relationsController = require('../../controllers/dashboard/relations.controller.js'),
  homesController = require('../../controllers/homes.controller.js'),
  emailsController = require('../../controllers/emails.controller.js'),
  documentationsController = require('../../controllers/dashboard/documentations.controller.js'),
  applicationController = require('../../controllers/application.controller.js'),
  flashHelper = require('../../helpers/flash.helper.js'),
  multer = require('multer');


module.exports = function (options) {
  const router = express.Router();

  options = options || {};
  const logger = options.logger;
  const csrfProtection = csrf({ cookie: true });
  const UsersController = new usersController(options);
  const DashboardController = new dashboardController(options);
  const ServicesController = new servicesController(options);
  const TokensController = new tokensController(options);
  const RoutesController = new routesController(options);
  const FieldsController = new fieldsController(options);
  const PagesController = new pagesController(options);
  const RelationsController = new relationsController(options);
  const HomesController = new homesController(options);
  const EmailsController = new emailsController(options);
  const FlashHelper = new flashHelper(options);
  const DocumentationsController = new documentationsController(options);
  const ApplicationController = new applicationController(options);
  const FormUpload = new multer({dest: 'uploads/'});

  function restrictedArea(req, res, next) {
    if (req.session.user == null) {
      return FlashHelper.addParam(req.session, 'redirect_uri', req.originalUrl, function(err) {
        return res.redirect('/login');
      });
    }
    UsersController.getUserData(req, res, next);
  };

  /* tokenized email links */
  router.all('/email/:accessToken', csrfProtection, EmailsController.getEmailTokenData, EmailsController.get);

  /* params + flash messages */
  router.all('/*', ApplicationController.dashboardInitialize);

  /* public pages */
  router.get('/', function(req, res) {
    res.render('pages/index', {
      layout: 'layouts/home',
      page: 'pages/index',
      data: req.data,
      flash: res._flash
    });
  });

  router
    .get('/services', HomesController.services)
    .get('/doc', DocumentationsController.index)
    .get('/doc/:folderId/:pageId', DocumentationsController.getPage);

  /* https only */
  router
    .all('/*', ApplicationController.restrictHttp);

  router
    .get('/login', csrfProtection, UsersController.sessionNew)
    .post('/login', csrfProtection, UsersController.sessionCreate)
    .get('/logout', UsersController.sessionDestroy)
    .get('/subscribe', csrfProtection, UsersController.new)
    .post('/subscribe', csrfProtection, UsersController.create)
    .get('/services', HomesController.services)
    .post('/actions/password_reset', csrfProtection, UsersController.processPasswordReset);

  /* dashboard / user area */
  router
    .all('/dashboard*', restrictedArea)
    .get('/dashboard', function(req, res) {
      return res.redirect('/dashboard/services');
    })
    .get('/dashboard/account', UsersController.view)
    .post('/dashboard/account', csrfProtection, UsersController.update)
    .get('/dashboard/account/edit', csrfProtection, UsersController.edit)
    .get('/dashboard/account/password_reset', csrfProtection, UsersController.passwordReset)
    .get('/dashboard/services/new', csrfProtection, ServicesController.new)
    .get('/dashboard/services', ServicesController.index)
    .post('/dashboard/services', csrfProtection, FormUpload.single('service_logo'), ServicesController.create)
    .get('/dashboard/services/:serviceName', ServicesController.getServiceData, ServicesController.view)
    .get('/dashboard/services/:serviceName/edit', csrfProtection, ServicesController.getServiceData, ServicesController.edit)
    .post('/dashboard/services/:serviceName', csrfProtection, FormUpload.single('service_logo'), ServicesController.getServiceData, ServicesController.update)
    .get('/dashboard/services/:serviceName/pages', csrfProtection, ServicesController.getServiceData, PagesController.index)
    .get('/dashboard/services/:serviceName/pages/new', csrfProtection, ServicesController.getServiceData, PagesController.new)
    .post('/dashboard/services/:serviceName/pages', csrfProtection, ServicesController.getServiceData, PagesController.create)
    .get('/dashboard/services/:serviceName/users', csrfProtection, ServicesController.getServiceData, ServicesController.users)
    .post('/dashboard/services/:serviceName/users', csrfProtection, ServicesController.getServiceData, ServicesController.inviteUser)
    .post('/dashboard/services/:serviceName/users/:userEmail/destroy', csrfProtection, ServicesController.getServiceData, ServicesController.revokeUser)
    .get('/dashboard/services/:serviceName/tokens', csrfProtection, ServicesController.getServiceData, TokensController.index)
    .get('/dashboard/services/:serviceName/routes', csrfProtection, ServicesController.getServiceData, RoutesController.index)
    .post('/dashboard/services/:serviceName/routes', csrfProtection, ServicesController.getServiceData, RoutesController.create)
    .get('/dashboard/services/:serviceName/routes/new', csrfProtection, ServicesController.getServiceData, RoutesController.new)
    .get('/dashboard/services/:serviceName/routes/:routeName', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.view)
    .get('/dashboard/services/:serviceName/routes/:routeName/edit', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.edit)
    .post('/dashboard/services/:serviceName/routes/:routeName/drop', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.drop)
    .post('/dashboard/services/:serviceName/routes/:routeName/remove', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.remove)
    .post('/dashboard/services/:serviceName/routes/:routeName', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.update)
    .get('/dashboard/services/:serviceName/routes/:routeName/relations', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RelationsController.index)
    .get('/dashboard/services/:serviceName/routes/:routeName/relations/new', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.getServiceRoutes, RelationsController.new)
    .get('/dashboard/services/:serviceName/routes/:routeName/relations/:relationId/edit', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.getServiceRoutes, RelationsController.getRelationData, RelationsController.edit)
    .post('/dashboard/services/:serviceName/routes/:routeName/relations/:relationId', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.getServiceRoutes, RelationsController.getRelationData, RelationsController.update)
    .post('/dashboard/services/:serviceName/routes/:routeName/relations/:relationId/destroy', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.getServiceRoutes, RelationsController.getRelationData, RelationsController.destroy)
    .post('/dashboard/services/:serviceName/routes/:routeName/relations', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, RoutesController.getServiceRoutes, RelationsController.create)
    .get('/dashboard/services/:serviceName/routes/:routeName/fields', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.index)
    .get('/dashboard/services/:serviceName/routes/:routeName/fields/new', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.new)
    .post('/dashboard/services/:serviceName/routes/:routeName/fields', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.create)
    .get('/dashboard/services/:serviceName/routes/:routeName/fields/:fieldId/edit', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.getFieldData, FieldsController.edit)
    .post('/dashboard/services/:serviceName/routes/:routeName/fields/:fieldId', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.getFieldData, FieldsController.update)
    .post('/dashboard/services/:serviceName/routes/:routeName/fields/:fieldId/destroy', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.getFieldData, FieldsController.destroy)
    .post('/dashboard/services/:serviceName/routes/:routeName/fields/:fieldId/up', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.getFieldData, FieldsController.up)
    .post('/dashboard/services/:serviceName/routes/:routeName/fields/:fieldId/down', csrfProtection, ServicesController.getServiceData, RoutesController.getRouteData, FieldsController.getFieldData, FieldsController.down)
    .post('/dashboard/services/:serviceName/tokens/generate', csrfProtection, ServicesController.getServiceData, TokensController.generateTokenFromDashboard)
    .get('/dashboard/services/:serviceName/tokens/generate', ServicesController.getServiceData, TokensController.gotoIndex)
    .post('/dashboard/services/:serviceName/clientSecret', csrfProtection, ServicesController.getServiceData, ServicesController.showClientSecretFromDashboard)
    .post('/dashboard/services/:serviceName/clientId', csrfProtection, ServicesController.getServiceData, ServicesController.showClientIdFromDashboard)
    .post('/dashboard/services/:serviceName/tokens/:accessToken/destroy', csrfProtection, ServicesController.getServiceData, TokensController.getTokenData, TokensController.destroy)
    .get('/dashboard/services/:serviceName/tokens/:accessToken/destroy', ServicesController.getServiceData, TokensController.gotoIndex)
    .post('/dashboard/services/:serviceName/tokens/:accessToken/revoke', csrfProtection, ServicesController.getServiceData, TokensController.getTokenData, TokensController.revoke)
    .get('/dashboard/services/:serviceName/tokens/:accessToken/revoke', ServicesController.getServiceData, TokensController.gotoIndex);

  return router;
};
