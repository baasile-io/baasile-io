'use strict';

const mongoose = require('mongoose'),
  CONFIG = require('../../config/app.js'),
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
  const self = this;
  const TYPE = CONFIG.api.v1.resources.Field.type;

  const FIELD_TYPES = [
    {key: 'ID', name: 'Identifiant unique', icon: 'privacy', default: "ID"},
    {key: 'STRING', name: 'Texte', icon: 'font', default: ""},
    {key: 'NUMERIC', name: 'Numérique', icon: 'hashtag', default: 0},
    {key: 'PERCENT', name: 'Pourcentage', icon: 'percent', default: 0},
    {key: 'AMOUNT', name: 'Montant', icon: 'euro', default: 0},
    {key: 'DATE', name: 'Date', icon: 'calendar', default: new Date()},
    {key: 'ENCODED', name: 'Donnée encodée', icon: 'protect', default: ""},
    {key: 'JSON', name: 'JSON', icon: 'sitemap', default: {}}
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
    routeId: {
      type: String,
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

  fieldSchema.methods.getResourceObject = function (apiUri) {
    apiUri = apiUri || options.apiUri;
    return {
      id: this.fieldId,
      type: TYPE,
      attributes: {
        nom: this.nameNormalized,
        description: this.description,
        position: this.order
      },
      links: {
        self: apiUri + '/' + CONFIG.api.v1.resources.Service.type + '/' + this.clientId + '/relationships/' + CONFIG.api.v1.resources.Route.type + '/' + this.routeId + '/relationships/' + TYPE + '/' + this.fieldId
      },
      meta: {
        creation: this.createdAt,
        modification: this.updatedAt,
        version: this.__v
      }
    };
  };

  this.io = db.model('Field', fieldSchema);

  this.io.schema.pre('validate', function(next) {
    var obj = this;
    if (this.nameNormalized != normalizeName(this.name))
      this.invalidate('nameNormalized', 'Le nom normalisé doit correspondre avec le nom');
    if (this.type === 'ID' && this.nameNormalized != 'id')
      this.invalidate('name', 'Un identifiant unique doit être nommé "id"');
    if (this.type === 'ID' && !this.required)
      this.invalidate('required', 'Un identifiant unique doit être un champ obligatoire');
    self.io.find({
      route: this.route,
      fieldId: {$ne: this.fieldId},
      nameNormalized: this.nameNormalized
    }, function(err, others) {
      if (err)
        obj.invalidate('_id', 'Internal Server Error');
      if (others.length > 0)
        obj.invalidate('name', 'Le nom doit être unique');
      next();
    });
  });

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

  this.isTypeValid = function(type, value) {
    if (type == 'STRING' && typeof value != 'string')
      return false;
    if ((type == 'NUMERIC' || type == 'PERCENT' || type == 'AMOUNT') && typeof value != 'number')
      return false;
    if (type == 'DATE' && (typeof value != 'string' || isNaN(Date.parse(value))))
      return false;
    if (type == 'JSON') {
      if (typeof value != 'object')
        return false;
      if (Array.isArray(value))
        return false;
    }
    return true;
  };

};
