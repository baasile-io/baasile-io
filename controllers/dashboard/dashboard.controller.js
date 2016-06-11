'use strict';

const request = require('request');

module.exports = DashboardController;

function DashboardController(options) {
  options = options || {};
  const logger = options.logger;

  this.dashboard = function(req, res) {
    return res.render('pages/dashboard', {
      query: {},
      data: req.data,
      flash: {}
    });
  }
}
