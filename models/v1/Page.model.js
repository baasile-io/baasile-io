'use strict';

const mongoose = require('mongoose'),
  removeDiacritics = require('diacritics').remove,
  _ = require('lodash'),
  validator = require('validator'),
  CONFIG = require('../../config/app.js'),
  crypto = require('crypto');

module.exports = PageModel;

function PageModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const self = this;
  const TYPE = CONFIG.api.v1.resources.Page.type;

  mongoose.Promise = global.Promise;

  const PAGE_TYPES = [
    {key: 'CATEGORY', name: 'Page ou catégorie', icon: 'file text'},
    {key: 'ROUTE', name: 'Collection', icon: 'database'},
  ];

  const RELATION_TYPES = [
    {key: 'ONETOONE', name: 'Un pour un', icon: 'angle right'},
    {key: 'ONETOMANY', name: 'Un pour plusieurs', icon: 'angle double right'}
  ];

  const pageSchema = new mongoose.Schema({
    pageId: {
      type: String,
      required: [true, "L'identifiant est obligatoire"]
    },
    type: {
      type: String,
      required: [true, 'Le type est obligatoire'],
      enum: {values: _.reduce(PAGE_TYPES, function(result, o) {
        result.push(o.key);
        return result;
      }, []), message: "Le type renseigné n'est pas valide"}
    },
    name: {
      type: String,
      required: [true, 'Le nom est obligatoire'],
    },
    nameNormalized: {
      type: String,
      required: [true, 'Le nom normalisé est obligatoire'],
      validate: {
        validator: function(o) {
          return validator.isWhitelisted(o, 'abcdefghijklmnopqrstuvwxyz0123456789_');
        },
        message: 'Le nom normalisé n\'est pas valide'
      }
    },
    parentPage: {
      type: mongoose.Schema.ObjectId,
      ref: 'PageModel'
    },
    parentPageId: {
      type: String
    },
    relationType: {
      type: String,
      required: [true, 'Le type de relation est obligatoire'],
      enum: {values: _.reduce(RELATION_TYPES, function(result, o) {
        result.push(o.key);
        return result;
      }, []), message: "Le type de relation renseigné n'est pas valide"},
      default: RELATION_TYPES[0].key
    },
    description: {
      type: String
    },
    smallDescription: {
      type: String
    },
    route: {
      type: mongoose.Schema.ObjectId,
      ref: 'ServiceModel'
    },
    routeId: {
      type: String
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

  pageSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  pageSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
  });

  pageSchema.virtual('completeType')
    .get(function () {
      return _.find(PAGE_TYPES, {key: this.type});
    });

  pageSchema.virtual('completeRelationType')
    .get(function () {
      return _.find(RELATION_TYPES, {key: this.relationType});
    });

  this.io = db.model('Page', pageSchema);

  this.generateId = function() {
    return crypto.randomBytes(16).toString('hex');
  };

  function normalizeName(name) {
    return removeDiacritics(name.toLowerCase().replace(/[^a-z0-9_-]/g, '_'));
  };

  this.getNormalizedName = function(name) {
    return normalizeName(name);
  };

  this.getPageTypes = function() {
    return PAGE_TYPES;
  };

  this.getRelationTypes = function() {
    return RELATION_TYPES;
  };
};
