'use strict';

const v1 = require('./api/v1/index.js'),
  dashboard = require('./dashboard/dashboard.router.js'),
  bodyParser = require('body-parser'),
  cookieParser = require('cookie-parser'),
  oAuthTokenModel = require('./../models/v1/OAuthToken.model.js'),
  oauthServer = require('express-oauth-server'),
  StandardError = require('standard-error'),
  S = require('string');

exports.configure = function (app, http, options) {
  const logger = options.logger;
  const OAuthTokenModel = new oAuthTokenModel(options);
  const oauth = new oauthServer({
    debug: true,
    model: OAuthTokenModel
  });

  app.use(bodyParser.urlencoded({ extended: false }));

  // api
  app.use('/api/v1', bodyParser.json(), oauth.authorize(), v1(options));

  app.use('/api*', function notFound(err, req, res, next) {
    if (!err)
      next(new StandardError('no route for URL ' + req.url, {code: 404}));
    res.end();
  });

  app.use('/api/v1*', function (err, req, res, next) {
    logger.error({error: err}, err.message);
    if (err.code) {
      if (err instanceof StandardError) {
        let error = {
          error: S(http.STATUS_CODES[err.code]).underscore().s,
          reason: err.message
        }
        return res.status(err.code).json(error)
      }
    }
    next(err);
  });

  // rendering views
  app.use(cookieParser());
  app.use('/', dashboard(options));
};
