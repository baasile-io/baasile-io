'use strict';

const request = require('request'),
  _ = require('lodash'),
  routeModel = require('../../models/v1/Route.model.js'),
  relationModel = require('../../models/v1/Relation.model.js'),
  flashHelper = require('../../helpers/flash.helper.js');

module.exports = PagesController;

function PagesController(options) {
  options = options || {};
  const logger = options.logger;
  const RouteModel = new routeModel(options);
  const RelationModel = new relationModel(options);
  const FlashHelper = new flashHelper(options);

  this.index = function(req, res) {
    if (req.data.route.relations.length == 0)
      return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/relations/new');
    return res.render('pages/dashboard/relations/index', {
      page: 'pages/dashboard/relations/index',
      data: req.data,
      csrfToken: req.csrfToken(),
      flash: res._flash
    });
  };

  this.new = function(req, res) {
    return res.render('pages/dashboard/relations/new', {
      page: 'pages/dashboard/relations/new',
      data: req.data,
      csrfToken: req.csrfToken(),
      query: {
        relation: {}
      },
      relationTypes: RelationModel.getTypes(),
      flash: res._flash
    });
  };

  this.create = function(req, res, next) {
    RouteModel.io.findOne({
      routeId: req.body.relation_child_route
    }, function(err, childRoute) {
      if (err)
        return next({code: 500});

      const relationData = {
        type: req.body.relation_type,
        relationId: RelationModel.generateId(),
        parentRoute: req.data.route,
        parentRouteId: req.data.route.routeId,
        childRoute: childRoute ? childRoute._id : null,
        childRouteId: childRoute ? childRoute.routeId : null,
        service: req.data.service,
        clientId: req.data.service.clientId,
        createdAt: new Date(),
        creator: {_id: req.data.user._id}
      };

      RelationModel.io.create(relationData, function (err, relation) {
        if (err) {
          let errors;
          errors = [err];
          return res.render('pages/dashboard/relations/new', {
            page: 'pages/dashboard/relations/new',
            csrfToken: req.csrfToken(),
            data: req.data,
            query: {
              relation: {
                childRouteId: childRoute ? childRoute.routeId : null,
                type: relationData.type
              }
            },
            relationTypes: RelationModel.getTypes(),
            flash: {
              errors: errors
            }
          });
        }
        logger.info('relation created: ' + relation.relationId);
        return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/relations');
      });
    });
  };

  this.update = function(req, res, next) {
    RouteModel.io.findOne({
      routeId: req.body.relation_child_route
    }, function(err, childRoute) {
      if (err)
        return next({code: 500});

      var relation = req.data.relation;
      relation.type = req.body.relation_type;
      relation.childRoute = childRoute ? childRoute._id : null;
      relation.childRouteId = childRoute ? childRoute.routeId : null;

      relation.save(function (err) {
        if (err) {
          let errors;
          errors = [err];
          return res.render('pages/dashboard/relations/edit', {
            page: 'pages/dashboard/relations/edit',
            csrfToken: req.csrfToken(),
            data: req.data,
            query: {
              relation: {
                childRouteId: relation.childRouteId,
                type: relation.type
              }
            },
            relationTypes: RelationModel.getTypes(),
            flash: {
              errors: errors
            }
          });
        }
        logger.info('relation updated: ' + relation.relationId);
        return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/relations');
      });
    });
  };

  this.edit = function(req, res) {
    return res.render('pages/dashboard/relations/edit', {
      page: 'pages/dashboard/relations/edit',
      data: req.data,
      csrfToken: req.csrfToken(),
      query: {
        relation: req.data.relation
      },
      relationTypes: RelationModel.getTypes(),
      flash: res._flash
    });
  };

  this.destroy = function(req, res, next) {
    req.data.relation.remove(function (err) {
      if (err)
        return next({code: 500});
      delete req.data.relation;
      res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/relations');
    });
  };

  this.getRelationData = function(req, res, next) {
    RelationModel.io.findOne({
      service: req.data.service,
      parentRoute: req.data.route,
      relationId: req.params.relationId
    }, function(err, relation) {
      if (err)
        return next({code: 500});
      if (!relation)
        return next({code: 404});
      req.data = req.data || {};
      req.data.relation = relation;
      return next();
    });
  };
};
