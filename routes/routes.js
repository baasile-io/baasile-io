'use strict';

const v1 = require('./v1/index.js');

exports.configure = function (app, options) {
  app.use('/v1', v1(options));
};
