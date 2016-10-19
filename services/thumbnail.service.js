'use strict';

const s3Uploader = require('s3-uploader');

module.exports = ThumbnailsService;

function ThumbnailsService(options) {
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
      versions: [{
        maxHeight: 1040,
        maxWidth: 1040,
        format: 'png',
        suffix: '-large',
        awsImageExpires: 31536000,
        awsImageMaxAge: 31536000
      }, {
        maxWidth: 780,
        format: 'png',
        aspect: '3:2!h',
        suffix: '-medium'
      }, {
        maxWidth: 320,
        format: 'png',
        aspect: '16:9!h',
        suffix: '-small'
      }, {
        maxHeight: 100,
        format: 'png',
        aspect: '1:1',
        suffix: '-thumb1'
      }, {
        maxHeight: 250,
        maxWidth: 250,
        format: 'png',
        aspect: '1:1',
        suffix: '-thumb2'
      }]
    });
  }

  this.upload = function(source, destination) {
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
