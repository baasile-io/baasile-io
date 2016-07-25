'use strict';

const mongoose = require('mongoose'),
  removeDiacritics = require('diacritics').remove,
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
        return validator.isWhitelisted(name.toLowerCase(), 'abcdefghijklmnopqrstuvwxyz0123456789- ùûüÿàâçéèêëïîô');
      },
      message: 'Le nom du service doit uniquement comporter des chiffres, des lettres, des espaces et des caractères `-`'
    }
  },
  nameNormalized: {
    type: String,
    required: [true, 'Nom du service obligatoire'],
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
  clientSecret: {
    type: String,
    required: true,
    unique: true
  },
  clientId: {
    type: String,
    required: true,
    unique: true
  },
  users: [{
      type: mongoose.Schema.ObjectId,
      ref: 'UserModel'
  }],
  creator: {
    type: mongoose.Schema.ObjectId,
    ref: 'UserModel',
    required: true
  },
  createdAt: {
    type: Date,
    required: true
  },
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

  serviceSchema.methods.tokensCount = function() {
    return this.model('Token').count({service: this}, function(err, total) {
      if (err)
        return -1;
      return total;
    });
  };

  this.io = db.model('Service', serviceSchema);

  this.generateSecret = function() {
    return crypto.randomBytes(48).toString('hex');
  };

  this.generateId = function() {
    return crypto.randomBytes(48).toString('hex');
  };

  this.getNormalizedName = function(name) {
    return removeDiacritics(name.toLowerCase().replace(/ /g, '-'));
  };
};