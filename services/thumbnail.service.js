'use strict';

const CONFIG = require('../config/app.js'),
  s3Uploader = require('s3-uploader'),
  request = require('request'),
  fs = require('fs');

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

  this.checkVersions = function() {
    let versions = CONFIG.dashboard.thumbnail.versions;

    return new Promise(function(resolve, reject) {
      ServiceModel
        .io
        .find({})
        .cursor()
        .on('data', function (service) {
          var self = this;
          self.pause();
          let originalImgUri = options.s3BucketUrl + '/services/logos/' + service.clientId + '-original.png';
          request
            .get(originalImgUri)
            .on('response', function (response) {

              function checkVersion(i) {
                i = i || 0;
                if (i == versions.length)
                  return self.resume();
                let version = versions[i];
                request
                  .get(options.s3BucketUrl + '/services/logos/' + service.clientId + version.suffix + '.' + version.format)
                  .on('response', function (responseCheck) {
                    if (responseCheck.statusCode != 200) {
                      logger.info('missing thumbnails for service ' + service.clientId);
                      logger.info('downloading image: ' + originalImgUri);

                      request
                        .get(options.s3BucketUrl + '/services/logos/' + service.clientId + '-original.png')
                        .on('response', function (response) {
                          var file = fs.createWriteStream('uploads/tmp_service_logo');
                          response.pipe(file);
                          file
                            .on('error', function (err) {
                              logger.warn('failed to download image: ' + err);
                              self.destroy();
                            })
                            .on('finish', function () {
                              logger.info('generating thumbnails for service ' + service.clientId);
                              return doProcess({path: 'uploads/tmp_service_logo'}, 'services/logos/' + service.clientId)
                                .then(function () {
                                  self.resume();
                                })
                                .catch(function () {
                                  self.destroy();
                                });
                            });
                        });

                    } else {
                      checkVersion(i + 1);
                    }
                  });
              }

              if (response.statusCode != 200) {
                logger.info('generating default thumbnails for service ' + service.clientId);
                return doProcess({path: './public/assets/images/no-image.png'}, 'services/logos/' + service.clientId)
                  .then(function () {
                    self.resume();
                  })
                  .catch(function () {
                    self.destroy();
                  });
              } else {
                logger.info('checking thumbnails for service ' + service.clientId);
                checkVersion();
              }
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
