'use strict';

const request = require('request'),
  tokenModel = require('../../models/v1/Token.model.js'),
  flashHelper = require('../../helpers/flash.helper.js');

module.exports = TokensController;

function TokensController(options) {
  options = options || {};
  const logger = options.logger;
  const TokenModel = new tokenModel(options);
  const FlashHelper = new flashHelper(options);

  this.index = function(req, res, next) {
    TokenModel.io.find({service: req.data.service})
      .sort({createdAt: -1})
      .exec(function(err, tokens) {
        if (err)
          return next(err);
        return res.render('pages/dashboard/tokens/index', {
          page: 'pages/dashboard/tokens/index',
          csrfToken: req.csrfToken(),
          data: req.data,
          tokens: tokens,
          now: new Date(),
          flash: res._flash
        });
      });
  };

  this.destroy = function(req, res) {
    req.data.token.remove(function(err) {
      if (err)
        return res.status(500).end();
      return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/tokens');
    });
  };

  this.revoke = function(req, res) {
    req.data.token.update({
      accessTokenExpiresOn: new Date()
    }, function(err) {
      if (err)
        return res.status(500).end();
      return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/tokens');
    });
  };

  this.generateTokenFromDashboard = function(req, res) {
    request
      .post({
          url: 'http://localhost:' + options.address.port + '/api/oauth/token',
          body: {
            client_secret: req.data.service.clientSecret,
            client_id: req.data.service.clientId
          },
          json: true,
          headers: {
            'Content-Type': 'application/vnd.api+json',
            'Accept': 'application/vnd.api+json'
          }
        },
        function (error, response, body) {
          if (response.statusCode == 200) {
            return FlashHelper.addSuccess(req.session, {title: 'Le jeton a bien été créé', messages: [body.data.attributes.access_token, 'Date d\'expiration: ' + body.data.attributes.expires_on]}, function (err) {
              if (err)
                return res.status(500).end();
              return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/tokens');
            });
          }
          FlashHelper.addError(req.session, body.errors, function(err) {
            if (err)
              return res.status(500).end();
            return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/tokens');
          });
        });
  };

  this.gotoIndex = function(req, res, next) {
    return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/tokens');
  };

  this.getTokenData = function(req, res, next) {
    TokenModel.io.findOne({
      service: req.data.service,
      accessToken: req.params.accessToken
    }, function(err, token) {
      if (err)
        return res.status(500).end();
      if (!token)
        return res.status(401).end();
      req.data = req.data || {};
      req.data.token = token;
      return next();
    });
  };
};
