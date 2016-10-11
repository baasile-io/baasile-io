'use strict';

const testHelper = require('../test.helper.js'),
  TestHelper = new testHelper(),
  convertService = require('../../services/convert.service.js'),
  ConvertService = new convertService(TestHelper.getOptions());

describe('ConvertService', function () {

  before(TestHelper.seedDb);

  describe('convert', function () {

    it('invalid type', function(done) {
      if (!(ConvertService.convert('INVALID_TYPE') instanceof Error))
        throw new Error('should return Error');

      done();
    });

    ['STRING', 'ENCODED'].forEach(function(type) {
      it(type, function (done) {
        var value;

        if (!((value = ConvertService.convert(type, 42)) instanceof Error))
          throw new Error('Number is not '+type);

        if (!((value = ConvertService.convert(type, {})) instanceof Error))
          throw new Error('Object is not '+type);

        if ((value = ConvertService.convert(type, 'my string')) instanceof Error)
          throw new Error('String is '+type);

        if (value != 'my string')
          throw new Error('wrong conversion');

        done();
      });
    });

    ['NUMERIC', 'AMOUNT', 'PERCENT'].forEach(function(type) {
      it(type, function (done) {
        var value;

        if ((value = ConvertService.convert(type, 42)) instanceof Error)
          throw new Error('Number is ' + type);

        if ((value = ConvertService.convert(type, "42")) instanceof Error)
          throw new Error('String "42" is ' + type);

        if (value != 42)
          throw new Error('wrong conversion');

        if ((value = ConvertService.convert(type, "99.99")) instanceof Error)
          throw new Error('String "99.99" is ' + type);

        if (value != 99.99)
          throw new Error('wrong conversion');

        if (!((value = ConvertService.convert(type, {})) instanceof Error))
          throw new Error('Object is not ' + type);

        if (!((value = ConvertService.convert(type, 'my string'))) instanceof Error)
          throw new Error('String is not ' + type);

        done();
      });
    });

    it('BOOLEAN', function (done) {
      var value;

      if (!((value = ConvertService.convert('BOOLEAN', 2)) instanceof Error))
        throw new Error('Number is not BOOLEAN');

      if (!((value = ConvertService.convert('BOOLEAN', {})) instanceof Error))
        throw new Error('Object is not BOOLEAN');

      if (!((value = ConvertService.convert('BOOLEAN', "hello")) instanceof Error))
        throw new Error('String is not BOOLEAN');

      if ((value = ConvertService.convert('BOOLEAN', "1")) instanceof Error)
        throw new Error('"1" is BOOLEAN');

      if (value != true)
        throw new Error('wrong conversion');

      if ((value = ConvertService.convert('BOOLEAN', "0")) instanceof Error)
        throw new Error('"0" is BOOLEAN');

      if (value != false)
        throw new Error('wrong conversion');

      if ((value = ConvertService.convert('BOOLEAN', "true")) instanceof Error)
        throw new Error('"true" is BOOLEAN');

      if (value != true)
        throw new Error('wrong conversion');

      if ((value = ConvertService.convert('BOOLEAN', "false")) instanceof Error)
        throw new Error('"false" is BOOLEAN');

      if (value != false)
        throw new Error('wrong conversion');

      done();
    });

    it('DATE', function (done) {
      var value;

      if (!((value = ConvertService.convert('DATE', {})) instanceof Error))
        throw new Error('Object is not DATE');

      if (!((value = ConvertService.convert('DATE', "hello")) instanceof Error))
        throw new Error('String is not DATE');

      if ((value = ConvertService.convert('DATE', 0)) instanceof Error)
        throw new Error('0 is DATE');

      if ((value = ConvertService.convert('DATE', "0")) instanceof Error)
        throw new Error('1 is DATE');

      if ((value = ConvertService.convert('DATE', "Mon, 25 Dec 1995 13:30:00 GMT")) instanceof Error)
        throw new Error('"Mon, 25 Dec 1995 13:30:00 GMT" is DATE');
      if (value !== Date.parse("Mon, 25 Dec 1995 13:30:00 GMT"))
        throw new Error('wrong conversion');

      if ((value = ConvertService.convert('DATE', "2011-10-10T14:48:00")) instanceof Error)
        throw new Error('"2011-10-10T14:48:00" is DATE');
      if (value !== Date.parse("2011-10-10T14:48:00"))
        throw new Error('wrong conversion');

      if ((value = ConvertService.convert('DATE', "2011-10-10")) instanceof Error)
        throw new Error('"2011-10-10" is DATE');
      if (value !== Date.parse("2011-10-10"))
        throw new Error('wrong conversion');

      done();
    });

    it('JSON', function (done) {
      var value;

      if ((value = ConvertService.convert('JSON', {})) instanceof Error)
        throw new Error('Object is JSON');

      if ((value = ConvertService.convert('JSON', {"test": "test"})) instanceof Error)
        throw new Error('Object is JSON');

      if ((value = ConvertService.convert('JSON', "{}")) instanceof Error)
        throw new Error('valid string is JSON');

      if (!((value = ConvertService.convert('JSON', "{sqdksqhd")) instanceof Error))
        throw new Error('invalid string is not JSON');

      if (!((value = ConvertService.convert('JSON', 42)) instanceof Error))
        throw new Error('Number is not JSON');

      if (!((value = ConvertService.convert('JSON', [])) instanceof Error))
        throw new Error('Array is not JSON');

      done();
    });

  });

});
