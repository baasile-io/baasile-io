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

  this.sendEmailConfirmation = function(user, apiuri) {
    return new Promise(function(resolve, reject) {
      const type = 'email_confirmation';
      var template = new EmailTemplate(path.join(templatesDir, type));
      const locals = {
        email: user.email,
        firstname: user.firstname,
        lastname: user.lastname
      };
      if (!user || !user.email)
        return reject({code: 500});
      EmailTokenModel.io.remove({
        type: type,
        email: locals.email
      }, function(err) {
        if (err)
          return reject({code: 500});
        const now = new Date();
        var newToken = {
          type: type,
          email: locals.email,
          user: user,
          accessToken: EmailTokenModel.generateToken(),
          accessTokenExpiresOn: new Date(now.getTime() + options.emailTokenExpiration * 60000),
          createdAt: now
        };
        EmailTokenModel.io.create(newToken, function(err, token) {
          if (err)
            return reject({code: 500});
          locals.link = apiuri + '/email/' + token.accessToken;
          template.render(locals, function (err, results) {
            if (err)
              return reject({code: 500, messages: err});
            transport.sendMail({
              from: options.sendgridFrom,
              to: locals.email,
              subject: '[API-CPA] Confirmez votre adresse E-Mail',
              html: results.html,
              text: results.text
            }, function (err, responseStatus) {
              if (err) {
                logger.warn(JSON.stringify(err));
                return reject({code: 503, messages: ['Une erreur est survenue sur le serveur de messagerie lors de l\'envoi du courriel de confirmation', err.response]});
              }
              return resolve({responseStatus: responseStatus, emailToken: token});
            })
          });
        });
      });
    });
  };
};
