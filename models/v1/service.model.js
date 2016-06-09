'use strict';

const mongoose = require('mongoose');

module.exports = ServiceModel;

var serviceSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Nom du service obligatoire'],
    unique: [true, 'Nom du service déjà utilisé']
  },
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
