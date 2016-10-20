'use strict';

const mongoose = require('mongoose'),
  removeDiacritics = require('diacritics').remove,
  CONFIG = require('../../config/app.js'),
  serviceModel = require('./Service.model.js'),
  crypto = require('crypto'),
  mongoosePaginate = require('mongoose-paginate');

module.exports = RouteModel;

function RouteModel(options) {
  options = options || {};
  const logger = options.logger;
  const db = mongoose.createConnection(options.dbHost);
  const ServiceModel = new serviceModel(options);
  const self = this;
  const TYPE = CONFIG.api.v1.resources.Route.type;

  mongoose.Promise = global.Promise;

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

  routeSchema.plugin(mongoosePaginate);

  routeSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  routeSchema.pre('save', function(next) {
    this.updatedAt = new Date();
    next();
  });

  routeSchema.virtual('fields', {
    ref: 'FieldModel',
    localField: '_id',
    foreignField: 'route'
  });

  routeSchema.virtual('attributes')
    .get(function () {
      return {
        alias: this.nameNormalized,
        nom: this.name,
        description: this.description,
        tableau_de_donnees: this.isCollection,
        donnees_identifiees: this.isIdentified,
        jeton_fc_lecture_ecriture: this.fcRestricted,
        jeton_fc_lecture_seulement: this.fcRequired,
        public: this.public
      };
    });

  routeSchema.methods.getApiUri = function(apiUri) {
    apiUri = apiUri || options.apiUri;
    return apiUri + '/' + TYPE + '/' + this.routeId
  };

  routeSchema.methods.getApiUriList = function(apiUri) {
    apiUri = apiUri || options.apiUri;
    return [
      {
        title: 'Ressource',
        method: 'GET',
        uri: this.getApiUri(apiUri)
      },
      {
        title: 'Liste des champs',
        method: 'GET',
        icon: CONFIG.api.v1.resources.Field.icon,
        uri: this.getApiUri(apiUri) + '/relationships/' + CONFIG.api.v1.resources.Field.type
      },
      {
        title: 'Liste des données',
        method: 'GET',
        uri: this.getApiUri(apiUri) + '/relationships/' + CONFIG.api.v1.resources.Data.type
      },
      {
        title: 'Ajout et modification de données',
        method: 'POST',
        uri: this.getApiUri(apiUri) + '/relationships/' + CONFIG.api.v1.resources.Data.type
      }
    ]
  };

  routeSchema.methods.getIncludedObjects = function(apiUri, opt) {
    opt = opt || {};
    var included = [];
    if (Array.isArray(opt.include) === true) {
      if (opt.include.indexOf(CONFIG.api.v1.resources.Service.type) != -1) {
        included.push(this.service.getResourceObject(apiUri));
      }
      if (opt.include.indexOf(CONFIG.api.v1.resources.Field.type) != -1) {
        this.fields.forEach(function (field) {
          included.push(field.getResourceObject(apiUri));
        });
      }
    }
    return included;
  };

  routeSchema.methods.getRelationshipsObject = function(apiUri, opt) {
    opt = opt || {};
    var relationships = {};
    relationships[CONFIG.api.v1.resources.Service.type] = {
      links: {
        self: apiUri + '/' + CONFIG.api.v1.resources.Service.type + '/' + this.clientId
      }
    };
    relationships[CONFIG.api.v1.resources.Field.type] = {
      links: {
        self: apiUri + '/' + TYPE + '/' + this.routeId + '/relationships/' + CONFIG.api.v1.resources.Field.type,
        related: apiUri + '/' + TYPE + '/' + this.routeId + '/' + CONFIG.api.v1.resources.Field.type
      }
    };
    if (Array.isArray(opt.include) === true) {
      if (opt.include.indexOf(CONFIG.api.v1.resources.Service.type) != -1) {
        relationships[CONFIG.api.v1.resources.Service.type].data = this.service.getRelationshipReference();
      }
      if (opt.include.indexOf(CONFIG.api.v1.resources.Field.type) != -1) {
        relationships[CONFIG.api.v1.resources.Field.type].meta = {count: this.fields.length};
        relationships[CONFIG.api.v1.resources.Field.type].data = [];
        this.fields.forEach(function (field) {
          relationships[CONFIG.api.v1.resources.Field.type].data.push(field.getRelationshipReference());
        });
      }
    }
    return relationships;
  };

  routeSchema.methods.getResourceObject = function (apiUri, opt) {
    opt = opt || {};
    apiUri = apiUri || options.apiUri;
    return {
      id: this.routeId,
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

  routeSchema.methods.getRelationshipReference = function () {
    return {
      id: this.routeId,
      type: TYPE
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
