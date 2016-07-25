'use strict';

const mongoose = require('mongoose'),
  crypto = require('crypto');

module.exports = DataModel;

function DataModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const self = this;

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
    service: {
      type: mongoose.Schema.ObjectId,
      ref: 'ServiceModel',
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

  this.io = db.model('Data', dataSchema);

  this.generateId = function() {
    return crypto.randomBytes(48).toString('hex');
  };
};
