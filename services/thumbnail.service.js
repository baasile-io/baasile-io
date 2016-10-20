'use strict';

const CONFIG = require('../config/app.js'),
  s3Uploader = require('s3-uploader'),
  request = require('request');

module.exports = ThumbnailService;

function ThumbnailService(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = options.models.ServiceModel;
  var S3Uploader;

  if (options.s3Bucket) {
    S3Uploader = new s3Uploader(options.s3Bucket, {
      aws: {
        path: '',
        region: options.s3Region,
        acl: 'public-read'
      },
      cleanup: {
        versions: true,
        original: false
      },
      original: {
        awsImageAcl: 'private'
      },
      versions: CONFIG.dashboard.thumbnail.versions
    });
  }

  function doProcess(source, destination) {
    return new Promise(function (resolve, reject) {
      if (typeof S3Uploader === 'undefined') {
        logger.warn('S3Uploader is undefined');
        reject({code: 's3_undefined'});
      }
      S3Uploader.upload(source.path, {
        path: destination
      }, function(err, versions, meta) {
        if (err) {
          logger.warn(err);
          return reject({code: 's3_error', message: err});
        }
        versions.forEach(function(image) {
          logger.info(image.width, image.height, image.url);
        });
        return resolve();
      });
    });
  }

  this.process = doProcess;

  this.init = function() {
    let version = CONFIG.dashboard.thumbnail.versions[0];

    return new Promise(function(resolve, reject) {
      ServiceModel
        .io
        .find({})
        .cursor()
        .on('data', function (service) {
          var self = this;
          self.pause();
          request
            .get(options.s3BucketUrl + '/services/logos/' + service.clientId + version.suffix + '.' + version.format)
            .on('response', function (response) {
              if (response.statusCode != 200) {
                logger.info('generating thumbnails for service ' + service.clientId);
                return doProcess({path: './public/assets/images/no-image.png'}, 'services/logos/' + service.clientId)
                  .then(function() {
                    self.resume();
                  })
                  .catch(function(err) {
                    self.destroy();
                  });
              }
              self.resume();
            });
        })
        .on('error', function (err) {
          return reject(err);
        })
        .on('end', function () {
          return resolve();
        });
    });
  };
}
