'use strict';

module.exports = ConvertService;

function ConvertService(options) {
  options = options || {};
  const logger = options.logger;

  this.convert = function(type, value) {
    if (type == 'STRING' || type == 'ENCODED') {
      if (typeof value != 'string')
        return new Error();
    }
    else if (type == 'NUMERIC' || type == 'PERCENT' || type == 'AMOUNT') {
      value = Number(value);
      if (isNaN(value))
        return new Error();
    }
    else if (type == 'DATE') {
      value = Date.parse(value);
      if (isNaN(value))
        return new Error();
    }
    else if (type == 'JSON') {
      if (typeof value === 'string') {
        try {
          value = JSON.parse(value);
        } catch(e) {
          return new Error();
        }
      }
      else if (typeof value !== 'object' || Array.isArray(value))
        return new Error();
    }
    else if (type == 'BOOLEAN') {
      if (typeof value === 'string') {
        if (value == 'true' || value == '1')
          value = true;
        else if (value == 'false' || value == '0')
          value = false;
        else
          value = new Error();
      }
      else if (typeof value === 'string') {
        if (value == 1)
          value = true;
        else if (value == 0)
          value = false;
        else
          value = new Error();
      }
      else
        return new Error();
    }
    else
      return new Error();
    return value;
  };
}