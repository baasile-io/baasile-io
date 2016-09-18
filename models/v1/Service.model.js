'use strict';

const mongoose = require('mongoose'),
  removeDiacritics = require('diacritics').remove,
  validator = require('validator'),
  CONFIG = require('../../config/app.js'),
  crypto = require('crypto');

module.exports = ServiceModel;

var serviceSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Nom du service obligatoire'],
    unique: [true, 'Nom du service déjà utilisé'],
    validate: {
      validator: function (name) {
        return validator.isWhitelisted(name.toLowerCase(), '\'abcdefghijklmnopqrstuvwxyz0123456789- ùûüÿàâçéèêëïîô');
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
    default: '',
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
  validated: {
    type: Boolean,
    required: true,
    default: false
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
  const TYPE = CONFIG.api.v1.resources.Service.type;

  mongoose.Promise = global.Promise;

  serviceSchema.pre('validate', function(next) {
    if (!this.validated)
      this.invalidate('public', 'Un service non validé par l\'Équipe administratrice de la Plate-forme ne peut être référencée sur l\'API');
    this.updatedAt = new Date();
    next();
  });

  serviceSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  serviceSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
  });

  serviceSchema.virtual('attributes')
    .get(function () {
      return {
        alias: this.nameNormalized,
        nom: this.name,
        description: this.description,
        site_internet: this.website
      };
    });

  serviceSchema.virtual('meta')
    .get(function () {
      return {
        creation: this.createdAt,
        modification: this.updatedAt,
        version: this.__v
      };
    });

  serviceSchema.methods.tokensCount = function() {
    return this.model('Token').count({service: this}, function(err, total) {
      if (err)
        return -1;
      return total;
    });
  };

  serviceSchema.methods.getResourceObject = function (apiUri) {
    apiUri = apiUri || options.apiUri;
    return {
      id: this.clientId,
      type: TYPE,
      attributes: this.get('attributes'),
      links: {
        self: apiUri + '/' + TYPE + '/' + this.clientId
      },
      meta: this.get('meta')
    };
  };

  this.io = db.model('Service', serviceSchema);

  this.generateSecret = function() {
    return crypto.randomBytes(48).toString('hex');
  };

  this.generateId = function() {
    return crypto.randomBytes(48).toString('hex');
  };

  function normalizeName(name) {
    return removeDiacritics(name.toLowerCase().replace(/[ \']/g, '_'));
  };

  this.getNormalizedName = function(name) {
    return normalizeName(name);
  };
};
