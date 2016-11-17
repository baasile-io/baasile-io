'use strict';

const _ = require('lodash'),
  request = require('request'),
  emailService = require('../../services/email.service.js'),
  flashHelper = require('../../helpers/flash.helper.js');

module.exports = AccountsController;

function AccountsController(options) {
  options = options || {};
  const logger = options.logger;
  const UserModel = options.models.UserModel;
  const ServiceModel = options.models.ServiceModel;
  const EmailService = new emailService(options);
  const FlashHelper = new flashHelper(options);

  function sendEmailConfirmation(user, req, res, callback) {
    EmailService
      .sendEmailConfirmation(user, res._serverUri)
      .then(function(result) {
        if (result.responseStatus.accepted.indexOf(user.email) == -1) {
          return FlashHelper.addError(req.session, 'Votre adresse E-Mail a été rejetée par le serveur de messagerie lors de l\'envoi du courriel de confirmation', function (err) {
            if (err)
              return callback({code: 500});
            return callback();
          });
        }
        let firstEmail = /\/subscribe/.test(req.headers.referer);
        console.log(req.headers.referer);
        FlashHelper.addError(req.session, {
          title: firstEmail ? 'Veuillez confirmer votre adresse E-Mail' : 'Votre adresse E-Mail n\'a pas été confirmée',
          icon: 'send',
          messages: [
            firstEmail ? 'Un lien de confirmation vous a été envoyé' : 'Un nouveau lien de confirmation vous a été envoyé',
            'Date d\'expiration du lien : ' + result.emailToken.accessTokenExpiresOn.toLocaleString(),
            'Les liens envoyés précédemment deviennent inactifs'
          ]
        }, function(err) {
          if (err)
            return callback({code: 500});
          logger.info(JSON.stringify(result));
          return callback();
        });
      })
      .catch(function(err) {
        if (err.code === 503) {
          return FlashHelper.addError(req.session, {
            title: 'Votre adresse E-Mail n\'a pas été confirmée',
            icon: 'mail',
            messages: err.messages
          }, function (err) {
            if (err)
              return callback({code: 500});
            return callback();
          });
        }
        return callback({code: 500});
      });
  }

  this.sessionNew = function(req, res) {
    if (req.session.user != null) {
      return res.redirect('/dashboard');
    }
    res.render('pages/users/login', {
      layout: 'layouts/login',
      page: 'pages/users/login',
      csrfToken: req.csrfToken(),
      query: {
        user: {}
      },
      flash: res._flash
    });
  };

  this.sessionCreate = function(req, res, next) {
    if (req.session.user != null) {
      return res.redirect('/dashboard');
    }
    const user_email = req.body.user_email;
    const password = req.body.user_password;

    // This can be used so that the user that logs in automatically gets
    // redirected to the protected they were trying to access before loging
    // in. It may not be set if the user goes straight to the login page.
    var redirect_uri = req.body.redirect_uri || '/dashboard';

    // check form fields here

    UserModel.io.findOne({
      email: user_email
    }, function(err, user) {
      let errors = [];
      if (err)
        errors.push(err);
      else if (!user)
        errors.push('Aucun compte ne correspond à cette adresse E-Mail');
      else if (!UserModel.validatePassword(password, user.password))
        errors.push('Mot de passe invalide');
      else if (!user.emailConfirmation) {
        errors.push('L\'adresse email n\'a pas été confirmée, veuillez consultez vos emails');

        sendEmailConfirmation(user, req, res, function(err) {
          if (err) {
            return next(err);
          }

          logger.info('user created: ' + user.email);
          res.redirect('/login');
        });
        return;
      }

      if (errors.length > 0) {
        return res.render('pages/users/login', {
          layout: 'layouts/login',
          page: 'pages/users/login',
          csrfToken: req.csrfToken(),
          query: {
            user: {
              email: user_email
            },
            redirect_uri: redirect_uri
          },
          flash: {
            errors: errors
          }
        });
      }

      user.lastLoginAt = new Date();
      user.save(function(err) {
        if (err)
          return next({code: 500});

        req.session.user = user;
        req.session.save(function(err) {
          if (err)
            return next({code: 500});

          logger.info('user logged in: ' + user.email);
          return res.redirect(redirect_uri);
        });
      });
    });
  };

  this.view = function(req, res) {
    return res.render('pages/users/view', {
      page: 'pages/users/view',
      query: {},
      data: req.data,
      flash: res._flash
    });
  };

  this.edit = function(req, res) {
    return res.render('pages/users/edit', {
      page: 'pages/users/edit',
      csrfToken: req.csrfToken(),
      query: {
        user: req.data.user
      },
      data: req.data,
      flash: res._flash
    });
  };

  this.passwordReset = function(req, res) {
    return res.render('pages/users/password_reset', {
      page: 'pages/users/password_reset',
      csrfToken: req.csrfToken(),
      data: req.data,
      flash: res._flash
    });
  };

  this.processPasswordReset = function(req, res, next) {
    const redirectUrl = !req.session.user ? '/login' : '/dashboard/account';

    function process(user) {
      EmailService
        .sendPasswordReset(user, res._serverUri)
        .then(function(result) {
          console.log('then');
          if (result.responseStatus.accepted.indexOf(user.email) == -1) {
            return FlashHelper.addError(req.session, 'Votre adresse E-Mail a été rejetée par le serveur de messagerie lors de l\'envoi du courriel de confirmation', function (err) {
              if (err)
                return next({code: 500});
              return res.redirect(redirectUrl).end();
            });
          }
          FlashHelper.addSuccess(req.session, {
            title: 'Réinitialisation du mot de passe',
            icon: 'send',
            messages: [
              'Un lien de réinitialisation de votre mot de passe vous a été envoyé sur votre adresse E-Mail',
              'Date d\'expiration du lien : ' + result.emailToken.accessTokenExpiresOn.toLocaleString(),
              'Les liens envoyés précédemment deviennent inactifs'
            ]
          }, function(err) {
            if (err)
              return next({code: 500});
            logger.info(JSON.stringify(result));
            return res.redirect(redirectUrl);
          });
        })
        .catch(function(err) {
          if (err.code === 503) {
            return FlashHelper.addError(req.session, {
              title: 'Une erreur est survenue',
              icon: 'mail',
              messages: err.messages
            }, function (err) {
              if (err)
                return next({code: 500});
              return res.redirect(redirectUrl);
            });
          }
          return next({code: 500});
        });
    }

    if (typeof req.body.email != 'undefined') {
      UserModel.io.findOne({email: req.body.email}, function(err, user) {
        if (err)
          return next({code: 500});
        if (!user) {
          return FlashHelper.addError(req.session, 'Aucun compte ne correspond à cet E-Mail', function (err) {
            if (err)
              return next({code: 500});
            FlashHelper.addParam(req.session, 'email', req.body.email, function(err) {
              if (err)
                return next({code: 500});
              res.redirect(redirectUrl);
            });
          });
        }
        return process(user);
      });
    } else {
      return process(req.data.user);
    }
  };

  this.new = function(req, res) {
    if (req.session.user != null) {
      return res.redirect('/dashboard');
    }
    res.render('pages/users/new', {
      layout: 'layouts/home',
      page: 'pages/users/new',
      csrfToken: req.csrfToken(),
      data: {},
      query: {
        user: {}
      },
      flash: res._flash
    });
  };

  this.update = function(req, res, next) {
    const userFirstname = _.trim(req.body.user_firstname);
    const userLastname = _.trim(req.body.user_lastname);
    const userEmail = _.trim(req.body.user_email);
    const oldEmail = req.data.user.email;
    req.data.user.firstname = userFirstname;
    req.data.user.lastname = userLastname;
    req.data.user.email = userEmail;
    req.data.user.save(function(err) {
      if (err) {
        let errors;
        errors = [err];
        return res.render('pages/users/edit', {
          page: 'pages/users/edit',
          csrfToken: req.csrfToken(),
          data: req.data,
          query: {
            user: {
              firstname: userFirstname,
              lastname: userLastname,
              email: userEmail
            }
          },
          flash: {
            errors: errors
          }
        });
      }

      logger.info('user updated: ' + userFirstname + ' ' + userLastname);
      var flashMessages = ['Votre compte a bien été mis à jour'];

      function redirect() {
        FlashHelper.addSuccess(req.session, flashMessages, function(err) {
          if (err)
            return next({code: 500});
          res.redirect('/dashboard/account');
        });
      };

      if (userEmail != oldEmail) {
        req.session.user.email = userEmail;
        req.session.save(function(err) {
          if (err) {
            logger.warn('changing user session email failed');
            return next({code: 500});
          }
          req.data.user.emailConfirmation = false;
          req.data.user.save(function(err) {
            if (err) {
              logger.warn('changing user emailConfirmation to false failed');
              return next({code: 500});
            }
            EmailService.sendEmailConfirmation(req.data.user, res._serverUri);
            flashMessages.push('Vous avez modifié votre adresse E-Mail, un lien de validation vous a été envoyé');
            flashMessages.push('Vous ne pourrez plus vous reconnecter au tableau de bord tant que vous n\'aurez pas validé votre nouvelle adresse E-Mail');
            return redirect();
          });
        });
      } else {
        redirect();
      }
    });
  };

  this.create = function(req, res) {
    if (req.session.user != null) {
      return res.redirect('/dashboard');
    }
    const user_firstname = req.body.user_firstname;
    const user_lastname = req.body.user_lastname;
    const user_email = req.body.user_email;
    const hashedPassword = req.body.user_password.length >= 10 ? UserModel.saltAndHash(req.body.user_password) : req.body.user_password;

    const userInfo = {
      firstname: user_firstname,
      lastname: user_lastname,
      email: user_email,
      password: hashedPassword,
      createdAt: new Date()
    };

    UserModel.io.create(userInfo, function(err, user) {
      if (err) {
        let errors = [];
        if (err.code == 11000)
          errors.push('Cette adresse E-Mail est déjà utilisée');
        else
          errors.push(err);
        return res.render('pages/users/new', {
          layout: 'layouts/home',
          page: 'pages/users/new',
          csrfToken: req.csrfToken(),
          data: {},
          query: {
            user: {
              firstname: user_firstname,
              lastname: user_lastname,
              email: user_email
            }
          },
          flash: {
            errors: errors
          }
        });
      }

      sendEmailConfirmation(user, req, res, function(err) {
        if (err) {
          return next(err);
        }

        logger.info('user created: ' + user.email);
        res.redirect('/login');
      });
    });
  };

  this.sessionDestroy = function(req, res) {
    req.session.destroy();
    res.redirect('/');
  };

  this.getUserData = function(req, res, next) {
    UserModel.io.findOne({
      email: req.session.user.email
    }, function(err, user) {
      if (err || !user)
        return next({code: 500});
      req.data = req.data || {};
      req.data.user = user;
      ServiceModel.io.find({
        users: {
          $in: [user._id]
        }
      }, {
        name: true,
        nameNormalized: true
      }, {
        sort: {
          nameNormalized: 'asc'
        }
      }, function(err, services) {
        if (err)
          return next({code: 500});
        req.data.user.services = services;
        next('route');
      });
    });
  };
}
