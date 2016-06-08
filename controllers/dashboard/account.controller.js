'use strict';

const request = require('request'),
  userModel = require('../../models/v1/user.model.js'),
  crypto = require('crypto');

module.exports = AccountController;

function AccountController(options) {
  options = options || {};
  const logger = options.logger;
  const UserModel = new userModel(options);

  this.login = function(req, res) {
    if (req.session.user != null) {
      return res.redirect('/dashboard');
    }

    // check form fields here

    UserModel.find({
      email: req.body.email,
      password: req.body.password
    }, function(err, user) {
      if (err) {
        throw err;
      }
      req.session.user = user;
      logger.info('user logged in: '+user);
      res.redirect('/dashboard');
    });
  }

  this.subscribe = function(req, res) {
    if (req.session.user != null) {
      return res.redirect('/dashboard');
    }

    // check form fields here

    UserModel.create({
      email: req.body.email,
      password: req.body.password
    }, function(err, user) {
      if (err) {
        throw err;
      }
      logger.info('user created: '+user);
      res.redirect('/login');
    });
  }
}
