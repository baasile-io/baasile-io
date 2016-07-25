'use strict';

const request = require('request'),
  _ = require('lodash'),
  fieldModel = require('../../models/v1/Field.model.js'),
  flashHelper = require('../../helpers/flash.helper.js');

module.exports = FieldsController;

function FieldsController(options) {
  options = options || {};
  const logger = options.logger;
  const FieldModel = new fieldModel(options);
  const FlashHelper = new flashHelper(options);

  this.index = function(req, res) {
    if (req.data.route.fields.length == 0)
      return res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/fields/new');
    FieldModel.io.find({route: req.data.route})
      .sort({createdAt: -1})
      .exec(function(err, fields) {
        if (err)
          next(err);
        return res.render('pages/dashboard/fields/index', {
          page: 'pages/dashboard/fields/index',
          csrfToken: req.csrfToken(),
          data: req.data,
          fields: fields,
          flash: res._flash
        });
      });
  };

  this.new = function(req, res, next) {
    return res.render('pages/dashboard/fields/new', {
      page: 'pages/dashboard/fields/new',
      csrfToken: req.csrfToken(),
      data: req.data,
      fieldTypes: FieldModel.getFieldTypes(),
      query: {
        field: {}
      },
      flash: res._flash
    });
  };

  this.edit = function(req, res) {
    return res.render('pages/dashboard/fields/edit', {
      page: 'pages/dashboard/fields/edit',
      csrfToken: req.csrfToken(),
      fieldTypes: FieldModel.getFieldTypes(),
      query: {
        field: req.data.field
      },
      data: req.data,
      flash: res._flash
    });
  };

  this.create = function(req, res, next) {
    const fieldName = _.trim(req.body.field_name);
    const fieldNameNormalized = FieldModel.getNormalizedName(fieldName);
    const fieldDescription = _.trim(req.body.field_description);
    const fieldRequired = req.body.field_required === 'true';
    const fieldType = req.body.field_type;

    const fieldData = {
      fieldId: FieldModel.generateId(),
      type: fieldType,
      description: fieldDescription,
      name: fieldName,
      nameNormalized: fieldNameNormalized,
      required: fieldRequired,
      createdAt: new Date(),
      creator: {_id: req.data.user._id},
      route: req.data.route,
      order: req.data.route.fields.length
    };

    FieldModel.io.create(fieldData, function(err, route) {
      if (err) {
        return res.render('pages/dashboard/fields/new', {
          page: 'pages/dashboard/fields/new',
          csrfToken: req.csrfToken(),
          data: req.data,
          fieldTypes: FieldModel.getFieldTypes(),
          query: {
            field: {
              name: fieldName,
              description: fieldDescription,
              required: fieldRequired,
              type: fieldType
            }
          },
          flash: {
            errors: [err]
          }
        });
      } else {
        res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/fields');
      }
    });
  };

  this.update = function(req, res, next) {
    var field = req.data.field;
    const fieldName = _.trim(req.body.field_name);
    const fieldNameNormalized = FieldModel.getNormalizedName(fieldName);
    const fieldDescription = _.trim(req.body.field_description);
    const fieldRequired = req.body.field_required === 'true';
    const fieldType = req.body.field_type;

    const fieldData = {
      name: fieldName,
      nameNormalized: fieldNameNormalized,
      description: fieldDescription,
      required: fieldRequired,
      type: fieldType
    };

    field.name = fieldName;
    field.nameNormalized = fieldNameNormalized;
    field.description = fieldDescription;
    field.required = fieldRequired;
    field.type = fieldType;

    field.save(function(err, num) {
      if (err || num == 0) {
        return res.render('pages/dashboard/fields/edit', {
          page: 'pages/dashboard/fields/edit',
          csrfToken: req.csrfToken(),
          data: req.data,
          fieldTypes: FieldModel.getFieldTypes(),
          query: {
            field: fieldData
          },
          flash: {
            errors: [err]
          }
        });
      }
      logger.info('field updated: ' + fieldData.name);
      FlashHelper.addSuccess(req.session, 'Le champ a bien été mis à jour', function(err) {
        if (err)
          return next({code: 500});
        res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/fields');
      });
    });
  };

  this.up = function(req, res, next) {
    FieldModel.io
      .findOne({
        route: req.data.route,
        order: req.data.field.order - 1
      })
      .exec(function(err, prevField) {
        if (err)
          return next({code: 500});
        if (!prevField)
          return next({code: 500});
        FieldModel.io.update({
          _id: prevField.id
        }, {
          $set: {
            order: req.data.field.order
          }
        }, function(err) {
          if (err)
            return next({code: 500});
          FieldModel.io.update({
            _id: req.data.field.id
          }, {
            $set: {
              order: prevField.order
            }
          }, function(err) {
            if (err)
              return next({code: 500});
            ensureFieldsOrder(req.data.route, function(err) {
              if (err)
                return next({code: 500});
              res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/fields');
            });
          });
        });
      });
  };

  this.down = function(req, res, next) {
    FieldModel.io
      .findOne({
        route: req.data.route,
        order: req.data.field.order + 1
      })
      .exec(function(err, prevField) {
        if (err)
          return next({code: 500});
        if (!prevField)
          return next({code: 500});
        FieldModel.io.update({
          _id: prevField.id
        }, {
          $set: {
            order: req.data.field.order
          }
        }, function(err) {
          if (err)
            return next({code: 500});
          FieldModel.io.update({
            _id: req.data.field.id
          }, {
            $set: {
              order: prevField.order
            }
          }, function(err) {
            if (err)
              return next({code: 500});
            ensureFieldsOrder(req.data.route, function(err) {
              if (err)
                return next({code: 500});
              res.redirect('/dashboard/services/' + req.data.service.nameNormalized + '/routes/' + req.data.route.nameNormalized + '/fields');
            });
          });
        });
      });
  };

  function ensureFieldsOrder(route, callback) {
    var order = 0;
    FieldModel.io.find({route: route})
      .sort({order: 1})
      .stream()
      .on('data', function(field) {
        var self = this;
        self.pause();
        field.update({order: order}, function(err) {
          if (err)
            return self.destroy(err);
          self.resume();
        });
        order++;
      })
      .on('error', function(err) {
        callback(err);
      })
      .on('end', function() {
        callback();
      });
  };

  this.getFieldData = function(req, res, next) {
    FieldModel.io.findOne({
      route: req.data.route,
      fieldId: req.params.fieldId
    }, function(err, field) {
      if (err)
        return next({code: 500});
      if (!field)
        return next({code: 404});
      req.data = req.data || {};
      req.data.field = field;
      return next();
    });
  };
};
