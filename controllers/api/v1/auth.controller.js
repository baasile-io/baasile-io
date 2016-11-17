'use strict';

const request = require('request');

module.exports = AuthController;

function AuthController(options) {
  options = options || {};
  const logger = options.logger;
  const TokenModel = options.models.TokenModel;
  const ServiceModel = options.models.ServiceModel;

  this.authorize = function(req, res, next) {
    if (res._service)
      return next();
    const access_token = res._request.params.access_token;
    if (!access_token)
      return next({messages: ['missing_parameter', '"access_token" is required'], code: 400});
    TokenModel.io.findOne({
      accessToken: access_token
    }, function(err, token) {
      if (err)
        return next({code: 500});
      if (!token)
        return next({messages: ['invalid_token'], code: 401});
      if (token.accessTokenExpiresOn  < new Date())
        return next({messages: ['expired_session'], code: 401});
      const now = new Date();
      token.accessTokenExpiresOn = new Date(now.getTime() + options.tokenExpiration * 60000);
      token.nbOfUse++;
      token.save(function(err) {
        if (err)
          logger.warn('failed to update token expiration date: ' + err);
        ServiceModel.io.findOne({
          _id: token.service
        }, function(err, service) {
          if (err)
            return next({code: 500});
          if (!service.validated)
            return next({messages: ['not_validated', 'Votre service n\'a pas été validé par l\'Équipe API-CPA'], code: 401});
          res._service = service;
          return next();
        });
      });
    });
  };

  this.authenticate = function(req, res, next) {
    const clientSecret = res._request.params.client_secret;
    const clientId = res._request.params.client_id;
    if (!clientId)
      return next({messages: ['missing_parameter', '"client_id" is required'], code: 400});
    if (!clientSecret)
      return next({messages: ['missing_parameter', '"client_secret" is required'], code: 400});
    ServiceModel.io.findOne({
      clientId: clientId,
      clientSecret: clientSecret
    }, function(err, service) {
      if (err)
        return next({code: 500});
      if (!service)
        return next({messages: ['invalid_parameter', '"client_id" and/or "client_secret" are/is invalid'], code: 400});
      createToken(service)
        .then(function(accessToken) {
          return next({code: 200, data: {
            id: accessToken.createdAt,
            type: "tokens",
            attributes: {
              access_token: accessToken.accessToken,
              expires_on: accessToken.accessTokenExpiresOn
            }
          }});
        })
        .catch(function(errors) {
          return next({code: 500, messages: errors});
        });
    });
  };

  function createToken(service) {
    return new Promise(function(resolve, reject) {
      const now = new Date();
      const accessToken = TokenModel.generateToken();
      const accessTokenExpiresOn = new Date(now.getTime() + options.tokenExpiration * 60000);
      TokenModel.io.create({
        production: false,
        accessToken: accessToken,
        accessTokenExpiresOn: accessTokenExpiresOn,
        service: service,
        createdAt: now
      }, function (err, accessToken) {
        if (err) {
          let errors;
          if (err.code == 11000)
            err = 'non unique access_token';
          errors = [err];
          return reject(errors);
        }
        logger.info('accessToken created: ' + accessToken.accessToken);
        return resolve(accessToken);
      });
    });
  };
};
