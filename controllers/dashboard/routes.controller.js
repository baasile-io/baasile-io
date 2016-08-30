'use strict';

const request = require('request'),
  _ = require('lodash'),
  routeModel = require('../../models/v1/Route.model.js'),
  fieldModel = require('../../models/v1/Field.model.js'),
  relationModel = require('../../models/v1/Relation.model.js'),
  dataModel = require('../../models/v1/Data.model.js'),
  flashHelper = require('../../helpers/flash.helper.js');

module.exports = RoutesController;

function RoutesController(options) {
  options = options || {};
  const logger = options.logger;
  const RouteModel = new routeModel(options);
  const FieldModel = new fieldModel(options);
  const DataModel = new dataModel(options);
  const RelationModel = new relationModel(options);
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
    const routeFcRestricted = req.body.route_fc_restricted === 'true';
    const routeFcRequired = routeFcRestricted ? true : req.body.route_fc_required === 'true';
    const routeCollection = req.body.route_collection === 'true';

    const routeData = {
      routeId: RouteModel.generateId(),
      description: routeDescription,
      name: routeName,
      nameNormalized: RouteModel.getNormalizedName(routeName),
      fcRequired: routeFcRequired,
      fcRestricted: routeFcRestricted,
      isCollection: routeCollection,
      public: routePublic,
      createdAt: new Date(),
      creator: {_id: req.data.user._id},
      service: req.data.service,
      clientId: req.data.service.clientId,
      method: 'POST',
      type: 'DONNEE_PARTAGEE'
    };

    RouteModel.io.create(routeData, function(err, route) {
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
              fcRequired: routeFcRequired,
              fcRestricted: routeFcRestricted,
              isCollection: routeCollection
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
    DataModel.io.aggregate([
      {
        $match: {
          route: req.data.route._id
        }
      },
      {
        $group: {
          _id: null,
          count: {$sum: 1}
        }
      }
    ], function(err, result) {
      if (err)
        return self.destroy(err);
      return res.render('pages/dashboard/routes/view', {
        page: 'pages/dashboard/routes/view',
        csrfToken: req.csrfToken(),
        data: req.data,
        dataCount: result.length > 0 ? result[0].count : 0,
        flash: res._flash
      });
    });
  };

  this.update = function(req, res, next) {
    const routeName = _.trim(req.body.route_name);
    const routeNameNormalized = RouteModel.getNormalizedName(routeName);
    const routeDescription = _.trim(req.body.route_description);
    const routePublic = req.body.route_public === 'true';
    const routeFcRestricted = req.body.route_fc_restricted === 'true';
    const routeFcRequired = routeFcRestricted ? true : req.body.route_fc_required === 'true';
    const routeCollection = req.body.route_collection === 'true';

    const routeData = {
      description: routeDescription,
      name: routeName,
      nameNormalized: routeNameNormalized,
      fcRequired: routeFcRequired,
      fcRestricted: routeFcRestricted,
      public: routePublic,
      isCollection: routeCollection
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
        res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + routeNameNormalized);
      });
    });
  };

  this.drop = function(req, res, next) {
    DataModel.io.remove({
      service: req.data.service._id,
      route: req.data.route._id
    }, function(err) {
      if (err)
        return next({code: 500});
      res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized);
    });
  };

  this.remove = function(req, res, next) {
    DataModel.io.remove({
      service: req.data.service._id,
      route: req.data.route._id
    }, function (err) {
      if (err)
        return next({code: 500});
      FieldModel.io.remove({
        route: req.data.route._id
      }, function (err) {
        if (err)
          return next({code: 500});
        RelationModel.io.remove({
          $or: [
            {parentRouteId: req.data.route.routeId},
            {childRouteId: req.data.route.routeId}
          ]
        }, function (err) {
          if (err)
            return next({code: 500});
          req.data.route.remove(function(err) {
            if (err)
              return next({code: 500});
            res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/');
          });
        })
      });
    });
  };

  this.getServiceRoutes = function(req, res, next) {
    RouteModel.io.find({
      service: req.data.service
    }, function(err, routes) {
      if (err)
        return next({code: 500});
      if (!routes)
        routes = [];
      req.data = req.data || {};
      req.data.serviceRoutes = routes;
      return next();
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
      FieldModel.io.find({route: route})
        .sort({order: 1})
        .exec(function(err, fields) {
          if (err)
            return next({code: 500});
          req.data.route.fields = fields;
          req.data.route.relations = [];
          RelationModel.io
            .find({parentRouteId: route.routeId})
            .stream()
            .on('data', function(relation) {
              var self = this;
              self.pause();
              RouteModel.io.findOne({_id: relation.childRoute}, function(err, childRouteObj) {
                if (err)
                  return self.destroy();
                req.data.route.relations.push({
                  _id: relation._id,
                  childRoute: childRouteObj,
                  childRouteId: childRouteObj.routeId,
                  updatedAt: relation.updatedAt,
                  createdAt: relation.createdAt,
                  completeType: relation.completeType,
                  relationId: relation.relationId
                });
                self.resume();
              });
            })
            .on('error', function(err) {
              return next({code: 500});
            })
            .on('end', function() {
              logger.info('----------------');
              logger.info(req.data.route.relations);
              return next();
            });
        });
    });
  };
};
