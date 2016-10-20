'use strict';

const thumbnailService = require('./../services/thumbnail.service.js'),
  serviceModel = require('./../models/v1/Service.model.js'),
  awsSdk = require('aws-sdk'),
  fs = require('fs'),
  CONFIG = require('./../config/app.js');


module.exports = S3Task;

function S3Task(options) {
  var self = this;
  options = options || {};
  const logger = options.logger;

  awsSdk.config.region = options.s3Region;
  const s3Bucket = new awsSdk.S3({params: {Bucket: options.s3Bucket}});

  options.models = {
    ServiceModel: new serviceModel(options)
  };

  const ThumbnailService = new thumbnailService(options);

  this.start = function(onStarted) {
    onStarted();
    initBucket()
      .then(ThumbnailService.checkServicesLogosVersions)
      .then(function() {
        logger.info('task terminated');
        process.exit();
      })
      .catch(function(err) {
        logger.info('task error: ' + err);
        process.exit();
      });
  };

  function initBucket() {
    return new Promise(function(resolve, reject) {
      if (typeof options.s3Bucket === 'undefined')
        return reject('s3Bucket is undefined');
      var params = {
        ACL: 'public-read'
      };
      const assets = CONFIG.dashboard.assets.sources;
      function uploadAssets(i) {
        i = i || 0;
        if (i == assets.length)
          return resolve();

        fs.readFile(assets[i], function(err, body) {
          if (err)
            return reject('failed to read asset "' + assets[i] + '": ' + err);
          params.Key = assets[i];
          params.Body = body;
          s3Bucket.upload(params, function(err, data) {
            if (err)
              logger.warn("error uploading data to S3 bucket: " + err);
            uploadAssets(i + 1);
          });
        });
      }

      s3Bucket.createBucket(function(err) {
        if (err && err.code != 'BucketAlreadyOwnedByYou')
          return reject('failed to create s3 bucket: ' + err);
        return uploadAssets();
      });
    });
  }

}
