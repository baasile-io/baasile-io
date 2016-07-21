'use strict';

const mongoose = require('mongoose'),
  serviceModel = require('./Service.model.js'),
  StandardError = require('standard-error');

module.exports = TokenModel;

var tokenSchema = new mongoose.Schema({
  accessToken: {
    type: String,
    required: true
  },
  accessTokenExpiresOn: {
    type: Date,
    required: true
  },
  production: {
    type: Boolean,
    required: true
  },
  nbOfUse: {
    type: Number,
    default: 0
  },
  service: [{
    type: mongoose.Schema.ObjectId,
    ref: 'ServiceModel'
  }],
  createdAt: {
    type: Date,
    required: true
  },
  updatedAt: Date
});


function TokenModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const ServiceModel = new serviceModel(options);

  tokenSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
  });

  this.io = db.model('Token', tokenSchema);
  
  this.generateToken = function() {
    return ServiceModel.generateSecret();
  };
};
