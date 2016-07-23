'use strict';

const request = require('request'),
  _ = require('lodash'),
  routeModel = require('../../models/v1/Route.model.js'),
  flashHelper = require('../../helpers/flash.helper.js');

module.exports = RoutesController;

function RoutesController(options) {
  options = options || {};
  const logger = options.logger;
  const RouteModel = new routeModel(options);
  const FlashHelper = new flashHelper(options);

  this.index = function(req, res) {
    RouteModel.io.find({service: req.data.service})
      .sort({createdAt: -1})
      .exec(function(err, routes) {
        if (err)
          next(err);
        return res.render('pages/dashboard/routes/index', {
          page: 'pages/dashboard/routes/index',
          csrfToken: req.csrfToken(),
          data: req.data,
          routes: routes,
          flash: res._flash
        });
      });
  };

  this.new = function(req, res, next) {
    return res.render('pages/dashboard/routes/new', {
      page: 'pages/dashboard/routes/new',
      csrfToken: req.csrfToken(),
      data: req.data,
      query: {
        route: {}
      },
      flash: res._flash
    });
  };

  this.create = function(req, res, next) {
    const routeName = _.trim(req.body.route_name);
    const routeDescription = _.trim(req.body.route_description);
    const routePublic = req.body.route_public === 'true';
    const routeFcRequired = req.body.route_fc_required === 'true';

    const routeData = {
      routeId: RouteModel.generateId(),
      description: routeDescription,
      name: routeName,
      nameNormalized: RouteModel.getNormalizedName(routeName),
      fcRequired: routeFcRequired,
      public: routePublic,
      createdAt: new Date(),
      creator: {_id: req.data.user._id},
      service: req.data.service,
      method: 'GET',
      type: 'DONNEE_PARTAGEE'
    };

    RouteModel.io.create(routeData, function(err, route) {
      logger.info(JSON.stringify(err));
      if (err) {

        return res.render('pages/dashboard/routes/new', {
          page: 'pages/dashboard/routes/new',
          csrfToken: req.csrfToken(),
          data: req.data,
          query: {
            route: {
              name: routeName,
              description: routeDescription,
              public: routePublic,
              fcRequired: routeFcRequired
            }
          },
          flash: {
            errors: [err]
          }
        });
      } else {
        res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes');
      }
    });
  };

  this.edit = function(req, res, next) {
    return res.render('pages/dashboard/routes/edit', {
      page: 'pages/dashboard/routes/edit',
      csrfToken: req.csrfToken(),
      query: {
        route: req.data.route
      },
      data: req.data,
      flash: res._flash
    });
  };

  this.view = function(req, res, next) {
    return res.render('pages/dashboard/routes/view', {
      page: 'pages/dashboard/routes/view',
      csrfToken: req.csrfToken(),
      data: req.data,
      flash: res._flash
    });
  };

  this.update = function(req, res, next) {
    const routeName = _.trim(req.body.route_name);
    const routeDescription = _.trim(req.body.route_description);
    const routePublic = req.body.route_public === 'true';
    const routeFcRequired = req.body.route_fc_required === 'true';

    const routeData = {
      description: routeDescription,
      name: routeName,
      nameNormalized: RouteModel.getNormalizedName(routeName),
      fcRequired: routeFcRequired,
      public: routePublic
    };

    RouteModel.io.update({
      _id: req.data.route._id
    }, {
      $set: routeData
    }, function(err, num) {
      if (err || num == 0) {
        return res.render('pages/dashboard/routes/edit', {
          page: 'pages/dashboard/routes/edit',
          csrfToken: req.csrfToken(),
          data: req.data,
          query: {
            route: routeData
          },
          flash: {
            errors: [err]
          }
        });
      }
      logger.info('route updated: ' + routeData.name);
      FlashHelper.addSuccess(req.session, 'La donnée a bien été mise à jour', function(err) {
        if (err)
          return next({code: 500});
        res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes');
      });
    });
  };


  this.getRouteData = function(req, res, next) {
    RouteModel.io.findOne({
      service: req.data.service,
      nameNormalized: req.params.routeName
    }, function(err, route) {
      if (err)
        return next({code: 500});
      if (!route)
        return next({code: 404});
      req.data = req.data || {};
      req.data.route = route;
      return next();
    });
  };
};
