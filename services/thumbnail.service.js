'use strict';

const CONFIG = require('../config/app.js'),
  s3Uploader = require('s3-uploader');

module.exports = ThumbnailService;

function ThumbnailService(options) {
  options = options || {};
  const logger = options.logger;
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

  this.process = function(source, destination) {
    return new Promise(function (resolve, reject) {
      if (typeof S3Uploader === 'undefined') {
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
          // 1024 760 https://my-bucket.s3.amazonaws.com/path/110ec58a-a0f2-4ac4-8393-c866d813b8d1.jpg
        });
        return resolve();
      });
    });
  }
}
