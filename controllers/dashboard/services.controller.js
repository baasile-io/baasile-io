'use strict';

const request = require('request'),
  serviceModel = require('../../models/v1/service.model.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);

  this.index = function(req, res) {
    return res.render('pages/dashboard/services/index', {
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

  this.view = function(req, res) {
    return res.render('pages/dashboard/services/view', {
      data: req.data,
      flash: {}
    });
  }

  this.edit = function(req, res) {
    return res.render('pages/dashboard/services/edit', {
      csrfToken: req.csrfToken(),
      query: {
        service: req.data.service
      },
      data: req.data,
      flash: {}
    });
  }

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
      name: req.body.service_name,
      nameNormalized: ServiceModel.getNormalizedName(req.body.service_name),
      description: req.body.service_description,
      website: req.body.service_website,
      public: req.body.service_public === 'true',
      users: [{_id: req.data.user._id}],
      secret: ServiceModel.generateSecret()
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
      res.redirect('/dashboard/services/' + service.nameNormalized);
    });
  }

  this.update = function(req, res) {
    const serviceInfo = {
      name: req.body.service_name,
      nameNormalized: ServiceModel.getNormalizedName(req.body.service_name),
      description: req.body.service_description,
      website: req.body.service_website,
      public: req.body.service_public === 'true'
    };
    ServiceModel.io.update({
      _id: req.data.service._id
    }, {
      $set: serviceInfo
    }, function(err, num) {
      if (err || num == 0) {
        let errors;
        if (err.code == 11000)
          err = 'Ce nom de service est déjà utilisé';
        errors = [err];
        return res.render('pages/dashboard/services/edit', {
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
      logger.info('service updated: ' + serviceInfo.name);
      res.redirect('/dashboard/services/' + serviceInfo.nameNormalized);
    });
  }

  this.getServiceData = function(req, res, next) {
    ServiceModel.io.findOne({
      users: {
        $in: [req.session.user._id]
      },
      nameNormalized: req.params.serviceName
    }, function(err, service) {
      if (err || !service)
        return res.status(500).end();
      req.data = req.data || {};
      req.data.service = service;
      next('route');
    });
  }
}
