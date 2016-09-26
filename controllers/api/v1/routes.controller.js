'use strict';

const _ = require('lodash'),
  serviceModel = require('../../../models/v1/Service.model.js'),
  routeModel = require('../../../models/v1/Route.model.js'),
  fieldModel = require('../../../models/v1/Field.model.js'),
  dataModel = require('../../../models/v1/Data.model.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);
  const RouteModel = new routeModel(options);
  const FieldModel = new fieldModel(options);
  const DataModel = new dataModel(options);

  this.getSharedRoutes = function(req, res, next) {
    var routes = [];
    var included = [];
    RouteModel
      .io
      .find({
        '$and': [
          {
            '$or': [
              {public: true},
              {clientId: res._service.clientId}
            ]
          },
          {service: req.data.service._id}
        ]
      })
      .sort({name: 1})
      .cursor()
      .on('data', function(element) {
        var self = this;
        self.pause();
        var elementData = element.getResourceObject(res._apiuri);
        DataModel.io.aggregate([
          {
            $match: {
              route: element._id
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
          elementData.meta = elementData.meta || {};
          elementData.meta.donnees = elementData.meta.donnees || {};
          elementData.meta.donnees.count = result.length > 0 ? result[0].count : 0;
          FieldModel.io.find({
            route: element._id
          }, function(err, fields) {
            if (err)
              return self.destroy(err);
            var dataFields = [];
            if (fields) {
              fields.forEach(function(field) {
                dataFields.push({
                  id: field.fieldId,
                  type: 'champs'
                });
                included.push(field.getResourceObject(res._apiuri));
              });
            }
            elementData.meta.champs = elementData.meta.fields || {};
            elementData.meta.champs.count = fields ? fields.length : 0;
            if (fields && fields.length > 0) {
              elementData.relationships = {
                champs: {
                  links: {
                    self: res._apiuri + '/services/' + req.data.service.clientId + '/relationships/collections/' + element.routeId + '/relationships/champs',
                    related: res._apiuri + '/services/' + req.data.service.clientId + '/collections/' + element.routeId + '/champs'
                  },
                  data: dataFields
                }
              }
            }
            routes.push(elementData);
            self.resume();
          });
        });
      })
      .on('error', function(err) {
        next({code: 500});
      })
      .on('end', function() {
        next({code: 200, data: routes, included: included});
      });
  };

  this.get = function(req, res, next) {
    return next({code: 200, data: req.data.route.getResourceObject(res._apiuri)});
  };

  this.getRouteData = function(req, res, next) {
    RouteModel.io.findOne({
      '$and': [
        {
          '$or': [
            {public: true},
            {clientId: res._service.clientId}
          ]
        },
        {
          '$or': [
            {nameNormalized: req.params.routeId},
            {routeId: req.params.routeId}
          ]
        }
      ]
    }, function(err, route) {
      if (err)
        return next({code: 500});
      if (!route)
        return next({code: 404, messages: ['not_found', '"' + req.params.routeId + '" is invalid']});
      req.data = req.data || {};
      req.data.route = route;
      return next();
    });
  };
};
