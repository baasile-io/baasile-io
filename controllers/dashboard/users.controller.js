'use strict';

const request = require('request'),
  userModel = require('../../models/v1/user.model.js'),
  serviceModel = require('../../models/v1/service.model.js');

module.exports = AccountsController;

function AccountsController(options) {
  options = options || {};
  const logger = options.logger;
  const UserModel = new userModel(options);
  const ServiceModel = new serviceModel(options);

  this.login = function(req, res) {
    if (req.session.user != null) {
      return res.redirect('/dashboard');
    }
    const user_email = req.body.user_email;
    const password = req.body.user_password;

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
      if (errors.length > 0) {
        return res.render('pages/login', {
          layout: 'layouts/login',
          csrfToken: req.csrfToken(),
          query: {
            user: {
              email: user_email
            }
          },
          flash: {
            errors: errors
          }
        });
      }
      req.session.user = user;
      logger.info('user logged in: ' + user.email);
      res.redirect('/dashboard');
    });
  }

  this.subscribe = function(req, res) {
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
      password: hashedPassword
    };

    UserModel.io.create(userInfo, function(err, user) {
      if (err) {
        let errors;
        if (err.code == 11000)
          err = 'Cette adresse E-Mail est déjà utilisée';
        errors = [err];
        return res.render('pages/subscribe', {
          layout: 'layouts/home',
          csrfToken: req.csrfToken(),
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
      logger.info('user created: ' + user.email);
      res.redirect('/login');
    });
  }

  this.logout = function(req, res) {
    req.session.user = null;
    res.redirect('/');
  }

  this.getUserData = function(req, res, next) {
    UserModel.io.findOne({
      email: req.session.user.email
    }, function(err, user) {
      if (err || !user)
        return res.status(500).end();
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
          return res.status(500).end();
        req.data.user.services = services;
        next('route');
      });
    });
  }

}
