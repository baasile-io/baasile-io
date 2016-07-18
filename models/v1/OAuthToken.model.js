'use strict';

const mongoose = require('mongoose'),
  serviceModel = require('./Service.model.js'),
  StandardError = require('standard-error');

module.exports = OAuthTokenModel;

var OAuthTokenSchema = new mongoose.Schema({
  accessToken: {
    type: String,
    required: true
  },
  accessTokenExpiresAt: {
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

function OAuthTokenModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const ServiceModel = new serviceModel(options);

  this.io = db.model('OAuthToken', OAuthTokenSchema);

  this.getAccessToken = function(bearerToken) {
    logger.info('getAccessToken (bearerToken: ' + bearerToken + ')');

    return this.io.findOne({
      access_token: bearerToken
    });
  };

  this.getClient = function(clientId, clientSecret) {
    logger.info('getClient (clientId: ' + clientId + ', clientSecret: ' + clientSecret + ')');
    return ServiceModel.io.findOne({
      //_id: clientId,
      secret: clientId
    });
    /*
    return new Promise(function(resolve, reject) {
      ServiceModel.io.findOne({
        //_id: clientId,
        secret: clientId
      }, function(err, service) {
        if (err)
          reject(err);
        if (!service)
          return reject(new StandardError('unknown client secret', {code: 400}));
        logger.info('returned service (_id: ' + service._id + ')');
        resolve(service);
      });
    });
    */
  };

  this.generateAccessToken = function() {
    logger.info('generateAccessToken');

    return 'abc';
  };

  this.generateAuthorizationCode = function() {
    logger.info('generateAuthorizationCode');

    return 'def';
  };

  this.generateRefreshToken = function() {
    logger.info('generateRefreshToken');

    return 'ghi';
  };

  this.revokeAuthorizationCode = function() {
    logger.info('revokeAuthorizationCode');

    return {
      expires_at: new Date() / 2
    }
  };

  this.saveAuthorizationCode = function() {
    logger.info('saveAuthorizationCode');

    return {
      authorizationCode: 'def'
    }
  };

  this.validateScope = function(user, client, scope) {
    logger.info('validateScope');

    return true;
  };

  this.getUser = function() {
    logger.info('getUser');

    return true;
  };
}
