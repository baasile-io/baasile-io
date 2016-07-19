'use strict';

module.exports = DashboardController;

function DashboardController(options) {
  options = options || {};
  const logger = options.logger;

  this.dashboard = function(req, res) {
    return res.render('pages/dashboard', {
      page: 'pages/dashboard',
      query: {},
      data: req.data,
      flash: {}
    });
  }
}
