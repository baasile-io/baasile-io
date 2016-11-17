'use strict';

const request = require('request'),
  _ = require('lodash'),
  flashHelper = require('../../helpers/flash.helper.js'),
  emailService = require('../../services/email.service.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = options.models.ServiceModel;
  const TokenModel = options.models.TokenModel;
  const UserModel = options.models.UserModel;
  const FlashHelper = new flashHelper(options);
  const EmailService = new emailService(options);
  const ThumbnailService = options.services.ThumbnailService;

  this.index = function(req, res) {
    ServiceModel.io.find({
      users: {
        $in: [req.session.user._id]
      }
    }, function(err, services) {
      if (err)
        return res.status(500).end();
      return res.render('pages/dashboard/services/index', {
        page: 'pages/dashboard/services/index',
        data: req.data,
        services: services,
        flash: res._flash
      });
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
        flash: res._flash,
        apiUriList: req.data.service.getApiUriList(res._apiuri)
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
      flash: res._flash
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
          public: false,
          validated: false
        }
      },
      data: req.data,
      flash: res._flash
    });
  };

  this.users = function(req, res) {
    UserModel.io.find({
      _id: {$in: req.data.service.users}
    }, function(err, users) {
      if (err)
        res.status(500).end();
      return res.render('pages/dashboard/users/index', {
        page: 'pages/dashboard/users/index',
        data: req.data,
        csrfToken: req.csrfToken(),
        users: users,
        query: {
          user_email: ""
        },
        flash: res._flash
      });
    });
  };

  this.inviteUser = function(req, res) {
    const userEmail = _.trim(req.body.user_email);
    UserModel.io.findOne({
      email: userEmail
    }, function(err, user) {
      var errors = [];
      if (err)
        res.status(500).end();
      if (!user)
        errors.push('Aucun utilisateur ne correspond à cet E-Mail');
      else {
        if (user.email == req.data.user.email)
          errors.push('Vous ne pouvez pas vous inviter vous-même !');
        if (_.find(req.data.service.users, function(o) { return o == user.id }))
          errors.push('Cet utilisateur est déjà associé à ce service');
      }
      UserModel.io.find({
        _id: {$in: req.data.service.users}
      }, function(err, users) {
        if (err)
          res.status(500).end();
        if (errors.length == 0) {
          FlashHelper.addSuccess(req.session, 'L\'utilisateur a bien été ajouté', function(err) {
            if (err)
              return res.status(500).end();
            req.data.service.users.push(user);
            req.data.service.save(function (err) {
              if (err)
                return res.status(500).json(err).end();
              return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/users');
            });
          });
        } else {
          return res.render('pages/dashboard/users/index', {
            page: 'pages/dashboard/users/index',
            csrfToken: req.csrfToken(),
            data: req.data,
            users: users,
            query: {
              user_email: req.body.user_email
            },
            flash: {
              errors: errors
            }
          });
        }
      });
    });
  };

  this.revokeUser = function(req, res, next) {
    const userEmail = req.params.userEmail;
    UserModel.io.findOne({
      email: userEmail
    }, function(err, user) {
      if (err)
        return next({code: 500});
      if (user.id == req.data.service.creator.toString())
        return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/users');
      req.data.service.users = _.filter(req.data.service.users, function(o) { return user.id != o });
      if (req.data.service.users.length == 0)
        return next({code: 500});
      req.data.service.save(function (err) {
        if (err)
          return next({code: 500});
        return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/users');
      });
    });
  };

  this.create = function(req, res) {
    const serviceName = _.trim(req.body.service_name);
    const serviceInfo = {
      name: serviceName,
      description: _.trim(req.body.service_description),
      website: _.trim(req.body.service_website),
      public: req.body.service_public === 'true',
      users: [{_id: req.data.user._id}],
      clientSecret: ServiceModel.generateSecret(),
      clientId: ServiceModel.generateId(),
      createdAt: new Date(),
      creator: {_id: req.data.user._id}
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
              public: serviceInfo.public,
              validated: false
            }
          },
          flash: {
            errors: errors
          }
        });
      }

      function doSuccess() {
        logger.info('service created: ' + service.name);
        EmailService
          .sendAdminNotificationsNewService(req.session.user, service, res._dashboarduri)
          .then(function (result) {
            return res.redirect('/dashboard/services/' + service.nameNormalized);
          })
          .catch(function (result) {
            logger.warn('failed to send admin notification: ' + JSON.stringify(result));
            return res.redirect('/dashboard/services/' + service.nameNormalized);
          });
      }

      if (typeof req.file === 'undefined') {
        req.file = {path: './public/assets/images/no-image.png'};
      }
      ThumbnailService
        .process(req.file, 'services/logos/' + service.clientId)
        .then(function (data) {
          doSuccess();
        })
        .catch(function (err) {
          return FlashHelper.addError(req.session, {icon: 'image', title: 'Erreur de téléchargement', messages: ['L\'image n\'a pas pu être téléchargée sur la plate-forme']}, function(err) {
            if (err)
              return next({code: 500});
            return doSuccess();
          });
        });
    });
  };

  this.update = function(req, res, next) {
    const serviceName = _.trim(req.body.service_name);
    const serviceDescription = _.trim(req.body.service_description);
    const serviceWebsite = _.trim(req.body.service_website);
    const servicePublic = req.body.service_public === 'true';
    req.data.service.name = serviceName;
    req.data.service.description = serviceDescription;
    req.data.service.website = serviceWebsite;
    req.data.service.public = servicePublic;
    req.data.service.save(function(err) {
      if (err) {
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
              name: serviceName,
              description: serviceDescription,
              website: serviceWebsite,
              public: servicePublic,
              validated: req.data.service.validated
            }
          },
          flash: {
            errors: errors
          }
        });
      }

      function doSuccess() {
        logger.info('service updated: ' + serviceName);
        FlashHelper.addSuccess(req.session, 'Le service a bien été mis à jour', function(err) {
          if (err)
            return next({code: 500});
          res.redirect('/dashboard/services/' + req.data.service.nameNormalized);
        });
      };

      if (req.file) {
        ThumbnailService
          .process(req.file, 'services/logos/' + req.data.service.clientId)
          .then(function (data) {
            doSuccess();
          })
          .catch(function (err) {
            return FlashHelper.addError(req.session, {icon: 'image', title: 'Erreur de téléchargement', messages: ['L\'image n\'a pas pu être téléchargée sur la plate-forme']}, function(err) {
              if (err)
                return next({code: 500});
              return doSuccess();
            });
          });
      } else {
        doSuccess();
      }
    });
  };

  this.showClientSecretFromDashboard = function(req, res, next) {
    FlashHelper.addSuccess(req.session, {
      title: 'Voici la clé secrète du service "' + req.data.service.name + '":',
      icon: 'lock',
      messages: [
        req.data.service.clientSecret
      ]
    }, function (err) {
      if (err)
        return next({code: 500});
      var redirect_url = req.body.redirect_url;
      if (!redirect_url || redirect_url == '')
        redirect_url = '/dashboard/services/' + req.data.service.nameNormalized;
      return res.redirect(redirect_url);
    });
  };

  this.showClientIdFromDashboard = function(req, res, next) {
    FlashHelper.addSuccess(req.session, {
      title: 'Voici la clé publique du service "' + req.data.service.name + '":',
      icon: 'lock',
      messages: [
        req.data.service.clientId
      ]
    }, function (err) {
      if (err)
        return next({code: 500});
      var redirect_url = req.body.redirect_url;
      if (!redirect_url || redirect_url == '')
        redirect_url = '/dashboard/services/' + req.data.service.nameNormalized;
      return res.redirect(redirect_url);
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
        return next({code: 500});
      if (!service)
        return next({code: 404});
      req.data = req.data || {};
      req.data.service = service;
      return next();
    });
  };
};
