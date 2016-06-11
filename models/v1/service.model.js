'use strict';

const mongoose = require('mongoose'),
  validator = require('validator'),
  crypto = require('crypto');

module.exports = ServiceModel;

var serviceSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Nom du service obligatoire'],
    unique: [true, 'Nom du service déjà utilisé'],
    validate: {
      validator: function (name) {
        return validator.isWhitelisted(name.toLowerCase(), 'abcdefghijklmnopqrstuvwxyz0123456789- ');
      },
      message: 'Le nom du service doit comporter uniquement des chiffres, des lettres, des espaces et des caractères `-`'
    }
  },
  nameNormalized: {
    type: String,
    required: true,
    unique: [true, 'Nom du service déjà utilisé']
  },
  description: {
    type: String,
    required: [true, 'Description du service obligatoire']
  },
  website: {
    type: String,
    validate: {
      validator: function (url) {
        if (url === '')
          return (true);
        return validator.isURL(url);
      },
      message: 'Adresse du Site Internet invalide'
    }
  },
  public: {
    type: Boolean,
    required: true
  },
  secret: {
    type: String,
    required: true,
    unique: true
  },
  tokens: [{
    type: mongoose.Schema.ObjectId,
    ref: 'TokenModel'
  }],
  users: [{
      type: mongoose.Schema.ObjectId,
      ref: 'UserModel'
  }],
  created_at: Date,
  updated_at: Date
});


function ServiceModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);

  serviceSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  this.io = db.model('Service', serviceSchema);

  this.generateSecret = function() {
    return crypto.randomBytes(48).toString('hex');
  }

  this.getNormalizedName = function(name) {
    return name.toLowerCase().replace(/ /g, '-');
  }
}
