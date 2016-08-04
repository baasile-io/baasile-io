'use strict';

const path = require('path'),
  EmailTemplate = require('email-templates').EmailTemplate,
  nodemailer = require('nodemailer'),
  emailTokenModel = require('../models/v1/EmailToken.model.js');

module.exports = EmailService;

function EmailService(options) {
  options = options || {};
  const logger = options.logger;
  const EmailTokenModel = new emailTokenModel(options);
  const templatesDir = path.resolve(__dirname, '..', 'views', 'emails');
  const transport = nodemailer.createTransport({
    service: 'sendgrid',
    auth: {
      user: options.sendgridUsername,
      pass: options.sendgridPassword
    }
  });

  function send(type, locals, to) {
    return new Promise(function(resolve, reject) {
      const template = new EmailTemplate(path.join(templatesDir, type));
      template.render(locals, function (err, results) {
        if (err)
          return reject({code: 500});
        transport.sendMail({
          from: options.sendgridFrom,
          to: to,
          html: results.html,
          text: results.text
        }, function (err, responseStatus) {
          if (err) {
            logger.warn(JSON.stringify(err));
            return reject({
              code: 503,
              messages: ['Une erreur est survenue sur le serveur de messagerie lors de l\'envoi du courriel de confirmation', err.response]
            });
          }
          return resolve({responseStatus: responseStatus});
        })
      });
    });
  };

  function generateEmailToken(type, email, unique, user) {
    return new Promise(function(resolve, reject) {
      const now = new Date();
      var newToken = {
        type: type,
        email: email,
        user: user,
        accessToken: EmailTokenModel.generateToken(),
        accessTokenExpiresOn: new Date(now.getTime() + options.emailTokenExpiration * 480000),
        createdAt: now
      };
      if (unique) {
        EmailTokenModel.io.remove({
          type: type,
          email: email
        }, function (err) {
          if (err)
            return reject({code: 500});
          EmailTokenModel.io.create(newToken, function (err, token) {
            if (err)
              return reject({code: 500});
            resolve(token);
          });
        });
      } else {
        EmailTokenModel.io.create(newToken, function (err, token) {
          if (err)
            return reject({code: 500});
          resolve(token);
        });
      }
    });
  };

  this.sendEmailConfirmation = function(user, apiuri) {
    return new Promise(function(resolve, reject) {
      if (!user || !user.email)
        return reject({code: 500});
      const type = 'email_confirmation';
      const locals = {
        email: user.email,
        firstname: user.firstname,
        lastname: user.lastname
      };
      generateEmailToken(type, user.email, true, user)
        .then(function(token) {
          locals.link = apiuri + '/email/' + token.accessToken;
          send(type, locals, user.email)
            .then(function(result) {
              result.emailToken = token;
              return resolve(result);
            })
            .catch(function(result) {
              result.emailToken = token;
              return reject(result);
            });
        })
        .catch(function(result) {
          reject(result);
        });
    });
  };
  
  this.sendAdminNotificationsNewService = function(user, service, apiuri) {
    return new Promise(function(resolve, reject) {
      const type = 'admin_notification_new_service';
      const locals = {
        user: user.firstname + ' ' + user.lastname,
        email: user.email,
        name: service.name,
        website: service.website,
        description: service.description
      };
      generateEmailToken(type, options.adminNotificationEmail, false)
        .then(function(token) {
          locals.link = apiuri + '/validate_service/' + token.accessToken;
          send(type, locals, options.adminNotificationEmail)
            .then(function(result) {
              return resolve(result);
            })
            .catch(function(result) {
              return reject(result);
            });
        })
        .catch(function(result) {
          reject(result);
        });
    });
  };
};
