'use strict';

const mongoose = require('mongoose'),
  validator = require('validator');

module.exports = ServiceModel;

var serviceSchema = new mongoose.Schema({
  name: {
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
    validate: {
      validator: function (url) {
        return validator.isURL(url);
      },
      message: 'Adresse du Site Internet invalide'
    }
  },
  public: {
    type: Boolean,
    required: true
  },
  secret: {
    type: String,
    required: true,
    unique: true
  },
  tokens: [{
    type: mongoose.Schema.ObjectId,
    ref: 'TokenModel'
  }],
  users: [{
      type: mongoose.Schema.ObjectId,
      ref: 'UserModel'
  }],
  created_at: Date,
  updated_at: Date
});

function ServiceModel(options) {
  options = options || {};
  const db = mongoose.createConnection(options.dbHost);

  this.io = db.model('Service', serviceSchema);
}
