'use strict';

const mongoose = require('mongoose'),
  validator = require('validator'),
  crypto = require('crypto');

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

  userSchema.pre('update', function(next) {
    this.options.runValidators = true;
    next();
  });

  this.io = db.model('User', userSchema);

  function sha256(str) {
    return crypto.createHash('sha256').update(str).digest('hex');
  }

  function generateSalt()
  {
    const set = '0123456789abcdefghijklmnopqurstuvwxyzABCDEFGHIJKLMNOPQURSTUVWXYZ';
    var salt = '';
    for (var i = 0; i < 10; i++) {
      let p = Math.floor(Math.random() * set.length);
      salt += set[p];
    }
    return salt;
  }

  this.saltAndHash = function(pass)
  {
    const salt = generateSalt();
    return (salt + sha256(pass + salt));
  }

  this.validatePassword = function(plainPass, hashedPass)
  {
    const salt = hashedPass.substr(0, 10);
    const validHash = salt + sha256(plainPass + salt);
    return (hashedPass === validHash);
  }

}
