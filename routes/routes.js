'use strict';

const v1 = require('./api/v1/index.js'),
  authController = require('../controllers/api/v1/auth.controller.js'),
  notificationService = require('../services/notification.service.js'),
  dashboard = require('./website/dashboard.router.js'),
  applicationController = require('../controllers/application.controller.js'),
  bodyParser = require('body-parser'),
  cookieParser = require('cookie-parser'),
  StandardError = require('standard-error'),
  _ = require('lodash'),
  S = require('string'),
  CONFIG = require('../config/app.js');

exports.configure = function (app, http, options) {
  const logger = options.logger;
  const NotificationService = new notificationService(options);
  const AuthController = new authController(options);
  const ApplicationController = new applicationController(options);

  // proxy
  app.enable('trust proxy'); // heroku proxy

  // api
  app.use('/api', ApplicationController.apiInitialize);
  app.use('/api', ApplicationController.restrictHttp);
  app.use('/api', ApplicationController.apiCheckRequest);

  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: false }));

  app.use('/api', function (req, res, next) {
    // set request
    var request = {
      params: {}
    };
    _.merge(request.params, req.body, req.query);
    res._request = request;

    // inclusion
    res._include = typeof request.params.include === 'string' ? request.params.include.split(',') : [];

    // pagination
    res._paginate = {};
    const isPaginated = typeof request.params.page !== 'undefined';
    if (isPaginated && typeof request.params.page.offset !== 'undefined') {
      res._paginate.offset = Number(request.params.page.offset);
    } else if (isPaginated && typeof request.params.page.number !== 'undefined') {
      res._paginate.offset = Number(request.params.page.number);
    } else {
      res._paginate.offset = CONFIG.api.pagination.offset;
    }
    if (isPaginated && typeof request.params.page.limit !== 'undefined') {
      res._paginate.limit = Number(request.params.page.limit);
    } else if (isPaginated && typeof request.params.page.size !== 'undefined') {
      res._paginate.limit = Number(request.params.page.size);
    } else {
      res._paginate.limit = CONFIG.api.pagination.limit;
    }

    next();
  });

  app.use('/api', v1(options));
  app.use('/api/v1', v1(options));

  app.use('/api', AuthController.authorize, function (responseParams, req, res, next) {
    const status = responseParams.code || 400;
    const response = {
      jsonapi: res._jsonapi,
      links: {
        self: res._originalUrl
      }
    };
    if (responseParams.links) {
      _.merge(response.links, responseParams.links);
    }
    if (responseParams.meta) {
      response.meta = responseParams.meta;
    }
    if (typeof responseParams.results !== 'undefined' || Array.isArray(response.data)) {
      response.meta = response.meta || {};
      if (typeof responseParams.results !== 'undefined') {
        response.meta.count = responseParams.results.docs.length;
        response.meta.total = responseParams.results.total;
        response.meta.total_pages = res._paginate.limit != 0 ? Math.ceil(responseParams.results.total / res._paginate.limit) : 1;
        response.links.first = response.links.self + '/?page[offset]=0&page[limit]=' + res._paginate.limit;
        if (res._paginate.offset > 0) {
          const offsetPrev = res._paginate.offset - res._paginate.limit;
          response.links.prev = response.links.self + '/?page[offset]=' + (offsetPrev > 0 ? offsetPrev : 0) + '&page[limit]=' + res._paginate.limit;
        }
        if (res._paginate.offset + res._paginate.limit < responseParams.results.total) {
          response.links.next = response.links.self + '/?page[offset]=' + (res._paginate.offset + res._paginate.limit) + '&page[limit]=' + res._paginate.limit;
        }
        //if (res._paginate.limit < responseParams.results.total) {
        //  response.links.last = response.links.self + '/?page[offset]=' + (Math.ceil(responseParams.results.total / res._paginate.limit) + (responseParams.results.total % res._paginate.limit)) + '&page[limit]=' + res._paginate.limit;
        //}
      } else {
        response.meta.count = responseParams.data.length;
      }
      response.meta.offset = res._paginate.offset;
      response.meta.limit = res._paginate.limit;
    }
    if (typeof responseParams.results !== 'undefined') {
      response.data = [];
      var included = [];
      responseParams.results.docs.forEach(function(doc) {
        response.data.push(doc.getResourceObject(res._apiuri, {include: res._include}));
        included = _.union(included, doc.getIncludedObjects(res._apiuri, {include: res._include}));
      });
      if (included.length > 0)
        response.included = included;
    } else if (responseParams.data) {
      response.data = responseParams.data;
    }
    if (Array.isArray(responseParams.included) === true && responseParams.included.length > 0) {
      _.union(response.included, responseParams.included);
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
