'use strict';

module.exports = NotificationService;

function NotificationService(options) {
  options = options || {};
  const logger = options.logger;
  const slack = options.slack;

  this.send = function(opt) {
    opt = opt || {};
    if (typeof slack != 'undefined') {
      slack.send({
        channel: opt.channel || "#api_notifications",
        text: opt.text,
        fields: opt.fields
      }, function(err) {
        if (err)
          logger.warn('slack error: ' + JSON.stringify(err));
      });
    } else
      logger.warn('no configuration available for slack notifications');
  };
};
