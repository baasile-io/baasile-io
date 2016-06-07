'use strict';

const request = require('request'),
  StandardError = require('standard-error'),
  _ = require('lodash'),
  apirService = require('../../services/apir.service.js'),
  idpToNirService = require('../../services/idpToNir.service.js');

module.exports = FcController;

function FcController(options) {
  options = options || {};
  const logger = options.logger;
  const ApirService = new apirService(options);
  const IdpToNirService = new idpToNirService(options);

  //this.getChomage = get("chomage", "CPA_chomage");
  //this.getRetraite = get("retraite", "CPA_retraite");
  //this.getPenibilite = get("penibilite", "CPA_penibilite");

  this.getFormation = get("formation", "CPA_formation");

  function fcCheckToken(token, scope) {
    return new Promise(function(resolve, reject) {
      request
        .post({
            url: 'https://fcp.integ01.dev-franceconnect.fr/api/v1/checktoken',
            body: {token: token},
            json: true
          },
          function (error, response, body) {
            if (error) {
              return reject(new StandardError("An error has occured when connecting to FC", {code: 500}));
            }
            if (response.statusCode === 401) {
              return reject(new StandardError(body.error.message, {code: 401}));
            }
            if (response.statusCode === 400) {
              return reject(new StandardError(body.error.message, {code: 400}));
            }
            if (scope && body.scope.indexOf(scope) < 0) {
              const msg = "needed scope (" + scope + ") is not in" + JSON.stringify(body.scope);
              return reject(new StandardError(msg, {code: 403}));
            }
            return resolve(body.identity);
          });
    });
  }

  function get(name, scope) {
    return function(req, res, next) {
      var startOfNir;
      var identity;
      fcCheckToken(req.query.token, scope)
        .then(function(identityChecked) {
          identity = identityChecked;
          startOfNir = IdpToNirService.process(identity);
          if (!startOfNir) {
            return next(new StandardError("invalid identité pivot" , {code: 401}));
          }
          if (req.query.devMode === "WITH_ENDOFNIR") {
            if (req.query.endOfNir) {
              return ApirServiceInstance.putEndOfNir(identity, req.query.endOfNir);
            }
            else {
              return ApirServiceInstance.getEndOfNir(identity);
            }
          }
          else {
            return new Promise(function(resolve) {
              resolve(null);
            });
          }
        })
        .then(function(endOfNir) {
          const nir = startOfNir + endOfNir;

          // call the mocked FD here
          // URL is available in defaults.json -> options.apicdcHost

          return res.json('data temporary unavailable');
        })
        .catch(function(err) {
          return next(err);
        });
    }
  }
}
