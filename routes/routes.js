'use strict';

const v1 = require('./v1/index.js'),
  dashboard = require('./dashboard/index.js'),
  bodyParser = require('body-parser'),
  cookieParser = require('cookie-parser');

exports.configure = function (app, options) {
  // api
  app.use('/v1', v1(options));

  // rendering views
  app.use(bodyParser.urlencoded({ extended: false }))
  app.use(cookieParser())
  app.use('/', dashboard(options));
};
