'use strict';

const testHelper = require('../../test.helper.js'),
  TestHelper = new testHelper(),
  fieldModel = require('../../../models/v1/Field.model.js'),
  FieldModel = new fieldModel(TestHelper.getOptions());

describe('Field model', function () {

  before(TestHelper.seedDb);

  describe('Validation', function () {

    it('required attributes', function (done) {
      var field = new FieldModel.io();
      field.save(function(err) {
        if (!err)
          throw new Error('field should not have been saved');
        err.errors.should.have.property('creator');
        err.errors.creator.message.should.eql('Path `creator` is required.');
        err.errors.should.have.property('clientId');
        err.errors.clientId.message.should.eql('Path `clientId` is required.');
        err.errors.should.have.property('routeId');
        err.errors.routeId.message.should.eql('Path `routeId` is required.');
        err.errors.should.have.property('route');
        err.errors.route.message.should.eql('Path `route` is required.');
        err.errors.should.have.property('type');
        err.errors.type.message.should.eql('Le type est obligatoire');
        err.errors.should.have.property('required');
        err.errors.required.message.should.eql('Path `required` is required.');
        err.errors.should.have.property('description');
        err.errors.description.message.should.eql('La description est obligatoire');
        err.errors.should.have.property('name');
        err.errors.name.message.should.eql('Le nom est obligatoire');

        field.creator = {_id: TestHelper.getUsers()[0]._id};
        field.clientId = 'clientId';
        field.routeId = 'routeId';
        field.route = {_id: TestHelper.getServices()[0].routesArray[0]._id};
        field.type = 'STRING';
        field.required = true;
        field.description = 'description';
        field.name = 'name';
        field.save(function(err, newField) {
          if (err)
            return done(err);
          newField.creator.should.eql(TestHelper.getUsers()[0]._id);
          newField.clientId.should.eql('clientId');
          newField.routeId.should.eql('routeId');
          newField.route.should.eql(TestHelper.getServices()[0].routesArray[0]._id);
          newField.type.should.eql('STRING');
          newField.required.should.eql(true);
          newField.description.should.eql('description');
          newField.name.should.eql('name');
          done();
        });
      });
    });

    describe('Name / NameNormalized', function() {

      it('accept uppercase', function(done) {
        var field = new FieldModel.io();
        field.name = 'MyName';
        field.save(function(err) {
          if (!err)
            throw new Error('field should not have been saved');
          field.name.should.eql('MyName');
          field.nameNormalized.should.eql('MyName');

          field.creator = {_id: TestHelper.getUsers()[0]._id};
          field.clientId = 'clientId';
          field.routeId = 'routeId';
          field.route = {_id: TestHelper.getServices()[0].routesArray[0]._id};
          field.type = 'STRING';
          field.required = true;
          field.description = 'description';
          field.save(function(err, newField) {
            if (err)
              return done(err);
            field.name.should.eql('MyName');
            field.nameNormalized.should.eql('MyName');
            done();
          });
        });
      });

    });

  });

});
