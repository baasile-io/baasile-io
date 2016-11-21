'use strict';

const mongoose = require('mongoose'),
  mongoosePaginate = require('mongoose-paginate'),
  crypto = require('crypto');

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
  service: {
    type: mongoose.Schema.ObjectId,
    ref: 'ServiceModel'
  },
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

  mongoose.Promise = global.Promise;

  tokenSchema.plugin(mongoosePaginate);

  tokenSchema.pre('validate', function(next) {
    this.updatedAt = new Date();
    next();
  });

  tokenSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  tokenSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    this.increment();
    next();
  });

  this.io = db.model('Token', tokenSchema);
  
  this.generateToken = function() {
    return crypto.randomBytes(48).toString('hex');
  };
};
