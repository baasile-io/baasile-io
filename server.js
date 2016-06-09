'use strict';

const http = require('http'),
  express = require('express'),
  session = require('express-session'),
  expressLayouts = require('express-ejs-layouts'),
  StandardError = require('standard-error'),
  emptylogger = require('bunyan-blackhole'),
  expressBunyanLogger = require("express-bunyan-logger"),
  cors = require('cors'),
  S = require('string'),
  routes = require('./routes/routes.js'),
  MongoStore = require('connect-mongo')(session),
  mongodb = require('mongodb'),
  i18n = require('i18n');

i18n.configure({
  locales: ['fr'],
  directory: './locales'
});

module.exports = Server;

function Server (options) {
  var self = this;
  options = options || {};
  options.port = options.port || 0;
  options.logger = options.logger || emptylogger();
  options.db = options.db || mongodb.MongoClient;
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

  app.use(function(req, res, next) {
    req.logger = logger;
    next();
  });

  app.use(session({
    secret: '16e17272a924d78e65eee5121d19dd1ddefc0db1',
    proxy: true,
    resave: true,
    saveUninitialized: true,
    store: new MongoStore({ url: options.dbHost, collection: 'sessions' })
  }));

  app.use(i18n.init);

  app.set('view engine', 'ejs');
  app.set('layout', 'layouts/dashboard');
  app.set("layout extractStyles", true);
  app.set("layout extractScripts", true);
  app.use(expressLayouts);
  app.use(express.static(__dirname + '/public'));
  app.use('/semantic/dist/', express.static(__dirname + '/semantic/dist/'));

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
