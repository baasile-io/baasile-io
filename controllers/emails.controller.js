'use strict';

const request = require('request'),
  emailTokenModel = require('../models/v1/EmailToken.model.js'),
  userModel = require('../models/v1/User.model.js'),
  serviceModel = require('../models/v1/Service.model.js'),
  flashHelper = require('../helpers/flash.helper.js'),
  emailService = require('../services/email.service.js');

module.exports = EmailsController;

function EmailsController(options) {
  options = options || {};
  const logger = options.logger;
  const EmailTokenModel = new emailTokenModel(options);
  const UserModel = new userModel(options);
  const ServiceModel = new serviceModel(options);
  const FlashHelper = new flashHelper(options);
  const EmailService = new emailService(options);

  function doEmailConfirmation(req, res, next) {
    UserModel.io.findOne({email: req.data.token.email}, function(err, user) {
      if (err)
        return next({code: 500});
      if (!user) {
        req.data.token.remove();
        return res.render('pages/errors/error410', {
          page: 'pages/errors/error410',
          layout: 'layouts/error',
          data: req.data,
          flash: {
            errors: ['Le compte développeur associé à ce lien n\'existe plus']
          }
        });
      }
      user.emailConfirmation = true;
      user.save(function(err) {
        if (err)
          return next({code: 500});
        FlashHelper.addSuccess(req.session, ['Votre compte développeur est maintenant actif', 'Vous pouvez vous connecter'], function(err) {
          if (err)
            return next({code: 500});
          req.data.token.remove();
          return res.redirect('/login');
        });
      });
    });
  };

  function doAdminNotificationNewService(req, res, next) {
    ServiceModel.io.findOne({clientId: req.data.token.foreignId}, function(err, service) {
      if (err)
        return next({code: 500});
      if (!service)
        return next({code: 404});
      service.validated = true;
      service.save(function(err) {
        if (err)
          return next({code: 500});
        FlashHelper.addSuccess(req.session, ['Le service a été activé'], function(err) {
          if (err)
            return next({code: 500});
          //req.data.token.remove();
          UserModel.io.findOne({_id: service.creator}, function(err, user) {
            if (err)
              return next({code: 500});
            EmailService.sendServiceValidation(user, service)
              .then(function (result) {
                return res.redirect('/login');
              })
              .catch(next);
          });
        });
      });
    });
  };

  this.get = function(req, res, next) {
    switch(req.data.token.type) {
      case 'email_confirmation':
        return doEmailConfirmation(req, res, next);
        break;
      case 'admin_notification_new_service':
        return doAdminNotificationNewService(req, res, next);
        break;
      default:
        return next({code: 501});
    }
  };

  this.getEmailTokenData = function(req, res, next) {
    EmailTokenModel.io.findOne({
      accessToken: req.params.accessToken
    }, function(err, token) {
      if (err)
        return next({code: 500});
      if (!token) {
        return res.render('pages/errors/error410', {
          page: 'pages/errors/error410',
          layout: 'layouts/error',
          data: req.data,
          flash: {
            errors: ['Ce lien n\'existe plus']
          }
        });
      }
      const now = new Date();
      if (now > token.accessTokenExpiresOn) {
        token.remove();
        return res.render('pages/errors/error410', {
          page: 'pages/errors/error410',
          layout: 'layouts/error',
          data: req.data,
          flash: {
            errors: ['Ce lien a expiré le ' + token.accessTokenExpiresOn.toLocaleString()]
          }
        });
      }
      req.data = req.data || {};
      req.data.token = token;
      return next();
    });
  };
};
