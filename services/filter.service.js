'use strict';

const StandardError = require('standard-error');

module.exports = FilterService;

function FilterService(options) {
  const CONDITIONAL_OPERATORS = ['$and', '$or', '$nor'];
  
  const DEFAULT_TYPE = 'STRING';
  
  
  
  const COND_TYPES = {
    'ID': ["$eq"],
    'STRING': ["$eq", "$ne", "$regex", "$in", "$nin"],
    'NUMERIC': ["$eq", "$ne", "$gt", "$lt", "$gte", "$lte", "$in", "$nin"],
    'PERCENT': ["$eq", "$ne", "$gt", "$lt", "$gte", "$lte", "$in", "$nin"],
    'AMOUNT': ["$eq", "$ne", "$gt", "$lt", "$gte", "$lte", "$in", "$nin"],
    'BOOLEAN': ["$eq", "$ne"],
    'DATE': ["$eq", "$ne", "$gt", "$lt", "$gte", "$lte", "$in", "$nin"],
    'ENCODED': ["$eq", "$ne"],
    'JSON': ["$eq", "$ne"]
  };
  options = options || {};
  const logger = options.logger;
  
  //  ******  outils  *******  //
  
  function getTabByKeyVal(key, val, myArray) {
    if (key === undefined || val === undefined || myArray === undefined)
      return undefined;
    for (var i = 0; i < myArray.length; i++) {
      if (myArray[i][key] === val) {
        return myArray[i];
      }
    }
    return undefined;
  }
  
  function getValIfValExistInArray(value, listfields) {
    if (typeof listfields === 'undefined')
      return value;
    var typeTab = getTabByKeyVal("name", value, listfields);
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
      var objson = getTabByKeyVal("name", getValIfValExistInArray(value, listfields), listfields);
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
      var objson = getTabByKeyVal("name", getValIfValExistInArray(value, listfields), listfields);
      if (objson === undefined)
        return undefined;
      return objson.key;
    }
  }
  
  function isKeyCondOkForThisTypeOfValue(key, value, listfields, errors) {
    var type = getTableTypeOf(value, listfields);
    if (type === undefined)
    {
      errors.push("value : " + value + " is not a field in your model");
      return false;
    }
    else if (type.indexOf(key) === -1)
    {
      errors.push("key : " + key + " is not a possible condition for the type: " + getTypeOf(value, listfields));
      return false;
    }
    return true;
    
  }
  
  function getConvertValueByTypeKeyname(val, keyname, listfields, errors) {
    var type = getTypeOf(keyname, listfields);
    if (type === undefined)
      errors.push("value : " + keyname + " is not a field in your model");
    if (type == 'NUMERIC' || type == 'PERCENT' || type == 'AMOUNT') {
      var res = Number(val);
      if (!isNaN(res))
        return Number(val);
      errors.push("the value: " + val + " is not a valide NUMBER");
      return undefined;
    }
    else {
      return val;
    }
  }
  
  function getRealKeyNeeded(key, obj)
  {
    if (key === '$ne' && Array.isArray(obj) === true)
      return "$nin";
    if (key === '$eq' && Array.isArray(obj) === true)
      return "$in";
    return key;
  }
  
  function canBeMultiVal(key)
  {
    return (key === "$nin" || key === "$in" || key === "$or" || key === "$and" || key === "$regex" || key === "$nor");
  }
  
  function mergeObj(obj1,obj2){
    var obj3 = {};
    for (var attrname in obj1) { obj3[attrname] = obj1[attrname]; }
    for (var attrname in obj2) { obj3[attrname] = obj2[attrname]; }
    return obj3;
  }

// ******************************* //

// ************* algo ************ //
  
  function fillJsonObjWithKeyAfter(jsonRes, key, val, obj, listfields, errors) {
    if (CONDITIONAL_OPERATORS.indexOf(key) != -1) {
      jsonRes = getConditionBefore(val, obj, listfields, errors);
    } else if (isKeyCondOkForThisTypeOfValue(key, val, listfields, errors)) {
      if ( typeof  obj[key] === 'object' && canBeMultiVal(getRealKeyNeeded(key, obj[key])))
      {
        var jsontab = [];
        Object.keys(obj[key]).forEach(function (key1) {
          jsontab.push(getConvertValueByTypeKeyname(obj[key][key1], val, listfields,errors));
          
        });
        jsonRes[getRealKeyNeeded(key, obj[key])] = jsontab;
      }
      else {
        jsonRes[getRealKeyNeeded(key, obj[key])] = getConvertValueByTypeKeyname(obj[key], val, listfields, errors);
      }
    }
    return jsonRes;
  }
  
  function getConditionAfter(val, obj, listfields, errors) {
    var jsonRes = {};
    var value;
    Object.keys(obj).forEach(function (key) {
      if (key[0] === '$') {
        jsonRes = fillJsonObjWithKeyAfter(jsonRes, key, val, obj, listfields, errors);
      }
      else if ((value = getValIfValExistInArray(key, listfields)) !== undefined)
      {
        jsonRes[value] = (getConditionAfter(value, obj[key], listfields, errors));
      }
      else {
        errors.push("key: "+ key + " need to be a condition started with '$'");
        jsonRes = undefined;
        return undefined;
      }
    });
    return (jsonRes);
  }
  
  function getConditionBeforeArray(currentKey, array, listfields, errors) {
    var jsontab = [];
    for(var i = 0; i < array.length; i++) {
      var value = array[i];
      if (typeof value !== 'object') {
        value = {'$eq': value};
      }
      var res = getConditionAfter(currentKey, value, listfields, errors);
      if (res === undefined) {
        return undefined;
      }
      else if (Array.isArray(res) === true) {
        jsontab = jsontab.concat(res);
      }
      else {
        jsontab.push(res);
      }
    }
    return jsontab;
  }
  
  function fillJsonObjWithKeyBefore(jsonRes, currentKey, key, obj, listfields, errors) {
    jsonRes[getRealKeyNeeded(key, obj[key])] = getConditionBefore(currentKey, obj[key], listfields, errors);
    if (jsonRes[getRealKeyNeeded(key, obj[key])] === undefined || !isKeyCondOkForThisTypeOfValue(key, jsonRes[key], listfields, errors)) {
      return undefined;
    }
    return jsonRes;
  }
  
  function getConditionBeforeObjOperator(jsontab, currentKey, key, obj, listfields, errors) {
    var jsonRes = {};
    jsonRes = fillJsonObjWithKeyBefore(jsonRes, currentKey, key, obj, listfields, errors);
    if (jsonRes === undefined)
      return undefined;
    if (currentKey !== null) {
      return jsonRes;
    }
    else {
      jsontab.push(jsonRes);
    }
    return jsontab;
  }
  
  function getConditionBeforeObjSpeOp(jsontab, currentKey, key, obj, listfields, errors) {
    var kval = getValIfValExistInArray(key, listfields, errors);
    if (kval === undefined) {
      errors.push("value : " + key + " is not a field in your model");
      return (undefined);
    }
    if (typeof obj[kval] !== 'object') {
      obj[kval] = {'$eq': obj[kval]};
    }
    if (Array.isArray(obj[kval]) === true) {
      for (var i = 0; i < obj[kval].length; i++) {
        var value = obj[kval][i];
        if (typeof value !== 'object') {
          value = {'$eq': value};
        }
        var jsonRes = {};
        jsonRes[getRealKeyNeeded(key, obj[key])] = getConditionAfter(kval, value, listfields, errors);
        jsontab.push(jsonRes);
      }
    } else {
      var jsonRes = {};
      jsonRes[kval] = getConditionAfter(kval, obj[kval], listfields, errors);
      jsontab.push(jsonRes);
    }
    return jsontab;
  }
  
  function getConditionBeforeObj(currentKey, array, listfields, errors) {
    var jsontab = [];
    Object.keys(array).forEach(function (key) {
      var jsonRes = {};
      if (CONDITIONAL_OPERATORS.indexOf(key) != -1) {
        jsontab = getConditionBeforeObjOperator(jsontab, currentKey, key, array, listfields, errors);
        if (jsontab === undefined)
          return undefined;
      }
      else if (key[0] !== '$') {
        if ((getConditionBeforeObjSpeOp(jsontab, currentKey, key, array, listfields, errors)) === undefined) {
          jsontab = undefined;
          return undefined;
        }
      }
      else {
        var jsonRes2 = {};
        jsonRes2[key] = array[key];
        var jsontmp = getConditionAfter(currentKey, jsonRes2, listfields, errors);
        if (jsontmp === undefined) {
          jsontab = undefined;
          return undefined;
        }
        jsontab.push(jsontmp);
      }
    });
    return jsontab;
  }
  
  function getConditionBefore(currentKey, array, listfields, errors) {
    var jsontab = [];
    if (Array.isArray(array) === true) {
      var tabtmp = [];
      if ((tabtmp = getConditionBeforeArray(currentKey, array, listfields, errors)) === undefined)
        return undefined;
      jsontab = jsontab.concat(tabtmp);
    } else if (typeof array === 'object') {
      var tabtmp = [];
      if ((tabtmp = getConditionBeforeObj(currentKey, array, listfields, errors)) === undefined)
        return undefined;
      if (currentKey !== null && currentKey !== undefined) {
        return tabtmp;
      }
      jsontab = jsontab.concat(tabtmp);
    }
    return jsontab;
  }
  
  this.buildMongoQuery = function (jsonRes, filters, listfields) {
    var errors = [];
    if (typeof filters !== 'undefined') {
      var jsonVal = {};
      jsonVal["$and"] = getConditionBefore(null, filters, listfields, errors);
      if (jsonVal["$and"] === undefined || errors.length > 0 )
      {
        errors.unshift("filters error");
        jsonVal["ERRORS"] = errors;
      }
      if (jsonRes !== undefined && Object.keys(jsonRes).length > 0)
      {
        if (jsonVal["$and"] !== undefined)
          jsonVal["$and"].unshift(jsonRes);
        else {
          jsonVal = jsonRes;
        }
      }
    }
    else {
      jsonVal = jsonRes;
    }
    return jsonVal;
  }
}
