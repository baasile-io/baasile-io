'use strict';

const mongoose = require('mongoose'),
  serviceModel = require('./Service.model.js'),
  StandardError = require('standard-error');

module.exports = TokenModel;

var TokenSchema = new mongoose.Schema({
  accessToken: {
    type: String,
    required: true
  },
  accessTokenExpiresOn: {
    type: Date,
    required: true
  },
  clientId: {
    type: String,
    required: true
  },
  production: {
    type: Boolean,
    required: true
  },
  created_at: Date,
  updated_at: Date
});

function TokenModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const ServiceModel = new serviceModel(options);

  this.io = db.model('Token', TokenSchema);

  this.getAccessToken = function(bearerToken) {
    logger.info('getAccessToken (bearerToken: ' + bearerToken + ')');

    return this.io.findOne({
      accessToken: bearerToken
    });
  };
}
