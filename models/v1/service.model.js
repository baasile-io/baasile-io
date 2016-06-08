'use strict';

const mongoose = require('mongoose');

module.exports = ServiceModel;

var serviceSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
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
  const db = mongoose.connect(options.dbHost);

  this.data = function() {
    return db.model('Service', serviceSchema);
  }
}
