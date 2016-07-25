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
          type: 'collections',
          attributes: {
            alias: element.nameNormalized,
            nom: element.name,
            description: element.description,
            jeton_france_connect_lecture_ectriture: element.fcRestricted,
            jeton_france_connect_lecture: element.fcRequired
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
                  self: res._apiuri + '/services/' + req.data.service.clientId + '/relationships/collections/' + element.routeId + '/relationships/champs',
                  related: res._apiuri + '/services/' + req.data.service.clientId + '/collections/' + element.routeId + '/champs'
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
      return next({code: 404, messages: ['Méthode "' + req.method + '" non reconnue sur cette collection']});
    if (req.data.route.fcRestricted || (req.data.route.fcRequired && res._request.params.fc_token)) {
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
      return next({code: 400, messages: ['missing_parameter', '"data" is required']});
    if ((req.data.route.fcRestricted || (req.data.route.fcRequired && req.data.fcIdentity)) && Array.isArray(res._request.params.data))
      return next({code: 400, messages: ['invalid_format', 'cannot update multiple objects when specifying "fc_token"']});
    if (!Array.isArray(res._request.params.data))
      res._request.params.data = [res._request.params.data];

    const length = res._request.params.data.length;
    var objects = [];
    var createdCount = 0;

    var whitelistedFields = [];
    FieldModel.io
      .find({
        route: req.data.route._id
      })
      .exec(function(err, fields) {
        if (err)
          return next({code: 500});

        fields.forEach(function(field) {
          whitelistedFields.push(field.nameNormalized);
        });

        let errors = [];
        res._request.params.data.forEach(function(data, i) {
          if (typeof data != 'object')
            errors.push('invalid_format', '"data" must be a JSON object or a collection of JSON objects', 'error on index: ');
          if (!data.type)
            errors.push('missing_parameter', '"type" is required for each JSON object', 'error on index: ' + i);
          if (data.type != 'donnees')
            errors.push('invalid_paramater', '"type" must be equal to "donnees"', 'error on index: ' + i);
          if (!data.attributes)
            errors.push('missing_parameter', '"attributes" is required for each JSON object', 'error on index: ' + i);
          if (typeof data.attributes != 'object')
            errors.push('invalid_format', '"attributes" must be a JSON object', 'error on index: ' + i);
          if ((req.data.route.fcRestricted || req.data.route.fcRequired) && !req.data.fcIdentity && !data.id)
            errors.push('missing_parameter', 'context: "fc_token" not specified', '"id" is required for each JSON object', 'error on index: ' + i);
          if ((req.data.route.fcRestricted || req.data.route.fcRequired) && req.data.fcIdentity && data.id)
            errors.push('unauthorized_parameter', 'context: "fc_token" specified', '"id" must be not specified', 'error on index: ' + i);
          if (!req.data.route.fcRestricted && !req.data.route.fcRequired && !data.id)
            errors.push('missing_parameter', 'context: "fc_token" not specified', '"id" is required for each JSON object', 'error on index: ' + i);

          fields.forEach(function(field) {
            let value = data.attributes[field.nameNormalized];
            if (field.required && !value) {
              errors.push('missing_parameter');
              errors.push('"' + field.nameNormalized + '" is required');
            }
            if (value && !FieldModel.isTypeValid(field.type, value)) {
              errors.push('invalid_format');
              errors.push('"' + field.nameNormalized + '" must be ' + field.type);
            }
          });
          let unauthorizedFields = _.reduce(data.attributes, function(result, val, key) {
            if (_.indexOf(whitelistedFields, key) == -1)
              result.push(key);
            return result;
          }, []);
          if (unauthorizedFields.length > 0) {
            unauthorizedFields.forEach(function (name) {
              errors.push('unauthorized_paramater'),
                errors.push('"' + name + '" is not a valid parameter');
            });
          }
        });
        if (errors.length > 0) {
          return next({code: 400, messages: errors});
        }

        requestPostElement(0, fields);
      });

    function requestPostElement(i, fields) {
      if (i == length) {
        return next({
          code: createdCount > 0 ? 201 : 200,
          data: objects.length == 0 ? objects[0] : objects
        });
      }
      let condition = {
        service: req.data.service._id,
        route: req.data.route._id
      };
      if (req.data.route.fcRestricted || (req.data.route.fcRequired && req.data.fcIdentity))
        condition.dataId = FranceConnectHelper.generateHash(req.data.fcIdentity);
      else
        condition.dataId = res._request.params.data[i].id;
      DataModel.io.findOne(condition, function(err, data) {
        if (err)
          return next({code: 500});
        if (data) {
          data.update({
            data: res._request.params.data[i].attributes
          }, function (err) {
            if (err)
              return next({code: 500});
            objects.push({
              id: data.dataId,
              type: 'donnees',
              attributes: res._request.params.data[i].attributes
            });
            return requestPostElement(i + 1, fields);
          });
        }
        else {
          DataModel.io.create({
            dataId: req.data.route.fcRestricted || (req.data.route.fcRequired && req.data.fcIdentity) ? FranceConnectHelper.generateHash(req.data.fcIdentity) : res._request.params.data[i].id || DataModel.generateId(),
            data: res._request.params.data,
            service: req.data.service._id,
            route: req.data.route._id,
            createdAt: new Date()
          }, function (err, data) {
            if (err)
              return next({code: 500, messages: err});
            objects.push({
              id: data.dataId,
              type: 'donnees',
              attributes: res._request.params.data[i].attributes
            });
            createdCount++;
            return requestPostElement(i + 1, fields);
          });
        }
      });
    };
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
