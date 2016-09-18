'use strict';

const mongoose = require('mongoose'),
  crypto = require('crypto');

module.exports = EmailTokenModel;

var emailTokenSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true
  },
  accessToken: {
    type: String,
    required: true
  },
  accessTokenExpiresOn: {
    type: Date,
    required: true
  },
  nbOfUse: {
    type: Number,
    default: 0
  },
  user: {
    type: mongoose.Schema.ObjectId,
    ref: 'UserModel'
  },
  email: {
    type: String,
    required: true
  },
  foreignId: {
    type: String
  },
  createdAt: {
    type: Date,
    required: true
  },
  updatedAt: Date
});


function EmailTokenModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);

  mongoose.Promise = global.Promise;

  emailTokenSchema.pre('validate', function(next) {
    this.updatedAt = new Date();
    next();
  });

  emailTokenSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  emailTokenSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
  });

  this.io = db.model('EmailToken', emailTokenSchema);
  
  this.generateToken = function() {
    return crypto.randomBytes(48).toString('hex');
  };
};
