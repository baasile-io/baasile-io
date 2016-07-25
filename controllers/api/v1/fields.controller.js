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
      },
      {
        _id: 0,
        fieldId: 1,
        order: 1,
        nameNormalized: 1,
        description: 1,
        required: 1
      })
      .sort({order: 1})
      .stream()
      .on('data', function(element) {
        var self = this;
        self.pause();
        var elementData = {
          id: element.fieldId,
          type: 'champs',
          attributes: {
            position: element.order,
            nom: element.nameNormalized,
            description: element.description,
            obligatoire: element.required
          }
        };
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