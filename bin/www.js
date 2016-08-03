'use strict';

const bunyan = require('bunyan'),
  bunyanFormat = require('bunyan-format'),
  nconf = require('nconf'),
  Server = require('../server'),
  http = require('http'),
  url = require('url');

nconf.env({
  separator: '_'
}).argv();
nconf.defaults(require('../defaults'));

var logger = bunyan.createLogger({
  name: nconf.get('appname'),
  level: nconf.get('log:level'),
  stream: bunyanFormat({
    outputMode: nconf.get('log:format')
  })
});

var mhttp = require('http-measuring-client').create();
mhttp.mixin(http);
mhttp.on('stat', function (parsed, stats) {
  logger.info({
    parsedUri: parsed,
    stats: stats
  }, '%s %s took %dms (%d)', stats.method || 'GET', url.format(parsed), stats.totalTime, stats.statusCode);
});

var server = new Server({
  tokenExpiration: nconf.get('tokenExpiration'),
  emailTokenExpiration: nconf.get('emailTokenExpiration'),
  apiUri: nconf.get('apiUri'),
  port: process.env.PORT || nconf.get('port'),
  dbHost: process.env.MONGODB_URI || nconf.get('MONGODB_URI'),
  expressSessionSecret: process.env.EXPRESS_SESSION_SECRET || nconf.get('EXPRESS_SESSION_SECRET'),
  expressSessionCookieMaxAge: Math.floor(process.env.EXPRESS_SESSION_COOKIE_MAX_AGE || nconf.get('EXPRESS_SESSION_COOKIE_MAX_AGE')),
  documentationServiceId: process.env.DOCUMENTATION_APP_ID || nconf.get('DOCUMENTATION_APP_ID'),
  sendgridPassword: process.env.SENDGRID_PASSWORD || nconf.get('sendgridPassword'),
  sendgridUsername: process.env.SENDGRID_USERNAME || nconf.get('sendgridUsername'),
  sendgridFrom: nconf.get('sendgridFrom'),
  logger: logger
});

server.start(function (err) {
  if (err) {
    logger.fatal({error: err}, 'cannot recover from previous errors. shutting down now. error was', err.stack);
    setTimeout(process.exit.bind(null, 99), 10);
  }
  logger.info('Sever successfully started.');
});
