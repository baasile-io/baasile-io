'use strict';

const request = require('request'),
  StandardError = require('standard-error');

module.exports = FdCdcService;

function FdCdcService(options) {
  options = options || {};
  const logger = options.logger;

  this.getFormation = function(nir)
  {
    return new Promise(function(resolve, reject) {
      request
        .get({
          url: options.apicdcHost + "/titulaires/" + nir
        }, function(err, response, body) {
          if(err) {
            return reject(err);
          }
          /*if (response.statusCode === 400) {
            let error400 = new StandardError("Invalid hash", {code: 400});
            return reject(error400);
          }*/
          if (response.statusCode === 404) {
            let error404 = new StandardError("Unknown tits", {code: 404});
            return reject(error404);
          }
          if (response.statusCode === 500) {
            let error500 = new StandardError("Server error", {code: 500});
            return reject(error500);
          }
          return resolve(JSON.parse(body));
        });
    });
  }
}
