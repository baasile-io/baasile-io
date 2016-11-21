'use strict';

const mongoose = require('mongoose'),
  _ = require('lodash'),
  validator = require('validator'),
  CONFIG = require('../../config/app.js'),
  crypto = require('crypto');

module.exports = RelationModel;

function RelationModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const self = this;
  const TYPE = CONFIG.api.v1.resources.Relation.type;

  mongoose.Promise = global.Promise;

  const RELATION_TYPES = [
    {key: 'ONETOONE', name: 'Un pour un', icon: 'minus'},
    {key: 'ONETOMANY', name: 'Un pour plusieurs', icon: 'share alternate'}
  ];

  const relationSchema = new mongoose.Schema({
    relationId: {
      type: String,
      required: [true, "L'identifiant est obligatoire"]
    },
    type: {
      type: String,
      required: [true, 'Le type de relation est obligatoire'],
      enum: {values: _.reduce(RELATION_TYPES, function(result, o) {
        result.push(o.key);
        return result;
      }, []), message: "Le type de relation renseigné n'est pas valide"},
      default: RELATION_TYPES[0].key
    },
    parentRoute: {
      type: mongoose.Schema.ObjectId,
      ref: 'RouteModel',
      required: true
    },
    parentRouteId: {
      type: String,
      required: true
    },
    childRoute: {
      type: mongoose.Schema.ObjectId,
      ref: 'RouteModel',
      required: [true, 'La relation n\'est pas complète']
    },
    childRouteId: {
      type: String,
      required: [true, 'La relation n\'est pas complète']
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

  relationSchema.virtual('completeType')
    .get(function () {
      return _.find(RELATION_TYPES, {key: this.type});
    });

  relationSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  relationSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    this.increment();
    next();
  });

  this.io = db.model('Relation', relationSchema);

  this.io.schema.pre('validate', function(next) {
    var obj = this;
    self.io.find({
      service: this.service,
      relationId: {$ne: this.relationId},
      childRouteId: this.childRouteId
    }, function(err, others) {
      if (err)
        obj.invalidate('_id', 'Internal Server Error');
      if (others && others.length > 0)
        obj.invalidate('childRoute', 'Une relation existe déjà avec cette collection');
      next();
    });
  });

  this.generateId = function() {
    return crypto.randomBytes(16).toString('hex');
  };

  this.getTypes = function() {
    return RELATION_TYPES;
  };
};
