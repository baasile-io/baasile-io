'use strict';

const request = require('request'),
  serviceModel = require('../../models/v1/Service.model.js'),
  tokenModel = require('../../models/v1/Token.model.js'),
  userModel = require('../../models/v1/User.model.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);
  const TokenModel = new tokenModel(options);
  const UserModel = new userModel(options);

  this.index = function(req, res) {
    return res.render('pages/dashboard/services/index', {
      page: 'pages/dashboard/services/index',
      data: req.data,
      flash: {}
    });
  };

  this.view = function(req, res) {
    TokenModel.io.count({
      service: req.data.service
    }, function(err, result) {
      if (err)
        return res.status(500).end();
      return res.render('pages/dashboard/services/view', {
        page: 'pages/dashboard/services/view',
        data: req.data,
        tokensCount: result,
        flash: {}
      });
    });
  };

  this.edit = function(req, res) {
    return res.render('pages/dashboard/services/edit', {
      page: 'pages/dashboard/services/edit',
      csrfToken: req.csrfToken(),
      query: {
        service: req.data.service
      },
      data: req.data,
      flash: {}
    });
  };

  this.new = function(req, res) {
    return res.render('pages/dashboard/services/new', {
      page: 'pages/dashboard/services/new',
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
  };

  this.users = function(req, res) {
    UserModel.io.find({
      _id: {$in: req.data.service.users}
    }, function(err, users) {
      if (err)
        res.status(500).end();
      return res.render('pages/dashboard/services/users', {
        page: 'pages/dashboard/services/users',
        data: req.data,
        csrfToken: req.csrfToken(),
        users: users,
        flash: {}
      });
    });
  };

  this.create = function(req, res) {
    const serviceInfo = {
      name: req.body.service_name,
      nameNormalized: ServiceModel.getNormalizedName(req.body.service_name),
      description: req.body.service_description,
      website: req.body.service_website,
      public: req.body.service_public === 'true',
      users: [{_id: req.data.user._id}],
      clientSecret: ServiceModel.generateSecret(),
      clientId: ServiceModel.generateId()
    };

    ServiceModel.io.create(serviceInfo, function(err, service) {
      if (err) {
        let errors;
        if (err.code == 11000)
          err = 'Ce nom de service est déjà utilisé';
        errors = [err];
        return res.render('pages/dashboard/services/new', {
          page: 'pages/dashboard/services/new',
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
  };

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
          page: 'pages/dashboard/services/edit',
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
  };

  this.getServiceData = function(req, res, next) {
    ServiceModel.io.findOne({
      users: {
        $in: [req.session.user._id]
      },
      nameNormalized: req.params.serviceName
    }, function(err, service) {
      if (err)
        return res.status(500).end();
      if (!service)
        return res.status(401).end();
      req.data = req.data || {};
      req.data.service = service;
      return next();
    });
  };
};
