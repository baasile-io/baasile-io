'use strict';

const mongoose = require('mongoose'),
  CONFIG = require('../../config/app.js'),
  _ = require('lodash'),
  removeDiacritics = require('diacritics').remove,
  validator = require('validator'),
  crypto = require('crypto'),
  mongoosePaginate = require('mongoose-paginate');

module.exports = FieldModel;

function FieldModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const self = this;
  const TYPE = CONFIG.api.v1.resources.Field.type;

  mongoose.Promise = global.Promise;

  const FIELD_TYPES = [
    {key: 'ID', name: 'Identifiant unique', icon: 'privacy', default: "ID", sample: "\"abcdefghijklmnopqrst...\""},
    {key: 'STRING', name: 'Texte', icon: 'font', default: "", sample: "\"My string\""},
    {key: 'NUMERIC', name: 'Numérique', icon: 'hashtag', default: 0, sample: "2017"},
    {key: 'PERCENT', name: 'Pourcentage', icon: 'percent', default: 0, sample: "99.9"},
    {key: 'AMOUNT', name: 'Montant', icon: 'euro', default: 0, sample: "42.42"},
    {key: 'BOOLEAN', name: 'Booléen', icon: 'toggle on', default: false, sample: "true"},
    {key: 'DATE', name: 'Date', icon: 'calendar', default: new Date(), sample: "\"2017-01-01T12:00:00.000Z\""},
    {key: 'ENCODED', name: 'Donnée encodée', icon: 'protect', default: "", sample: "\"e4ba65bd1ab6070b1dbe...\""},
    {key: 'JSON', name: 'JSON', icon: 'sitemap', default: {}, sample: "{\"field1\": \"value1\", \"field2\": \"value2\"}"}
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
          return validator.isWhitelisted(o.toLowerCase(), 'abcdefghijklmnopqrstuvwxyz0123456789-_ ùûüÿàâçéèêëïîô');
        },
        message: 'Le nom doit uniquement comporter des chiffres, des lettres, des espaces et des caractères `-`'
      },
      minlength: [2, 'Le nom doit faire entre 2 et 30 caractères'],
      maxlength: [30, 'Le nom doit faire entre 2 et 30 caractères']
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

  fieldSchema.plugin(mongoosePaginate);

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

  fieldSchema.virtual('service', {
    ref: 'ServiceModel',
    localField: 'clientId',
    foreignField: 'clientId'
  });

  fieldSchema.virtual('attributes')
    .get(function () {
      return {
        nom: this.nameNormalized,
        description: this.description,
        position: this.order,
        type: this.type
      };
    });

  fieldSchema.methods.getApiUri = function(apiUri) {
    apiUri = apiUri || options.apiUri;
    return apiUri + '/' + TYPE + '/' + this.fieldId
  };

  fieldSchema.methods.getApiUriList = function(apiUri) {
    apiUri = apiUri || options.apiUri;
    return [
      {
        title: 'Ressource',
        method: 'GET',
        uri: this.getApiUri(apiUri)
      }
    ]
  };

  fieldSchema.methods.getIncludedObjects = function(apiUri, opt) {
    opt = opt || {};
    var included = [];
    if (Array.isArray(opt.include) === true) {
      if (opt.include.indexOf(CONFIG.api.v1.resources.Route.type) != -1) {
        included.push(this.route.getResourceObject(apiUri));
      }
    }
    return included;
  };

  fieldSchema.methods.getRelationshipsObject = function(apiUri, opt) {
    opt = opt || {};
    var relationships = {};
    relationships[CONFIG.api.v1.resources.Route.type] = {
      links: {
        self: apiUri + '/' + CONFIG.api.v1.resources.Route.type + '/' + this.routeId
      }
    };
    relationships[CONFIG.api.v1.resources.Service.type] = {
      links: {
        self: apiUri + '/' + CONFIG.api.v1.resources.Service.type + '/' + this.clientId
      }
    };
    if (Array.isArray(opt.include) === true) {
      if (opt.include.indexOf(CONFIG.api.v1.resources.Route.type) != -1) {
        relationships[CONFIG.api.v1.resources.Route.type].data = this.route.getRelationshipReference();
      }
    }
    if (Array.isArray(opt.include) === true) {
      if (opt.include.indexOf(CONFIG.api.v1.resources.Service.type) != -1) {
        relationships[CONFIG.api.v1.resources.Service.type].data = this.service[0].getRelationshipReference();
      }
    }
    return relationships;
  };

  fieldSchema.methods.getResourceObject = function (apiUri, opt) {
    opt = opt || {};
    apiUri = apiUri || options.apiUri;
    return {
      id: this.fieldId,
      type: TYPE,
      attributes: this.get('attributes'),
      links: {
        self: this.getApiUri(apiUri)
      },
      meta: {
        creation: this.createdAt,
        modification: this.updatedAt,
        version: this.__v
      },
      relationships: this.getRelationshipsObject(apiUri, opt)
    };
  };

  fieldSchema.methods.getRelationshipReference = function () {
    return {
      id: this.fieldId,
      type: TYPE
    };
  };

  this.io = db.model('Field', fieldSchema);

  this.io.schema.pre('validate', function(next) {
    var obj = this;
    this.nameNormalized = normalizeName(this.name);
    if (this.type === 'ID' && this.nameNormalized.indexOf('id_') != 0)
      this.invalidate('name', 'Un identifiant unique doit commencer par "id_"');
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
};
