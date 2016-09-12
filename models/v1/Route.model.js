'use strict';

const mongoose = require('mongoose'),
  removeDiacritics = require('diacritics').remove,
  CONFIG = require('../../config/app.js'),
  serviceModel = require('./Service.model.js'),
  crypto = require('crypto');

module.exports = RouteModel;

function RouteModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const ServiceModel = new serviceModel(options);
  const self = this;
  const TYPE = CONFIG.api.v1.resources.Route.type;

  const ROUTE_TYPES = [
    'API',
    'DONNEE_PARTAGEE'
  ];

  const routeSchema = new mongoose.Schema({
    routeId: {
      type: String,
      required: [true, "L'identifiant est obligatoire"],
      unique: [true, "L'identifiant doit être unique"]
    },
    name: {
      type: String,
      required: [true, "Le nom est obligatoire"],
    },
    nameNormalized: {
      type: String,
      required: [true, "Le nom est obligatoire"],
    },
    description: {
      type: String,
      required: [true, "La description est obligatoire"]
    },
    type: {
      type: String,
      required: true,
      enum: {values: ROUTE_TYPES, message: "Le type renseigné n'est pas valide"}
    },
    isCollection: {
      type: Boolean,
      required: true
    },
    isIdentified: {
      type: Boolean,
      required: true
    },
    method: {
      type: String,
      required: true
    },
    fcRequired: {
      type: Boolean,
      required: true
    },
    fcRestricted: {
      type: Boolean,
      required: true
    },
    public: {
      type: Boolean,
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
    creator: {
      type: mongoose.Schema.ObjectId,
      ref: 'UserModel',
      required: true
    },
    createdAt: {
      type: Date,
      required: true
    },
    updatedAt: Date
  });

  routeSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  routeSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
  });

  routeSchema.virtual('attributes')
    .get(function () {
      return {
        alias: this.nameNormalized,
        nom: this.name,
        description: this.description,
        tableau_de_donnees: this.isCollection,
        jeton_fc_lecture_ectriture: this.fcRestricted,
        jeton_fc_lecture_seulement: this.fcRequired
      };
    });

  routeSchema.methods.getResourceObject = function (apiUri) {
    apiUri = apiUri || options.apiUri;
    return {
      id: this.routeId,
      type: TYPE,
      attributes: this.get('attributes'),
      links: {
        self: apiUri + '/' + CONFIG.api.v1.resources.Service.type + '/' + this.clientId + '/relationships/' + TYPE + '/' + this.routeId
      },
      meta: {
        creation: this.createdAt,
        modification: this.updatedAt,
        version: this.__v
      }
    };
  };

  this.io = db.model('Route', routeSchema);

  this.io.schema.pre('validate', function(next) {
    var obj = this;
    if (!this.isIdentified) {
      this.fcRestricted = false;
      this.fcRequired = false;
    }
    if (this.fcRestricted)
      this.fcRequired = true;
    if (this.nameNormalized != normalizeName(this.name))
      this.invalidate('nameNormalized', 'Le nom normalisé doit correspondre avec le nom');
    self.io.find({
      service: this.service,
      routeId: {$ne: this.routeId},
      nameNormalized: this.nameNormalized
    }, function(err, others) {
      if (err)
        obj.invalidate('_id', 'Internal Server Error');
      if (others && others.length > 0)
        obj.invalidate('name', 'Le nom doit être unique');
      next();
    });
  });

  this.generateId = function() {
    return crypto.randomBytes(16).toString('hex');
  };

  function normalizeName(name) {
    return removeDiacritics(name.toLowerCase().replace(/ /g, '-'));
  };

  this.getNormalizedName = function(name) {
    return normalizeName(name);
  };
};
