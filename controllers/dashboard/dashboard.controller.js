'use strict';

const request = require('request');

module.exports = AccountController;

function AccountController(options) {
  options = options || {};
  const logger = options.logger;

  this.dashboard = function(req, res) {
    return res.render('pages/dashboard', {
      csrfToken: req.csrfToken(),
      query: {},
      data: req.data,
      flash: {}
    });
  }
}
