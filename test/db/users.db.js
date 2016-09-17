'use strict';

const users = require('./db.js').USERS,
  userModel = require('../../models/v1/User.model.js');

module.exports = UsersDb;

function UsersDb(options) {
  options = options || {};

  const UserModel = new userModel(options);

  var db = [];

  this.seed = function() {
    return new Promise(function(resolve, reject) {
      var i = 0;

      function insert() {
        if (i == users.length)
          return resolve(db);

        // seed default values
        users[i].createdAt = users[i].createdAt || new Date();

        UserModel.io.create(users[i], function(err, user) {
          if (err)
            return reject(err);

          db.push(user);

          i++;
          return insert();
        });
      };

      return insert();
    });
  };

  this.drop = function() {
    return new Promise(function(resolve, reject) {
      UserModel.io.remove({}, function (err) {
        if (err)
          return reject(err);

        return resolve();
      });
    });
  };
};