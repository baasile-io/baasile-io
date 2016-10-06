'use strict';

const v1 = require('./api/v1/index.js'),
  authController = require('../controllers/api/v1/auth.controller.js'),
  notificationService = require('../services/notification.service.js'),
  dashboard = require('./website/dashboard.router.js'),
  applicationController = require('../controllers/application.controller.js'),
  paginationService = require('../services/pagination.service.js'),
  bodyParser = require('body-parser'),
  cookieParser = require('cookie-parser'),
  _ = require('lodash'),
  qs = require('qs');
  

exports.configure = function (app, http, options) {
  const logger = options.logger;
  const NotificationService = new notificationService(options);
  const AuthController = new authController(options);
  const ApplicationController = new applicationController(options);
  const PaginationService = new paginationService(options);

  // proxy
  app.enable('trust proxy'); // heroku proxy

  // api
  app.use('/api', ApplicationController.apiInitialize);
  app.use('/api', ApplicationController.restrictHttp);
  app.use('/api', ApplicationController.apiCheckRequest);
  
  app.use(bodyParser.json({reviver:{depth:10}}));
  app.use(bodyParser.urlencoded({ extended: true }));

  app.use('/', function (req, res, next) {
    // set data container
    req.data = req.data || {};

    // parse again query for depth filter
    if (req.query.filter !== undefined) {
      var filterParam = qs.parse(res._originalUrlObject.query, { depth: 10 });
      req.query.filter = filterParam.filter;
    }
    
    // set request
    res._request = {
      params: {}
    };
    
    _.merge(res._request.params, req.body, req.query);

    // inclusion
    res._request.params.include = typeof res._request.params.include === 'string' ? res._request.params.include.split(',') : [];

    next();
  });

  app.use('/', PaginationService.init);

  app.use('/api', v1(options));
  app.use('/api/v1', v1(options));

  app.use('/api', AuthController.authorize, PaginationService.setResponse, function (responseParams, req, res, next) {
    var status = responseParams.code || 500;
    var response = {};

    if (responseParams.links) {
      _.merge(res._links, responseParams.links);
    }
    if (responseParams.meta) {
      _.merge(res._meta, responseParams.meta);
    }
    if (typeof responseParams.results !== 'undefined') {
      res._data = [];
      responseParams.results.docs.forEach(function (doc) {
        res._data.push(doc.getResourceObject(res._apiuri, {include: res._request.params.include}));
        res._included = _.union(res._included, doc.getIncludedObjects(res._apiuri, {include: res._request.params.include}));
      });
      if (responseParams.results.total > responseParams.results.docs.length) {
        status = 206;
      }
    } else if (responseParams.data) {
      res._data = responseParams.data;
    }
    if (Array.isArray(responseParams.included) === true) {
      _.union(res._included, responseParams.included);
    }
    if (Array.isArray(res._data) === true) {
      res._meta.count = res._data.length;
    }
    if (Object.keys(res._jsonapi).length > 0)
      response.jsonapi = res._jsonapi;
    if (Object.keys(res._links).length > 0)
      response.links = res._links;
    if (Object.keys(res._meta).length > 0)
      response.meta = res._meta;
    if (typeof res._data !== 'undefined')
      response.data = res._data;
    if (res._included.length > 0) {
      response.included = res._included;
    }
    if (responseParams.messages) {
      if (!Array.isArray(responseParams.messages))
        responseParams.messages = [responseParams.messages];
      response.errors = responseParams.messages;
    }
    else if (status >= 400) {
      response.errors = ['internal_server_error'];
    }
    if (status >= 400)
      response.errors.push('status_code:' + status);
    if (status >= 300) {
      var serviceName = 'unknown service';
      if (res._service)
        serviceName = res._service.name;
      NotificationService.send({
        channel: '#api_errors',
        text: '[API] ' + status + ' ' + req.method + ' ' + res._originalUrl + ' (' + serviceName + ')'
      });
    }
    return res.status(status).json(response).end();
  }, function(req, res) {
    var serviceName = 'unknown service';
    if (res._service)
      serviceName = res._service.name;
    NotificationService.send({
      channel: '#api_errors',
      text: '[API] 404 ' + req.method + ' ' + res._originalUrl + ' (' + serviceName + ')'
    });
    return res.status(404).json({
      jsonapi: res._jsonapi,
      links: {
        self: res._originalUrl
      },
      errors: ['not_found', 'status_code:404']
    }).end();
  });

  app.use('/api', function(req, res) {
    res.end();
  });

  // rendering views
  app.use(cookieParser());
  app.use('/', dashboard(options));

  /* errors handler */
  app
    .use(function(err, req, res, next) {
      const status = err.code || err.status || err.statusCode || 500;
      if (status == 404)
        return next();
      logger.warn('an error occured (code: ' + status + ')');
      var page;
      switch(status) {
        case 501:
        case 410:
        case 500:
        case 403:
          page = 'pages/errors/error' + status;
          break;
        default:
          page = 'pages/errors/error500';
          break;
      }
      var userName = 'unknown user';
      if (req.data && req.data.user)
        userName = req.data.user.firstname + ' ' + req.data.user.lastname + ' / ' + req.data.user.email;
      NotificationService.send({
        channel: '#api_errors',
        text: '[DASHBOARD] ' + status + ' ' + req.method + ' ' + res._originalUrl + ' (' + userName + ')'
      });
      return res.status(status).render(page, {
        page: page,
        layout: 'layouts/error',
        data: req.data,
        flash: res._flash
      });
    });

  app
    .use(function(req, res) {
      const status = 404;
      logger.warn('page not found (code: ' + status + ') (' + res._originalUrl + ')');
      var userName = 'unknown user';
      if (req.data && req.data.user)
        userName = req.data.user.firstname + ' ' + req.data.user.lastname + ' / ' + req.data.user.email;
      NotificationService.send({
        channel: '#api_errors',
        text: '[DASHBOARD] 404 ' + req.method + ' ' + res._originalUrl + ' (' + userName + ')'
      });
      return res.status(status).render('pages/errors/error404', {
        page: 'pages/errors/error404',
        layout: 'layouts/error',
        data: req.data,
        flash: res._flash
      });
    });
};
