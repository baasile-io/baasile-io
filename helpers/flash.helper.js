'use strict';

const _ = require('lodash');

module.exports = FlashHelper;

function FlashHelper(options) {
  options = options || {};
  const logger = options.logger;

  this.get = function(session, callback) {
    const flash = session.flash || {};
    session.flash = null;
    session.save(function(err) {
      callback(err, flash);
    });
  };

  this.addError = function(session, err, callback) {
    session.flash = session.flash || {};
    session.flash.errors = session.flash.errors || [];
    if (Array.isArray(err))
      _.merge(session.flash.errors, err);
    else
      session.flash.errors.push(err);
    session.save(function(err) {
      callback(err);
    });
  };

  this.addSuccess = function(session, msg, callback) {
    session.flash = session.flash || {};
    if (!Array.isArray(msg) && typeof msg == 'object')
      session.flash.success = msg;
    else {
      session.flash.success = session.flash.success || [];
      if (Array.isArray(msg))
        _.merge(session.flash.success, msg);
      else
        session.flash.success.push(msg);
    }
    session.save(function(err) {
      callback(err);
    });
  };

  this.addParam = function(session, name, value, callback) {
    session.flash = session.flash || {};
    session.flash.params = session.flash.params || {};
    session.flash.params[name] = value;
    session.save(function(err) {
      callback(err);
    });
  };
};
