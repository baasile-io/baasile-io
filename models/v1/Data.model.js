'use strict';

const mongoose = require('mongoose'),
  CONFIG = require('../../config/app.js'),
  crypto = require('crypto');

module.exports = DataModel;

function DataModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const self = this;
  const TYPE = CONFIG.api.v1.resources.Data.type;

  const dataSchema = new mongoose.Schema({
    dataId: {
      type: String,
      required: [true, "L'identifiant est obligatoire"]
    },
    data: {
      type: Object,
      required: [true, "Le champ 'data' est obligatoire"],
    },
    route: {
      type: mongoose.Schema.ObjectId,
      ref: 'RouteModel',
      required: true
    },
    routeId: {
      type: String,
      required: true
    },
    service: {
      type: mongoose.Schema.ObjectId,
      ref: 'ServiceModel',
      required: true
    },
    clientId: {
      type: String,
      required: true
    },
    createdAt: {
      type: Date,
      required: true
    },
    updatedAt: Date
  });

  dataSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  dataSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
  });

  dataSchema.virtual('attributes')
    .get(function () {
      return this.data;
    });

  dataSchema.methods.getResourceObject = function (apiUri) {
    apiUri = apiUri || options.apiUri;
    return {
      id: this.dataId,
      type: TYPE,
      data: this.data,
      links: {
        self: apiUri + '/' + CONFIG.api.v1.resources.Service.type + '/' + this.clientId + '/relationships/' + CONFIG.api.v1.resources.Route.type + '/' + this.routeId + '/relationships/' + TYPE + '/' + this.dataId
      },
      meta: {
        creation: this.createdAt,
        modification: this.updatedAt
      }
    };
  };

  this.io = db.model('Data', dataSchema);

  this.generateId = function() {
    return crypto.randomBytes(48).toString('hex');
  };
};
