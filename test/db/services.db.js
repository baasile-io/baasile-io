'use strict';

const services = require('./db.js').SERVICES,
  serviceModel = require('../../models/v1/Service.model.js'),
  routeModel = require('../../models/v1/Route.model.js'),
  fieldModel = require('../../models/v1/Field.model.js'),
  dataModel = require('../../models/v1/Data.model.js');

module.exports = ServicesDb;

function ServicesDb(options) {
  options = options || {};

  const ServiceModel = new serviceModel(options),
    RouteModel = new routeModel(options),
    FieldModel = new fieldModel(options),
    DataModel = new dataModel(options);

  var db = [],
    routes = [],
    fields = [],
    datas = [];

  this.seed = function(users) {
    return new Promise(function(resolve, reject) {

      var iService = 0;
      function insertServices() {
        if (iService == services.length)
          return resolve(db);

        // seed default values
        services[iService].createdAt = services[iService].createdAt || new Date();
        services[iService].nameNormalized = ServiceModel.getNormalizedName(services[iService].name);

        // seed users id
        services[iService].creator = users[services[iService].CREATOR_INDEX];
        services[iService].USERS_INDEX.forEach(function(index) {
          services[iService].users.push(users[index]);
        });

        ServiceModel.io.create(services[iService], function(err, service) {
          if (err)
            return reject(err);

          db.push(service);
          service.routesArray = [];

          var iRoute = 0;
          function insertRoutes() {
            if (iRoute == services[iService].ROUTES.length) {
              iService++;
              return insertServices();
            }

            // seed default values
            services[iService].ROUTES[iRoute].nameNormalized = RouteModel.getNormalizedName(services[iService].ROUTES[iRoute].name);
            services[iService].ROUTES[iRoute].method = 'POST';
            services[iService].ROUTES[iRoute].type = 'DONNEE_PARTAGEE';
            services[iService].ROUTES[iRoute].createdAt = new Date();

            // seed ids
            services[iService].ROUTES[iRoute].clientId = service.clientId;
            services[iService].ROUTES[iRoute].creator = service.creator;
            services[iService].ROUTES[iRoute].service = service;

            RouteModel.io.create(services[iService].ROUTES[iRoute], function(err, route) {
              if (err)
                return reject(err);

              routes.push(route);
              service.routesArray.push(route);
              route.fieldsArray = [];

              var iField = 0;
              function insertFields() {
                if (iField == services[iService].ROUTES[iRoute].FIELDS.length) {
                  return insertDatas();
                }

                // seed default values
                services[iService].ROUTES[iRoute].FIELDS[iField].createdAt = new Date();
                services[iService].ROUTES[iRoute].FIELDS[iField].nameNormalized = FieldModel.getNormalizedName(services[iService].ROUTES[iRoute].FIELDS[iField].name);
                services[iService].ROUTES[iRoute].FIELDS[iField].description = 'description';

                // seed ids
                services[iService].ROUTES[iRoute].FIELDS[iField].route = route;
                services[iService].ROUTES[iRoute].FIELDS[iField].routeId = route.routeId;
                services[iService].ROUTES[iRoute].FIELDS[iField].service = service;
                services[iService].ROUTES[iRoute].FIELDS[iField].creator = service.creator;
                services[iService].ROUTES[iRoute].FIELDS[iField].clientId = service.clientId;

                FieldModel.io.create(services[iService].ROUTES[iRoute].FIELDS[iField], function(err, field) {
                  if (err)
                    return reject(err);

                  fields.push(field);
                  route.fieldsArray.push(field);

                  iField++;
                  return insertFields();
                });
              };

              var iData = 0;
              function insertDatas() {
                if (iData == services[iService].ROUTES[iRoute].DATAS.length) {
                  iRoute++;
                  return insertRoutes();
                }

                // seed default values
                services[iService].ROUTES[iRoute].DATAS[iData].createdAt = new Date();

                // seed ids
                services[iService].ROUTES[iRoute].DATAS[iData].route = route;
                services[iService].ROUTES[iRoute].DATAS[iData].routeId = route.routeId;
                services[iService].ROUTES[iRoute].DATAS[iData].service = service;
                services[iService].ROUTES[iRoute].DATAS[iData].clientId = service.clientId;

                DataModel.io.create(services[iService].ROUTES[iRoute].DATAS[iData], function(err, data) {
                  if (err)
                    return reject(err);

                  datas.push(data);

                  iData++;
                  return insertDatas();
                });

              };

              return insertFields();
            });
          };

          return insertRoutes();
        });
      };

      return insertServices();
    });
  };

  this.drop = function() {
    return new Promise(function(resolve, reject) {
      ServiceModel.io.remove({}, function (err) {
        if (err)
          return reject(err);

        FieldModel.io.remove({}, function (err) {
          if (err)
            return reject(err);

          RouteModel.io.remove({}, function (err) {
            if (err)
              return reject(err);

            DataModel.io.remove({}, function (err) {
              if (err)
                return reject(err);

              return resolve();
            });
          });
        });
      });
    });
  };
};