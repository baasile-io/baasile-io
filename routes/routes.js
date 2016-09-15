'use strict';

const v1 = require('./api/v1/index.js'),
  notificationService = require('../services/notification.service.js'),
  dashboard = require('./website/dashboard.router.js'),
  documentation = require('./website/documentation.router.js'),
  bodyParser = require('body-parser'),
  cookieParser = require('cookie-parser'),
  StandardError = require('standard-error'),
  S = require('string'),
  _ = require('lodash');

exports.configure = function (app, http, options) {
  const logger = options.logger;
  const NotificationService = new notificationService(options);

  // api
  app.use('/api', function(req, res, next) {
    res.set({
      "Content-Type": "application/vnd.api+json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PATCH, DELETE, OPTIONS",
      "Access-Control-Allow-Headers": req.headers["access-control-request-headers"] || "",
      "Cache-Control": "private, must-revalidate, max-age=0",
      "Expires": "Thu, 01 Jan 1970 00:00:00"
    });

    if (req.method === "OPTIONS") {
      return next({messages: ["No Content"], code: 204});
    }

    return next();
  });
  app.use('/api', function(req, res, next) {
    if (!req.headers["content-type"] && !req.headers.accept) return next();

    if (req.headers["content-type"]) {
      // 415 Unsupported Media Type
      if (req.headers["content-type"].match(/^application\/vnd\.api\+json;.+$/)) {
        return next({messages: ["Unsupported Media Type - [" + req.headers["content-type"] + "]"], code: 415});
      }

      // Convert "application/vnd.api+json" content type to "application/json".
      // This enables the express body parser to correctly parse the JSON payload.
      if (req.headers["content-type"].match(/^application\/vnd\.api\+json$/)) {
        req.headers["content-type"] = "application/json";
      }
    }

    if (req.headers.accept) {
      // 406 Not Acceptable
      var matchingTypes = req.headers.accept.split(/, ?/);
      matchingTypes = matchingTypes.filter(function(mediaType) {
        // Accept application/*, */vnd.api+json, */* and the correct JSON:API type.
        return mediaType.match(/^(\*|application)\/(\*|vnd\.api\+json)$/) || mediaType.match(/\*\/\*/);
      });

      if (matchingTypes.length === 0) {
        return next({messages: ["Not Acceptable Accept Header - [" + req.headers.accept + "]"], code: 406});
      }
    }

    return next();
  });
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: false }));

  app.use('/api', function (req, res, next) {
    // set request
    var request = {
      params: {}
    };
    _.merge(request.params, req.body, req.query);
    res._request = request;
    res._originalUrl = req.protocol + '://' + req.get('host') + '/api/' + _.trim(req.path, '/');
    return next();
  });

  app.use('/api', v1(options));
  app.use('/api/v1', v1(options));

  app.use('/api', function (responseParams, req, res, next) {
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
    if (responseParams.data) {
      if (Array.isArray(responseParams.data)) {
        response.meta = response.meta || {};
        response.meta.count = responseParams.data.length;
      }
      response.data = responseParams.data;
    }
    if (responseParams.included) {
      response.included = responseParams.included;
    }
    if (responseParams.messages) {
      response.errors = responseParams.messages;
    }
    else if (status >= 400) {
      response.errors = ['internal_server_error'];
    }
    if (status >= 400)
      response.errors.push('status_code:' + status);
    return res.status(status).json(response).end();
  }, function(req, res) {
    var serviceName;
    if (req.data && req.data.service)
      serviceName = req.data.service.name;
    NotificationService.send({
      text: '404 ' + res._originalUrl + ' (' + serviceName + ')'
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
  app.use('/doc', documentation(options));

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
          page = 'pages/errors/error' + status;
          break;
        default:
          page = 'pages/errors/error500';
          break;
      }
      return res.render(page, {
        page: page,
        layout: 'layouts/error',
        data: req.data,
        flash: res._flash
      });
    });

  app
    .use(function(req, res) {
      const status = 404;
      logger.warn('page not found (code: ' + status + ') (' + req.originalUrl + ')');
      var userName;
      if (req.data && req.data.user)
        userName = req.data.user.firstname + ' ' + req.data.user.lastname;
      NotificationService.send({
        text: '404 ' + req.originalUrl + ' (' + userName + ')'
      });
      return res.render('pages/errors/error404', {
        page: 'pages/errors/error404',
        layout: 'layouts/error',
        data: req.data,
        flash: res._flash
      });
    });
};
