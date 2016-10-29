'use strict';

const mongoose = require('mongoose'),
  removeDiacritics = require('diacritics').remove,
  validator = require('validator'),
  CONFIG = require('../../config/app.js'),
  crypto = require('crypto'),
  mongoosePaginate = require('mongoose-paginate'),
  _ = require('lodash');

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

  serviceSchema.plugin(mongoosePaginate);

  serviceSchema.pre('validate', function(next) {
    this.nameNormalized = normalizeName(this.name);
    if (this.validated != true && this.public === true)
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

  serviceSchema.virtual('routes', {
    ref: 'RouteModel',
    localField: '_id',
    foreignField: 'service'
  });

  serviceSchema.virtual('attributes')
    .get(function () {
      return {
        alias: this.nameNormalized,
        nom: this.name,
        description: this.description,
        site_internet: this.website,
        public: this.public
      };
    });

  serviceSchema.methods.getMetaObject = function() {
    return {
      creation: this.createdAt,
      modification: this.updatedAt,
      version: this.__v
    }
  };

  serviceSchema.methods.getRelationshipsObject = function(apiUri, opt) {
    opt = opt || {};
    var relationships = {};
    relationships[CONFIG.api.v1.resources.Route.type] = {
      links: {
        self: apiUri + '/' + TYPE + '/' + this.clientId + '/relationships/' + CONFIG.api.v1.resources.Route.type,
        related: apiUri + '/' + TYPE + '/' + this.clientId + '/' + CONFIG.api.v1.resources.Route.type
      }
    };
    if (Array.isArray(opt.include) === true && opt.include.indexOf(CONFIG.api.v1.resources.Route.type) != -1) {
      relationships[CONFIG.api.v1.resources.Route.type].meta = {count: this.routes.length};
      relationships[CONFIG.api.v1.resources.Route.type].data = [];
      this.routes.forEach(function (route) {
        relationships[CONFIG.api.v1.resources.Route.type].data.push(route.getRelationshipReference());
      });
    }
    return relationships;
  };

  serviceSchema.methods.getIncludedObjects = function(apiUri, opt) {
    opt = opt || {};
    var included = [];
    if (Array.isArray(opt.include) === true && opt.include.indexOf(CONFIG.api.v1.resources.Route.type) != -1) {
      this.routes.forEach(function (route) {
        included.push(route.getResourceObject(apiUri));
      });
    }
    return included;
  };

  serviceSchema.methods.getApiUri = function(apiUri) {
    apiUri = apiUri || options.apiUri;
    return apiUri + '/' + TYPE + '/' + this.clientId;
  };

  serviceSchema.methods.getApiUriList = function(apiUri) {
    apiUri = apiUri || options.apiUri;
    return [
      {
        title: 'Ressource',
        method: 'GET',
        uri: this.getApiUri(apiUri)
      },
      {
        title: 'Liste des collections',
        method: 'GET',
        icon: CONFIG.api.v1.resources.Route.icon,
        uri: this.getApiUri(apiUri) + '/relationships/' + CONFIG.api.v1.resources.Route.type
      }
    ]
  };

  serviceSchema.methods.tokensCount = function() {
    return this.model('Token').count({service: this}, function(err, total) {
      if (err)
        return -1;
      return total;
    });
  };

  serviceSchema.methods.getResourceObject = function (apiUri, opt) {
    opt = opt || {};
    apiUri = apiUri || options.apiUri;
    return {
      id: this.clientId,
      type: TYPE,
      attributes: this.get('attributes'),
      links: {
        self: this.getApiUri(apiUri)
      },
      meta: this.getMetaObject(),
      relationships: this.getRelationshipsObject(apiUri, opt)
    };
  };

  serviceSchema.methods.getRelationshipReference = function () {
    return {
      id: this.clientId,
      type: TYPE
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
