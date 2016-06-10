'use strict';

const request = require('request'),
  serviceModel = require('../../models/v1/service.model.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);

  this.new = function(req, res) {
    return res.render('pages/dashboard/services/new', {
      csrfToken: req.csrfToken(),
      query: {
        service: {
          name: '',
          description: '',
          website: '',
          public: false
        }
      },
      data: req.data,
      flash: {}
    });
  }

  this.create = function(req, res) {
    const serviceInfo = {
      name: req.body.name,
      description: req.body.description,
      website: req.body.website,
      public: typeof req.body.public == 'undefined'
    };

    ServiceModel.io.create(serviceInfo, function(err, service) {
      if (err) {
        let errors;
        if (err.code == 11000)
          err = 'Ce nom de service est déjà utilisé';
        errors = [err];
        return res.render('pages/dashboard/services/new', {
          csrfToken: req.csrfToken(),
          data: req.data,
          query: {
            service: {
              name: serviceInfo.name,
              description: serviceInfo.description,
              website: serviceInfo.website,
              public: serviceInfo.public
            }
          },
          flash: {
            errors: errors
          }
        });
      }
      logger.info('service created: ' + service.name);
      res.redirect('/dashboard/services/' + service._id);
    });
  }
}
