'use strict';

const testHelper = require('../../test.helper.js'),
  TestHelper = new testHelper(),
  userModel = require('../../../models/v1/user.model.js'),
  UserModel = new userModel(TestHelper.getOptions());

describe('User model', function () {

  before(TestHelper.seedDb);

  describe('Validation', function () {

    it('required attributes', function (done) {
      var user = new UserModel.io();
      user.save(function(err) {
        if (!err)
          throw new Error('user should not have been saved');
        err.errors.should.have.property('firstname');
        err.errors.firstname.message.should.eql('Prénom obligatoire');
        err.errors.should.have.property('lastname');
        err.errors.lastname.message.should.eql('Nom obligatoire');
        err.errors.should.have.property('email');
        err.errors.email.message.should.eql('Adresse E-Mail obligatoire');
        err.errors.should.have.property('password');
        err.errors.password.message.should.eql('Mot de passe obligatoire');

        user.firstname = 'First name';
        user.lastname = 'Last name';
        user.email = 'email@email.com';
        user.password = 'password10';
        user.save(function(err, newUser) {
          if (err)
            return done(err);
          newUser.firstname.should.eql('First name');
          newUser.lastname.should.eql('Last name');
          newUser.email.should.eql('email@email.com');
          newUser.password.should.eql('password10');
          done();
        });
      });
    });

    describe('E-Mail', function() {

      it('does not accept invalid email', function(done) {
        var user = new UserModel.io();
        user.email = 'invalidemail';
        user.save(function(err) {
          if (!err)
            throw new Error('user should not have been saved');
          err.errors.should.have.property('email');
          err.errors.email.message.should.eql('Adresse E-Mail invalide');

          user.email = 'still@invalidemail';
          user.save(function(err) {
            if (!err)
              throw new Error('user should not have been saved');
            err.errors.should.have.property('email');
            err.errors.email.message.should.eql('Adresse E-Mail invalide');

            user.email = 'email@email.com';
            user.save(function (err) {
              if (!err)
                throw new Error('user should not have been saved');
              err.errors.should.not.have.property('email');
              done();
            });
          });
        });
      });

    });

  });

});
