'use strict';

const http = require('http'),
  express = require('express'),
  session = require('express-session'),
  expressLayouts = require('express-ejs-layouts'),
  emptylogger = require('bunyan-blackhole'),
  expressBunyanLogger = require("express-bunyan-logger"),
  cors = require('cors'),
  routes = require('./routes/routes.js'),
  MongoStore = require('connect-mongo')(session),
  mongodb = require('mongodb');

module.exports = Server;

function Server (options) {
  var self = this;
  options = options || {};
  options.port = options.port || 0;
  options.logger = options.logger || emptylogger();
  options.db = options.db || mongodb.MongoClient;
  options.tokenExpiration = 20; //minutes
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
    secret: options.expressSessionSecret,
    cookie: {
      maxAge: 360000
    },
    proxy: true,
    resave: false,
    saveUninitialized: true,
    store: new MongoStore({
      url: options.dbHost,
      collection: 'sessions'
    })
  }));

  app.use(function(req, res, next){
    req.session.touch();
    next();
  });

  app.set('view engine', 'ejs');
  app.set('layout', 'layouts/dashboard');
  app.set("layout extractStyles", true);
  app.set("layout extractScripts", true);
  app.use(expressLayouts);
  app.use(express.static(__dirname + '/public'));
  app.use('/semantic/dist/', express.static(__dirname + '/semantic/dist/'));

  var server = http.createServer(app);
  routes.configure(app, http, options);

  this.getPort = function() {
    return this.port;
  };

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
