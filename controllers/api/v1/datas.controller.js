'use strict';

const _ = require('lodash'),
  serviceModel = require('../../../models/v1/Service.model.js'),
  routeModel = require('../../../models/v1/Route.model.js'),
  fieldModel = require('../../../models/v1/Field.model.js'),
  dataModel = require('../../../models/v1/Data.model.js'),
  franceConnectHelper = require('../../../helpers/fc.helper.js'),
  filterservice = require('../../../services/filter.service.js');

module.exports = ServicesController;

function ServicesController(options) {
  options = options || {};
  const logger = options.logger;
  const ServiceModel = new serviceModel(options);
  const RouteModel = new routeModel(options);
  const FieldModel = new fieldModel(options);
  const DataModel = new dataModel(options);
  const FranceConnectHelper = new franceConnectHelper(options);
  const FilterService = new filterservice(options);
  
  this.get = function(req, res, next) {
    return next({code: 200, data: req.data.data.getResourceObject(res._apiuri)});
  };
  
  this.getDataData = function(req, res, next) {
    let condition = {
      service: req.data.service._id,
      route: req.data.route._id
    };
    if (req.data.route.fcRestricted || (req.data.route.fcRequired && req.data.fcIdentity))
      condition.dataId = FranceConnectHelper.generateHash(req.data.fcIdentity);
    else
      condition.dataId = req.params.dataId;
    DataModel.io
      .findOne(condition, function(err, data) {
        if (err)
          return next({code: 500});
        if (!data)
          return next({code: 404, messages: ['not_found', '"' + condition.dataId + '" is invalid']});
        req.data = req.data || {};
        req.data.data = data;
        next();
      });
  };
  
  this.destroy = function(req, res, next) {
    req.data.data.remove(function(err) {
      if (err)
        return next({code: 500});
      return next({code: 200});
    });
  };
  
  this.fcAuthorize = function(req, res, next) {
    if (req.data.route.fcRestricted || (req.data.route.fcRequired && (req.data.route.service != res._service._id.toString() || res._request.params.fc_token))) {
      FranceConnectHelper
        .checkToken(res._request.params.fc_token, '')
        .then(function (fcIdentity) {
          req.data.fcIdentity = fcIdentity;
          next();
        })
        .catch(function (err) {
          next(err);
        });
    }
    else
      next();
  };
  
  this.processRequest = function(req, res, next) {
    if (req.data.route.method == 'GET' && req.method != 'GET')
      return next({code: 404, messages: ['Méthode "' + req.method + '" non reconnue sur cette collection']});
    if (req.method == 'GET') {
      if (req.data.route.fcRestricted || (req.data.route.fcRequired && (req.data.route.service != res._service._id.toString() || res._request.params.fc_token))) {
        req.params.dataId = FranceConnectHelper.generateHash(req.data.fcIdentity);
        return DataModel.io
          .findOne({
            service: req.data.service._id,
            route: req.data.route._id,
            dataId: req.params.dataId
          }, function(err, data) {
            if (err)
              return next({code: 500});
            if (data)
              return next({code: 200, data: data.getResourceObject(res._apiuri)});
            return next({code: 404, messages: ['not_found', '"' + req.params.dataId + '" is invalid']});
          });
      }
      return requestGet(req, res, next);
    }
    if (req.method == 'POST')
      return requestPost(req, res, next);
    return next({code: 500, messages: ['not_implemented']});
  };
  
  function requestGet(req, res, next) {
    var dataResult = [];
    var jsonRes = {};
    jsonRes["route"] = req.data.route._id;
    var whitelistedFields = [];
    FieldModel.io
      .find({
        route: req.data.route._id
      })
      .exec(function (err, fields) {
        console.log('1' + err);
        if (err)
          return next({code: 500});

        fields.forEach(function (field) {
          whitelistedFields.push({"name": "data."+field.nameNormalized, "key": field.type});
        });
        var jsonSearch = FilterService.buildMongoQuery(jsonRes, res._request.params.filter, whitelistedFields);
        if (jsonSearch["ERRORS"] !== undefined && jsonSearch["ERRORS"].length > 0)
          return next({code: 400, messages: jsonSearch["ERRORS"]});
        DataModel
          .io
          .find(jsonSearch)
          .cursor()
          .on('data', function(data) {
            dataResult.push(data.getResourceObject(res._apiuri));
          })
          .on('error', function(err) {
            console.log('2' + err);
            next({code: 500});
          })
          .on('end', function() {
            next({code: 200, data: dataResult});
          });
      });
    
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
            errors.push('missing_parameter', '"type" is required', 'error on index: ' + i);
          if (data.type != 'donnees')
            errors.push('invalid_paramater', '"type" must be equal to "donnees"', 'error on index: ' + i);
          if (!data.attributes)
            errors.push('missing_parameter', '"attributes" is required', 'error on index: ' + i);
          if ((req.data.route.fcRestricted || req.data.route.fcRequired) && !req.data.fcIdentity && !data.id)
            errors.push('missing_parameter', 'context: "fc_token" not specified', '"id" is required', 'error on index: ' + i);
          if ((req.data.route.fcRestricted || req.data.route.fcRequired) && req.data.fcIdentity && data.id)
            errors.push('unauthorized_parameter', 'context: "fc_token" specified', '"id" must be not specified', 'error on index: ' + i);
          if (!req.data.route.fcRestricted && !req.data.route.fcRequired && !data.id)
            errors.push('missing_parameter', '"id" is required', 'error on index: ' + i);
          
          if (req.data.route.isCollection) {
            if (!Array.isArray(data.attributes))
              errors.push('invalid_format', '"attributes" must be an array', 'error on index: ' + i);
          } else {
            if (Array.isArray(data.attributes))
              errors.push('invalid_format', '"attributes" cannot be an array', 'error on index: ' + i);
          }
          
          if (errors.length == 0) {
            var attributesToCheck = data.attributes;
            if (!Array.isArray(attributesToCheck))
              attributesToCheck = [attributesToCheck];
            attributesToCheck.forEach(function (attr) {
              if (typeof attr != 'object')
                errors.push('invalid_format', '"attributes" must be a JSON object', 'error on index: ' + i);
              
              fields.forEach(function (field) {
                let value = attr[field.nameNormalized];
                if (field.required && !value) {
                  errors.push('missing_parameter', '"' + field.nameNormalized + '" is required', 'error on index: ' + i);
                }
                if (value && !FieldModel.isTypeValid(field.type, value)) {
                  errors.push('invalid_format', '"' + field.nameNormalized + '" must be ' + field.type, 'error on index: ' + i);
                }
              });
              
              let unauthorizedFields = _.reduce(attr, function (result, val, key) {
                if (_.indexOf(whitelistedFields, key) == -1)
                  result.push(key);
                return result;
              }, []);
              if (unauthorizedFields.length > 0) {
                unauthorizedFields.forEach(function (name) {
                  errors.push('unauthorized_paramater', '"' + name + '" is not a valid parameter');
                });
              }
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
          data.data = res._request.params.data[i].attributes;
          data.save(function (err) {
            if (err)
              return next({code: 500});
            DataModel.io.findOne(condition, function(err, data) {
              if (err)
                return next({code: 500});
              objects.push(data.getResourceObject(res._apiuri));
              return requestPostElement(i + 1, fields);
            });
          });
        }
        else {
          DataModel.io.create({
            dataId: req.data.route.fcRestricted || (req.data.route.fcRequired && req.data.fcIdentity) ? FranceConnectHelper.generateHash(req.data.fcIdentity) : res._request.params.data[i].id || DataModel.generateId(),
            data: res._request.params.data[i].attributes,
            service: req.data.service._id,
            clientId: req.data.service.clientId,
            route: req.data.route._id,
            routeId: req.data.route.routeId,
            createdAt: new Date()
          }, function (err, data) {
            if (err)
              return next({code: 500, messages: err});
            objects.push({
              id: data.dataId,
              type: 'donnees',
              attributes: res._request.params.data[i].attributes,
              links: {
                self: res._apiuri + '/services/' + req.data.service.clientId + '/relationships/collections/' + data.dataId
              }
            });
            createdCount++;
            return requestPostElement(i + 1, fields);
          });
        }
      });
    };
  };
  
};
