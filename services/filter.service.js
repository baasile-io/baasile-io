'use strict';

const StandardError = require('standard-error');

module.exports = FilterService;

function FilterService(options) {
  const CONDITIONAL_OPERATORS = ['$and', '$or'];

  const DEFAULT_TYPE = 'STRING';

  const COND_TYPES = {
    'ID': ["$eq"],
    'STRING': ["$eq", "$ne", "$regex", "$in", "$nin"],
    'NUMERIC': ["$eq", "$gt", "$lt", "$gte", "$lte"],
    'PERCENT': ["$eq", "$gt", "$lt", "$gte", "$lte"],
    'AMOUNT': ["$eq", "$gt", "$lt", "$gte", "$lte"],
    'BOOLEAN': ["$eq"],
    'DATE': ["$eq", "$gt", "$lt", "$gte", "$lte"],
    'ENCODED': ["$eq"],
    'JSON': ["$eq"]
  };
  options = options || {};
  const logger = options.logger;


  // const FIELD_TYPES = [
  //   {key: 'STRING', name: 'prenom'},
  //   {key: 'STRING', name: 'name'},
  //   {key: 'NUMERIC', name: 'age'}
  // ];

  function searchByVal(key, nameKey, myArray) {
    if (key === undefined || nameKey === undefined || myArray === undefined)
      return undefined;
    for (var i = 0; i < myArray.length; i++) {
      if (myArray[i][key] === nameKey) {
        return myArray[i];
      }
    }
    return undefined;
  }

  function searchBykey(nameKey, myArray) {
    if (nameKey === undefined || myArray === undefined)
      return undefined;
    for (var i = 0; i < myArray.length; i++) {
      if (myArray[i] === nameKey) {
        return myArray[i];
      }
    }
    return undefined;
  }

  function getValIfValExist(value, listfields) {
    if (typeof listfields === 'undefined')
      return value;
    var typeTab = searchByVal("name", value, listfields);
    if (typeTab !== undefined) {
      return value;
    }
    else {
      return (undefined);
    }
  }

  function getTableTypeOf(value, listfields) {
    if ((value === undefined) || Array.isArray(value) || (value[0] == '$'))
      return CONDITIONAL_OPERATORS;
    else {
      if (typeof listfields === 'undefined')
        return COND_TYPES[DEFAULT_TYPE];
      var objson = searchByVal("name", getValIfValExist(value, listfields), listfields);
      if (objson === undefined)
        return undefined;
      return COND_TYPES[objson.key];
    }
  }

  function getTypeOf(value, listfields) {
    if (typeof listfields === 'undefined')
      return DEFAULT_TYPE;
    if ((value === undefined) || Array.isArray(value) || (value[0] == '$'))
      return undefined;
    else {
      var objson = searchByVal("name", getValIfValExist(value, listfields), listfields);
      if (objson === undefined)
        return undefined;
      return objson.key;
    }
  }

  function tryKeyByType(key, value, listfields) {
    var type = getTableTypeOf(value, listfields);
    if (type !== undefined && (type.indexOf(key) != -1)) {
      return true;
    }
    return false;
  }

  function getValueByFieldType(val, keyname, listfields) {
    var type = getTypeOf(keyname, listfields);
    if (type == 'NUMERIC' || type == 'PERCENT' || type == 'AMOUNT')
      return Number(val);
    else {
      return val;
    }
  }

  function getConditionAfter(val, obj, listfields) {

    var jsonRes = {};
    Object.keys(obj).forEach(function (key) {
      if (key[0] === '$') {
        if (CONDITIONAL_OPERATORS.indexOf(key) != -1) {
          jsonRes = getConditionBefore(val, obj, listfields);
        } else if (tryKeyByType(key, val, listfields)) {
          jsonRes[key] = getValueByFieldType(obj[key], val, listfields);
        }
      }
      else {
        return undefined;
      }
    });
    return (jsonRes);
  }

  function getConditionBefore(currentKey, array, listfields) {
    var jsontab = [];
    if (Array.isArray(array) === true) {
      for(var i = 0; i < array.length; i++) {
        var value = array[i];
        if (typeof value !== 'object') {
          value = {'$eq': value};
        }
        jsontab.push(getConditionAfter(currentKey, value, listfields));
      }
    } else {
      Object.keys(array).forEach(function (key) {
        var jsonRes = {};
        if (CONDITIONAL_OPERATORS.indexOf(key) != -1) {
          jsonRes[key] = getConditionBefore(currentKey, array[key], listfields);
          if (jsonRes[key] === undefined || !tryKeyByType(key, jsonRes[key], listfields)) {
            return undefined;
          }
          if (currentKey !== null) {
            jsontab = jsonRes;
          }
          else
            jsontab.push(jsonRes);
        }
        else if (key[0] !== '$') {
          var kval = getValIfValExist(key, listfields);
          if (kval === undefined)
            return (undefined);
          if (typeof array[kval] !== 'object') {
            array[kval] = {'$eq': array[kval]};
          }
          if (Array.isArray(array[kval]) === true) {
            for (var i = 0; i < array[kval].length; i++) {
              var value = array[kval][i];
              if (typeof value !== 'object') {
                value = {'$eq': value};
              }
              var jsonRes = {};
              jsonRes[kval] = getConditionAfter(kval, value, listfields);
              jsontab.push(jsonRes);
            }
          } else {
            jsonRes[kval] = getConditionAfter(kval, array[kval], listfields);
            jsontab.push(jsonRes);
          }
        }
        else {
          var jsonRes2 = {};
          jsonRes2[key] = array[key];
          jsontab.push(getConditionAfter(currentKey, jsonRes2, listfields));
        }
      });
    }
    return jsontab;
  }

  this.buildMongoQuery = function (jsonRes, filters, listfields) {
    if (typeof filters !== 'undefined') {
      //var jsonVal = {};
      if ((jsonRes["$and"] = getConditionBefore(null, filters, listfields)) === undefined)
        return undefined;
    }
    return jsonRes;
  }
}
