'use strict';

const request = require('request'),
  userModel = require('../../models/v1/user.model.js'),
  crypto = require('crypto');

module.exports = AccountController;

function AccountController(options) {
  options = options || {};
  const logger = options.logger;
  const UserModel = new userModel(options);

  function sha256(str) {
    return crypto.createHash('sha256').update(str).digest('hex');
  }

  function generateSalt()
  {
    const set = '0123456789abcdefghijklmnopqurstuvwxyzABCDEFGHIJKLMNOPQURSTUVWXYZ';
    var salt = '';
    for (var i = 0; i < 10; i++) {
      let p = Math.floor(Math.random() * set.length);
      salt += set[p];
    }
    return salt;
  }

  function saltAndHash(pass)
  {
    const salt = generateSalt();
    return (salt + sha256(pass + salt));
  }

  function validatePassword(plainPass, hashedPass, callback)
  {
    const salt = hashedPass.substr(0, 10);
    const validHash = salt + sha256(plainPass + salt);
    return (hashedPass === validHash);
  }

  this.login = function(req, res) {
    if (req.session.user != null) {
      return res.redirect('/dashboard');
    }
    const email = req.body.email;
    const password = req.body.password;

    // check form fields here

    UserModel.data().findOne({
      email: email
    }, function(err, user) {
      if (err) {
        throw err;
      }
      if (!validatePassword(password, user.password)) {
        return res.redirect('/login');
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
    const email = req.body.email;
    const hashedPassword = saltAndHash(req.body.password);

    // check form fields here

    UserModel.data().create({
      email: email,
      password: hashedPassword
    }, function(err, user) {
      if (err) {
        throw err;
      }
      logger.info('user created: ' + user.email);
      res.redirect('/login');
    });
  }

  this.logout = function(req, res) {
    req.session.user = null;
    res.redirect('/');
  }
}
