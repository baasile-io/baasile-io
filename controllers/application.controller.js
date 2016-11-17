'use strict';

const _ = require('lodash'),
  CONFIG = require('../config/app.js'),
  flashHelper = require('../helpers/flash.helper.js'),
  domurl = require('domurl');

module.exports = ApplicationController;

function ApplicationController(options) {
  options = options || {};
  const logger = options.logger;
  const FlashHelper = new flashHelper(options);

  this.dashboardInitialize = function(req, res, next) {
    req.data = req.data || {};
    req.data.user = req.session.user;
    res._serverUri = req.protocol + '://' + req.get('host');
    res._apiuri = res._serverUri + '/api/' + CONFIG.api.current_version_url;
    res._originalUrl = req.protocol + '://' + req.get('host') + req.originalUrl;
    res._originalUrlObject = new domurl(res._originalUrl, true);
    FlashHelper.get(req.session, function(err, flash) {
      if (err)
        return next(err);
      res._flash = flash;
      next();
    });
  };

  this.apiInitialize = function (req, res, next) {
    res._originalUrl = req.protocol + '://' + req.get('host') + req.originalUrl;
    res._originalUrlObject = new domurl(res._originalUrl, true);

    // set response
    res.set({
      "Content-Type": "application/vnd.api+json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PATCH, DELETE, OPTIONS",
      "Access-Control-Allow-Headers": req.headers["access-control-request-headers"] || "",
      "Cache-Control": "private, must-revalidate, max-age=0",
      "Expires": "Thu, 01 Jan 1970 00:00:00"
    });

    res._jsonapi = {
      version: CONFIG.api.current_version
    };
    res._serverUri = req.protocol + '://' + req.get('host') + '/api';
    res._apiuri = res._serverUri + '/api';

    res._links = {self: res._originalUrl};

    res._meta = {};
    res._data;
    res._included = [];
    next();
  };

  this.restrictHttp = function(req, res, next) {
    // allow https only (heroku or production environment)
    if ((options.nodeEnv === 'heroku' && req.headers['x-forwarded-proto'] !== 'https')
      || (options.nodeEnv === 'production' && req.secure === false)) {
      return next({code: 403, messages: ['forbidden_access', 'You must use HTTPS protocol']});
    }
    next();
  };

  this.apiCheckRequest = function(req, res, next) {
    if (req.method === "OPTIONS") {
      return next({code: 204, messages: ['no_content', 'There is no content to provide']});
    }

    if (!req.headers["content-type"] && !req.headers.accept) return next();

    if (req.headers["content-type"]) {
      // 415 Unsupported Media Type
      if (req.headers["content-type"].match(/^application\/vnd\.api\+json;.+$/)) {
        return next({code: 415, messages: ['unsupported_media_type', 'Unsupported Media Type - [' + req.headers["content-type"] + ']']});
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
        return next({code: 406, messages: ['not_acceptable', 'Not Acceptable Accept Header - [' + req.headers.accept + ']']});
      }
    }

    return next();
  };
};
