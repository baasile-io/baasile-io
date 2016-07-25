'use strict';

const mongoose = require('mongoose'),
  removeDiacritics = require('diacritics').remove,
  serviceModel = require('./Service.model.js'),
  crypto = require('crypto');

module.exports = RouteModel;

function RouteModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const ServiceModel = new serviceModel(options);
  const self = this;

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
    method: {
      type: String,
      required: true
    },
    fcRequired: {
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

  this.io = db.model('Route', routeSchema);

  this.io.schema.pre('validate', function(next) {
    var obj = this;
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
