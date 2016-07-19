'use strict';

const v1 = require('./api/v1/index.js'),
  dashboard = require('./dashboard/dashboard.router.js'),
  bodyParser = require('body-parser'),
  cookieParser = require('cookie-parser'),
  StandardError = require('standard-error'),
  S = require('string');

exports.configure = function (app, http, options) {
  const logger = options.logger;

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
  app.use('/api', bodyParser.urlencoded({ extended: false }));
  app.use('/api', bodyParser.json());
  app.use('/api/v1', v1(options));
  app.use('/api', function (err, req, res, next) {
    const status = err.code || 400;
    const messages = err.messages || ['Internal Server Error'];
    res.status(status).json({
      links: {
        self: req.protocol + '://' + req.get('host') + req.originalUrl
      },
      errors: messages
    }).end();
  }, function(req, res) {
    res.status(404).json({
      links: {
        self: req.protocol + '://' + req.get('host') + req.originalUrl
      },
      errors: ["not found"]
    }).end();
  });

  app.all('/api', function(req, res) {
    res.end();
  });

  // rendering views
  app.use(cookieParser());
  app.use('/', dashboard(options));
};
