'use strict';

const request = require('request'),
  StandardError = require('standard-error'),
  tokenModel = require('../../../models/v1/Token.model.js');

module.exports = AuthController;

function AuthController(options) {
  options = options || {};
  const logger = options.logger;
  const TokenModel = new tokenModel(options);

  this.authorize = function(req, res, next) {
    const access_token = req.body.access_token || req.query.access_token;
    if (!access_token)
      return next({messages: ["missing access_token"], code: 401});
    TokenModel.io.findOne({
      accessToken: access_token
    }, function(err, num) {
      if (err)
        return next({code: 500});
      if (!num)
        return next({messages: ['invalid token'], code: 401});
      if (num.accessTokenExpiresOn  < new Date())
        return next({messages: ['expired session'], code: 401});
      next();
    });
  }
}
