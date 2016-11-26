'use strict';

const http = require('http'),
  path = require('path'),
  express = require('express'),
  session = require('express-session'),
  favicon = require('serve-favicon'),
  expressLayouts = require('express-ejs-layouts'),
  emptylogger = require('bunyan-blackhole'),
  expressBunyanLogger = require("express-bunyan-logger"),
  cors = require('cors'),
  routes = require('./routes/routes.js'),
  MongoStore = require('connect-mongo')(session),
  mongodb = require('mongodb'),
  mongoose = require('mongoose');

const userModel = require('./models/v1/User.model.js'),
  serviceModel = require('./models/v1/Service.model.js'),
  routeModel = require('./models/v1/Route.model.js'),
  fieldModel = require('./models/v1/Field.model.js'),
  pageModel = require('./models/v1/Page.model.js'),
  dataModel = require('./models/v1/Data.model.js'),
  relationModel = require('./models/v1/Relation.model.js'),
  tokenModel = require('./models/v1/Token.model.js'),
  emailTokenModel = require('./models/v1/EmailToken.model.js');

const thumbnailService = require('./services/thumbnail.service.js');

module.exports = Server;

function Server(options) {
  var self = this;
  options = options || {};
  options.port = options.port || 0;
  options.logger = options.logger || emptylogger();
  options.db = options.db || mongodb.MongoClient;
  options.tokenExpiration = options.tokenExpiration || 20; //minutes
  options.expressSessionCookieMaxAge = options.expressSessionCookieMaxAge || 5; //minutes

  options.models = {
    UserModel: new userModel(options),
    ServiceModel: new serviceModel(options),
    RouteModel: new routeModel(options),
    FieldModel: new fieldModel(options),
    PageModel: new pageModel(options),
    DataModel: new dataModel(options),
    RelationModel: new relationModel(options),
    TokenModel: new tokenModel(options),
    EmailTokenModel: new emailTokenModel(options)
  };

  options.services = {
    ThumbnailService: new thumbnailService(options)
  };

  var logger = options.logger;
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

  app.locals.getAssetUri = function(file) {
    if (options.s3BucketUrl)
      return options.s3BucketUrl + '/public/' + file;
    return '/' + file;
  };

  app.use(session({
    secret: options.expressSessionSecret,
    cookie: {
      maxAge: options.expressSessionCookieMaxAge * 60000
    },
    proxy: true,
    resave: false,
    saveUninitialized: true,
    rolling: true,
    store: new MongoStore({
      url: options.dbHost,
      collection: 'sessions'
    })
  }));

  app.get('/robots.txt', function(req, res) {
    res.type('text/plain');
    if (options.nodeEnv === 'production')
      res.send("User-agent: *\nDisallow:");
    else
      res.send("User-agent: *\nDisallow: /");
  });

  app.set('view engine', 'ejs');
  app.set('layout', 'layouts/dashboard');
  app.set("layout extractStyles", true);
  app.set("layout extractScripts", true);
  app.use(expressLayouts);

  app.use(function(req, res, next){
    req.session.touch();
    next();
  });

  if (typeof options.s3BucketUrl === 'undefined') {
    app.use(express.static(__dirname + '/public'));
    app.use('/semantic/dist/', express.static(__dirname + '/semantic/dist/'));
    app.use(favicon(path.join(__dirname, 'public', 'assets', 'images', 'api-cpa.ico')));
  }

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
      options.address = server.address();
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
