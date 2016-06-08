'use strict';

const mongoose = require('mongoose');

module.exports = UserModel;

var userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  created_at: Date,
  updated_at: Date
});

function UserModel(options) {
  options = options || {};
  const db = mongoose.connect(options.dbHost);

  return db.model('User3', userSchema);
}
