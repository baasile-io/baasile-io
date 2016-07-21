'use strict';

const serviceModel = require('../../../models/v1/Service.model.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);

  this.getServices = function(req, res, next) {
    ServiceModel.io.aggregate([
      {
        $match: {public: true}
      },
      {
        $project: {
          _id: 0,
          id: "$clientId",
          type: {
            $concat: ["service"]
          },
          attributes: {
            nom: "$name",
            description: "$description",
            site_internet: "$website"
          }
        }
      }
    ], function(err, services) {
      if (err)
        return next({code: 500, messages: err});
      return next({code: 200, data: services});
    });
  };
};
