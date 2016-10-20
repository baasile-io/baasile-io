'use strict';

const nconf = require('nconf');

// enable live performance monitoring
const newRelicLicenseKey = process.env.NEW_RELIC_LICENSE_KEY || nconf.get('NEW_RELIC_LICENSE_KEY');
if (newRelicLicenseKey) {
  require('newrelic');
}

const bunyan = require('bunyan'),
  bunyanFormat = require('bunyan-format'),
  Server = require('../server'),
  http = require('http'),
  url = require('url');

nconf.env({
  separator: '_'
}).argv();
nconf.defaults(require('../defaults'));

const logger = bunyan.createLogger({
  name: nconf.get('appname'),
  level: nconf.get('log:level'),
  stream: bunyanFormat({
    outputMode: nconf.get('log:format')
  })
});

const slackWebhookUrl = process.env.SLACK_WEBHOOK_URL || nconf.get('slackWebhookUrl');
var slack;
if (slackWebhookUrl && slackWebhookUrl != '')
  slack = require('slack-notify')(slackWebhookUrl);

var mhttp = require('http-measuring-client').create();
mhttp.mixin(http);
mhttp.on('stat', function (parsed, stats) {
  logger.info({
    parsedUri: parsed,
    stats: stats
  }, '%s %s took %dms (%d)', stats.method || 'GET', url.format(parsed), stats.totalTime, stats.statusCode);
});

var options = {
  adminNotificationEmail: nconf.get('adminNotificationEmail'),
  tokenExpiration: nconf.get('tokenExpiration'),
  emailTokenExpiration: nconf.get('emailTokenExpiration'),
  apiUri: nconf.get('apiUri'),
  port: process.env.PORT || nconf.get('port'),
  dbHost: process.env.MONGODB_URI || nconf.get('MONGODB_URI'),
  expressSessionSecret: process.env.EXPRESS_SESSION_SECRET || nconf.get('EXPRESS_SESSION_SECRET'),
  expressSessionCookieMaxAge: Math.floor(process.env.EXPRESS_SESSION_COOKIE_MAX_AGE || nconf.get('EXPRESS_SESSION_COOKIE_MAX_AGE')),
  sendgridPassword: process.env.SENDGRID_PASSWORD || nconf.get('sendgridPassword'),
  sendgridUsername: process.env.SENDGRID_USERNAME || nconf.get('sendgridUsername'),
  sendgridFrom: nconf.get('sendgridFrom'),
  nodeEnv: process.env.NODE_ENV || nconf.get('NODE_ENV') || 'development',
  logger: logger,
  slack: slack,
  slackChannelPrefix: process.env.SLACK_CHANNEL_SUFFIX || nconf.get('SLACK_CHANNEL_SUFFIX') || 'development',
  s3Bucket: process.env.S3_BUCKET || nconf.get('S3_BUCKET'),
  s3Region: process.env.AWS_DEFAULT_REGION || nconf.get('AWS_DEFAULT_REGION')
};

if (typeof options.s3Region !== 'undefined' && typeof options.s3Bucket !== 'undefined') {
  options.s3BucketUrl = 'https://s3-' + options.s3Region + '.amazonaws.com/' + options.s3Bucket;
}

if (process.argv.indexOf('s3.task') != -1) {
  const s3Task = require('../tasks/s3.task.js');
  var S3Task = new s3Task(options);

  S3Task.start(function (err) {
    if (err) {
      logger.fatal({error: err}, 'cannot recover from previous errors. shutting down now. error was', err.stack);
      setTimeout(process.exit.bind(null, 99), 10);
    }
    logger.info('Task successfully started.');
  });

} else {
  var server = new Server(options);

  server.start(function (err) {
    if (err) {
      logger.fatal({error: err}, 'cannot recover from previous errors. shutting down now. error was', err.stack);
      setTimeout(process.exit.bind(null, 99), 10);
    }
    logger.info('Sever successfully started.');
  });
}