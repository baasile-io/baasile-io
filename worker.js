'use strict';

const thumbnailService = require('./services/thumbnail.service.js'),
  serviceModel = require('./models/v1/Service.model.js');

module.exports = Worker;

function Worker(options) {
  var self = this;
  options = options || {};
  const logger = options.logger;

  options.models = {
    ServiceModel: new serviceModel(options)
  };

  const ThumbnailService = new thumbnailService(options);

  this.start = function(onStarted) {
    onStarted();
    ThumbnailService
      .init()
      .then(function() {
        logger.info('thumbnail.service terminated');
        process.exit();
      })
      .catch(function(err) {
        logger.info('thumbnail.service error: ' + err);
        process.exit();
      });
  };
}
