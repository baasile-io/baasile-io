'use strict';

const mongoose = require('mongoose'),
  validator = require('validator');

module.exports = TokenModel;

var tokenSchema = new mongoose.Schema({
  value: {
    type: String,
    required: true
  },
  production: {
    type: Boolean,
    required: true
  },
  expires_at: {
    type: Date,
    required: true
  }
  created_at: Date,
  updated_at: Date
});

function TokenModel(options) {
  options = options || {};
  const db = mongoose.createConnection(options.dbHost);

  this.io = db.model('Token', tokenSchema);
}
