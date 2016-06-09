'use strict';

const mongoose = require('mongoose'),
  validator = require('validator');

module.exports = UserModel;

var userSchema = new mongoose.Schema({
  firstname: {
    type: String,
    required: [true, 'Prénom obligatoire']
  },
  lastname: {
    type: String,
    required: [true, 'Nom obligatoire']
  },
  email: {
    type: String,
    required: [true, 'Adresse E-Mail obligatoire'],
    unique: [true, 'Cette adresse E-Mail est déjà utilisée'],
    validate: {
      validator: function (email) {
        return validator.isEmail(email);
      },
      message: 'Adresse E-Mail invalide'
    }
  },
  password: {
    type: String,
    required: [true, 'Mot de passe obligatoire'],
    minlength: [10, 'Le mot de passe doit comporter au minimum 10 caractères']
  },
  created_at: Date,
  updated_at: Date
});

function UserModel(options) {
  options = options || {};
  const db = mongoose.createConnection(options.dbHost);

  this.io = db.model('User', userSchema);
}
