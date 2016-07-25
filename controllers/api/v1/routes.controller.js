'use strict';

const _ = require('lodash'),
  serviceModel = require('../../../models/v1/Service.model.js'),
  routeModel = require('../../../models/v1/Route.model.js'),
  fieldModel = require('../../../models/v1/Field.model.js'),
  dataModel = require('../../../models/v1/Data.model.js'),
  franceConnectHelper = require('../../../helpers/fc.helper.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);
  const RouteModel = new routeModel(options);
  const FieldModel = new fieldModel(options);
  const DataModel = new dataModel(options);
  const FranceConnectHelper = new franceConnectHelper(options);

  this.getSharedRoutes = function(req, res, next) {
    var routes = [];
    RouteModel.io.find({
      service: req.data.service._id,
      public: true
    })
      .sort({name: 1})
      .stream()
      .on('data', function(element) {
        var self = this;
        self.pause();
        var elementData = {
          id: element.routeId,
          type: 'donnees',
          attributes: {
            alias: element.nameNormalized,
            nom: element.name,
            description: element.description,
            jeton_france_connect: element.fcRequired
          }
        };
        FieldModel.io.aggregate([
          {
            $match: {
              route: element._id
            }
          },
          {
            $project: {
              _id: 0,
              id: "$fieldId",
              type: {
                $concat: ["champs"]
              }
            }
          }
        ], function(err, fields) {
          if (err)
            return self.destroy(err);
          if (fields && fields.length > 0) {
            elementData.relationships = {
              champs: {
                links: {
                  self: res._apiuri + '/services/' + req.data.service.clientId + '/relationships/donnees/' + element.routeId + '/relationships/champs',
                  related: res._apiuri + '/services/' + req.data.service.clientId + '/donnees/' + element.routeId + '/champs'
                },
                data: fields
              }
            }
          }
          routes.push(elementData);
          self.resume();
        });
      })
      .on('error', function(err) {
        next({code: 500});
      })
      .on('end', function() {
        next({code: 200, data: routes});
      });
  };

  this.processRequest = function(req, res, next) {
    if (req.data.route.method == 'GET' && req.method != 'GET')
      return next({code: 404, messages: ['Méthode "' + req.method + '" non reconnue sur cette donnée']});
    if (req.data.route.fcRequired) {
      FranceConnectHelper
        .checkToken(res._request.params.fc_token, '')
        .then(function (fcIdentity) {
          req.data.fcIdentity = fcIdentity;
          requestDispatchMethod(req, res, next);
        })
        .catch(function (err) {
          next(err);
        });
    }
    else
      requestDispatchMethod(req, res, next);
  };

  function requestDispatchMethod(req, res, next) {
    if (req.method == 'GET')
      return requestGet(req, res, next);
    if (req.method == 'POST')
      return requestPost(req, res, next);
    return next({code: 500, messages: ['not_implemented']});
  };

  function requestGet(req, res, next) {
    next({code: 500, messages: ['not_implemented']});
  };

  function requestPost(req, res, next) {
    if (!res._request.params.data)
      return next({code: 400, messages: ['missing parameter \'data\'']});
    if (typeof res._request.params.data != 'object')
      return next({code: 400, messages: ['invalid format for \'data\': \''+ typeof res._request.params.data +'\'', '\'data\' should be JSON']});
    if (!req.data.route.fcRequired && !res._request.params.id)
      return next({code: 400, messages: ['missing parameter \'id\'']});
    var object = {};
    var errors = [];
    var whitelistedFields = [];
    FieldModel.io
      .find({
        route: req.data.route._id
      })
      .exec(function(err, fields) {
        if (err)
          return next({code: 500});
        fields.forEach(function(field) {
          const value = res._request.params.data[field.nameNormalized];
          whitelistedFields.push(field.nameNormalized);
          if (field.required && !value)
            errors.push('required field: \'' + field.nameNormalized + '\'');
          if (value && !FieldModel.isTypeValid(field.type, value)) {
            errors.push('invalid format for field: \'' + field.nameNormalized + '\'');
            errors.push('\'' + field.nameNormalized + '\' should be ' + field.type);
          }
        });
        const unauthorizedFields = _.reduce(res._request.params.data, function(result, val, key) {
          if (_.indexOf(whitelistedFields, key) == -1)
            result.push(key);
          return result;
        }, []);
        unauthorizedFields.forEach(function(name) {
          errors.push('unauthorized field: \'' + name + '\'');
        });
        if (errors.length > 0)
          return next({code: 400, messages: errors});
        const condition = {
          service: req.data.service._id,
          route: req.data.route._id
        };
        if (req.data.route.fcRequired)
          condition.fcIdentity = FranceConnectHelper.generateHash(req.data.fcIdentity);
        else
          condition.dataId = res._request.params.id;
        DataModel.io.findOne(condition, function(err, data) {
          if (err)
            return next({code: 500});
          if (data) {
            data.update({
              data: res._request.params.data
            }, function (err) {
              if (err)
                return next({code: 500});
              next({code: 200, data: {
                id: data.dataId,
                type: "enregistrements",
                attributes: res._request.params.data
              }});
            });
          }
          else {
            DataModel.io.create({
              dataId: req.data.route.fcRequired ? DataModel.generateId() : res._request.params.id || DataModel.generateId(),
              fcIdentity: req.data.route.fcRequired ? FranceConnectHelper.generateHash(req.data.fcIdentity) : null,
              data: res._request.params.data,
              service: req.data.service._id,
              route: req.data.route._id,
              createdAt: new Date()
            }, function (err, data) {
              if (err)
                return next({code: 500, messages: err});
              next({code: 201, data: {
                id: data.dataId,
                type: "enregistrements",
                attributes: data.data
              }});
            });
          }
        });
      });
  };

  this.getRouteData = function(req, res, next) {
    RouteModel.io.findOne({
      public: true,
      $or: [
        {nameNormalized: req.params.routeId},
        {routeId: req.params.routeId}
      ]
    }, function(err, route) {
      if (err)
        return next({code: 500, messages: err});
      if (!route)
        return next({code: 404, messages: 'Donnée non trouvée'});
      req.data = req.data || {};
      req.data.route = route;
      return next();
    });
  };
};
