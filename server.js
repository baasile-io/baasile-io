'use strict';

const http = require('http');
const express = require('express');
const StandardError = require('standard-error');
const emptylogger = require('bunyan-blackhole');
const expressBunyanLogger = require("express-bunyan-logger");
const cors = require('cors');
const S = require('string');
const routes = require('./routes/routes.js');

module.exports = Server;

function Server (options) {
  var self = this;
  options = options || {};
  options.port = options.port || 0;
  options.logger = options.logger || emptylogger();
  var logger = options.logger
  var app = express();
  app.set("port", options.port);
  app.disable('x-powered-by');
  var corsOptions = {
    exposedHeaders: ['Range', 'Content-Range', 'X-Content-Range'],
    credentials: true,
    origin: function (origin, callback) {
      logger.info('using cors origin', origin);
      callback(null, true);
    }
  };
  app.use(cors(corsOptions));

  app.use(expressBunyanLogger({
    name: "requests",
    logger: logger
  }));

  app.use((req, res, next) => {
      req.logger = logger;
    next();
  })

  app.use(express.static(__dirname + '/public'));

  routes.configure(app, options);

  app.use(function notFound(req, res, next) {
    next(new StandardError('no route for URL ' + req.url, {code: 404}));
  });

  app.use(function (err, req, res, next) {
    req.logger.error({error: err}, err.message);
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


  this.getPort = function() {
    return this.port;
  };

  var server = http.createServer(app);
  this.start = function (onStarted) {
    server.listen(app.get('port'), function (error) {
      if (error) {
        logger.error({error: error}, 'Got error while starting server');
        return onStarted(error);
      }
      self.port = server.address().port;
      app.set('port', self.port);
      logger.info({
        event: 'server_started',
        port: self.port
      }, 'Server listening on port', self.port);
      onStarted();
    });
  };

  this.stop = function (onStopped) {
    logger.info({
      event: 'server_stopping'
    }, 'Stopping server');
    server.close(function (error) {
      if (error) {
        logger.error({error: error}, 'Got error while stopping server');
        return onStopped(error);
      }
      logger.info({
        event: 'server_stopped'
      }, 'server stopped');
      onStopped();
    });
  }
}
