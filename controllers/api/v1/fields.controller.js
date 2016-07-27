'use strict';

const fieldModel = require('../../../models/v1/Field.model.js');

module.exports = FieldsController;

function FieldsController(options) {
  options = options || {};
  const logger = options.logger;
  const FieldModel = new fieldModel(options);

  this.getFields = function(req, res, next) {
    var fields = [];
    FieldModel.io.find({
        route: req.data.route._id
      })
      .sort({order: 1})
      .stream()
      .on('data', function(element) {
        var self = this;
        self.pause();
        var elementData = element.getResourceObject(res._apiuri);
        fields.push(elementData);
        self.resume();
      })
      .on('error', function(err) {
        next({code: 500});
      })
      .on('end', function() {
        next({code: 200, data: fields});
      });
  };
};