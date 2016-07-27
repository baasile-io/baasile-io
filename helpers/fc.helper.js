'use strict';

const request = require('request'),
  crypto = require('crypto'),
  _ = require('lodash');

module.exports = FranceConnectHelper;

function FranceConnectHelper(options) {
  options = options || {};
  const logger = options.logger;

  this.checkToken = function(fc_token, scope) {
    logger.info("a request is done to france connect with token '" + fc_token + "'");
    return new Promise(function (resolve, reject) {
      if (!fc_token)
        reject({code: 400, messages: ['missing_parameter', '"fc_token" is required']});
      request
        .post({
            url: 'https://fcp.integ01.dev-franceconnect.fr/api/v1/checktoken',
            body: {token: fc_token},
            json: true
          },
          function (error, response, body) {
            if (error)
              return reject({code: 500, messages: ['internal server error on FranceConnect server side']});
            if (response.statusCode === 401)
              return reject({code: 401, messages: ['unauthorized', '"fc_token" is invalid']});
            if (response.statusCode === 400)
              return reject({code: 400, messages: [body.error.message]});
            if (scope && body.scope.indexOf(scope) < 0)
              return reject({code: 403, messages: ['unauthorized', 'needed scope: "' + scope + '"']});
            if (response.statusCode != 200)
              return reject({code: 400, messages: ['unauthorized', 'unknown FranceConnect error']});
            return resolve(body.identity);
          });
    });
  };

  this.generateHash = function(fcIdentity) {
    const str = _.toLower(fcIdentity.given_name + fcIdentity.family_name + fcIdentity.birthdate + fcIdentity.gender + fcIdentity.birthplace + fcIdentity.birthdepartment + fcIdentity.birthcountry);
    return crypto
      .createHash('sha256')
      .update(str)
      .digest('hex');
  };
};