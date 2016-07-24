'use strict';

const mongoose = require('mongoose'),
  _ = require('lodash'),
  removeDiacritics = require('diacritics').remove,
  validator = require('validator'),
  serviceModel = require('./Service.model.js'),
  crypto = require('crypto');

module.exports = FieldModel;

function FieldModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);

  const FIELD_TYPES = [
    {key: 'STRING', name: 'Texte', icon: 'font'},
    {key: 'NUMERIC', name: 'Numérique', icon: 'hashtag'},
    {key: 'PERCENT', name: 'Pourcentage', icon: 'percent'},
    {key: 'AMOUNT', name: 'Montant', icon: 'euro'},
    {key: 'DATE', name: 'Date', icon: 'calendar'},
    {key: 'ID', name: 'Identifiant unique', icon: 'privacy'},
    {key: 'ENCODED', name: 'Donnée encodée', icon: 'protect'},
    {key: 'JSON', name: 'JSON', icon: 'sitemap'}
  ];

  const fieldSchema = new mongoose.Schema({
    fieldId: {
      type: String,
      required: [true, "L'identifiant est obligatoire"],
      unique: [true, "L'identifiant doit être unique"]
    },
    name: {
      type: String,
      required: [true, "Le nom est obligatoire"],
      validate: {
        validator: function(o) {
          return validator.isWhitelisted(o.toLowerCase(), 'abcdefghijklmnopqrstuvwxyz0123456789- ùûüÿàâçéèêëïîô');
        },
        message: 'Le nom doit uniquement comporter des chiffres, des lettres, des espaces et des caractères `-`'
      },
      minlength: [2, 'Le nom doit faire entre 2 et 25 caractères'],
      maxlength: [25, 'Le nom doit faire entre 2 et 25 caractères']
    },
    nameNormalized: {
      type: String,
      required: [true, "Le nom est obligatoire"],
      validate: {
        validator: function(o) {
          return validator.isWhitelisted(o, 'abcdefghijklmnopqrstuvwxyz0123456789_');
        },
        message: 'Le nom normalisé n\'est pas valide'
      }
    },
    description: {
      type: String,
      required: [true, "La description est obligatoire"]
    },
    required: {
      type: Boolean,
      required: true
    },
    order: {
      type: Number,
      default: 0
    },
    type: {
      type: String,
      required: [true, 'Le type est obligatoire'],
      enum: {values: _.reduce(FIELD_TYPES, function(result, o) {
        result.push(o.key);
        return result;
      }, []), message: "Le type renseigné n'est pas valide"}
    },
    route: {
      type: mongoose.Schema.ObjectId,
      ref: 'RouteModel',
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

  fieldSchema.pre('validate', function(next) {
    if (this.nameNormalized != normalizeName(this.name))
      next('Le nom normalisé doit correspondre avec le nom');
    next();
  });

  fieldSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  fieldSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
  });

  fieldSchema.virtual('completeType')
    .get(function () {
      return _.find(FIELD_TYPES, {key: this.type});
    });

  this.io = db.model('Field', fieldSchema);

  this.generateId = function() {
    return crypto.randomBytes(16).toString('hex');
  };

  function normalizeName(name) {
    return removeDiacritics(name.toLowerCase().replace(/[ \-]/g, '_'));
  };

  this.getNormalizedName = function(name) {
    return normalizeName(name);
  };

  this.getFieldTypes = function() {
    return FIELD_TYPES;
  };

};
