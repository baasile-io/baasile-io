'use strict';

const _ = require('lodash'),
  flashHelper = require('../helpers/flash.helper.js');

module.exports = HomesController;

function HomesController(options) {
  options = options || {};
  const logger = options.logger;
  const RouteModel = options.models.RouteModel;
  const ServiceModel = options.models.ServiceModel;
  const FlashHelper = new flashHelper(options);

  this.services = function(req, res, next) {
    var services = [];
    ServiceModel
      .io
      .find({public: true})
      .sort({createdAt: -1})
      .populate({
        path: 'routes',
        model: RouteModel.io,
        match: {public: true}
      })
      .exec(function(err, services) {
        if (err)
          return next({code: 500});
        res.render('pages/services', {
          layout: 'layouts/home',
          page: 'pages/services',
          data: req.data,
          services: services,
          flash: res._flash,
          apiUri: res._apiuri
        });
      });
  };
};