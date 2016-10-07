'use strict';

const StandardError = require('standard-error');

module.exports = FilterService;

function FilterService(options) {
  const CONDITIONAL_OPERATORS = ['$and', '$or', '$nor'];
  
  const SPE_OPERATORS = {'$text':['$search', '$language', '$caseSensitive', '$diacriticSensitive']};
  
  const SPE_COND_TYPES = {
    "$search" : "STRING",
    "$language" : "STRING",
    "$caseSensitive" : "BOOLEAN",
    "$diacriticSensitive" : "BOOLEAN"
  };
  
  const DEFAULT_TYPE = 'STRING';
  
  const COND_TYPES = {
    'ID': ["$eq"],
    'STRING': ["$eq", "$ne", "$regex", "$options", "$in", "$nin"],
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
  
  function getconvertedVal(val, type, param){
    switch (type)
    {
      case "ID":
        return val;
        break;
      case "STRING":
        return val;
        break;
      case "NUMERIC":
        var res = Number(val);
        if (!isNaN(res))
          return res;
        param["errors"].push("the value: " + val + " is not a valide NUMBER");
        return undefined;
        break;
      case "PERCENT":
        var res = Number(val);
        if (!isNaN(res))
          return res;
        param["errors"].push("the value: " + val + " is not a valide NUMBER");
        return undefined;
        break;
      case "AMOUNT":
        var res = Number(val);
        if (!isNaN(res))
          return res;
        param["errors"].push("the value: " + val + " is not a valide NUMBER");
        return undefined;
        break;
      case "BOOLEAN":
        if (val === "true" || val === "1")
          return true;
        else if (val === "false" || val === "0")
          return false;
        param["errors"].push("the value: " + val + " is not a valide BOOLEAN (true || 1 => true, false || 0 => false)");
        break;
      case "DATE":
        var res = Date(val);
        if ( isNaN( res.getTime() ) ) {
          param["errors"].push("the value: " + val + " is not a valide DATE");
          return undefined;
        }
        else {
          return res;
        }
        break;
      case "ENCODED":
        return val;
        break;
      case "JSON":
        var json = JSON.stringify(eval("(" + val + ")"));
        return json;
        break;
      default:
        param["errors"].push("do not know the type "+ type);
        break;
    };
  }
  
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
  
  function isKeyCondOkForThisTypeOfValue(key, value, listfields, param) {
    var type = getTableTypeOf(value, listfields);
    if (type === undefined)
    {
      param["errors"].push("value : " + value + " is not a field in your model");
      return false;
    }
    else if (type.indexOf(key) === -1)
    {
      param["errors"].push("key : " + key + " is not a possible condition for the type: " + getTypeOf(value, listfields));
      return false;
    }
    return true;
    
  }
  
  function getConvertValueByTypeKeyname(val, keyname, listfields, param) {
    var type = getTypeOf(keyname, listfields);
    if (type === undefined)
      param["errors"].push("value : " + keyname + " is not a field in your model");
    return getconvertedVal(val, type, param);
  }
  
  function getRealKeyNeeded(key, obj, objParent, param)
  {
    if (key === "$options" &&  !("$regex" in objParent)){
      param["errors"].push("options can only be with $regex");
    }
    if (key === '$ne' && Array.isArray(obj) === true)
      return "$nin";
    if (key === '$eq' && Array.isArray(obj) === true)
      return "$in";
    return key;
  }
  
  function canBeMultiVal(key)
  {
    return (key === "$nin" || key === "$in" || key === "$or" || key === "$and" || key === "$nor");
  }
  
  function mergeObj(obj1,obj2){
    var obj3 = {};
    for (var attrname in obj1) { obj3[attrname] = obj1[attrname]; }
    for (var attrname in obj2) { obj3[attrname] = obj2[attrname]; }
    return obj3;
  }
  
// ******************************* //

// ************* algo ************ //
  
  function addObjOptionIfNeeded(jsonRes, key, obj, param )
  {
    if (key == "$regex" && !("$options" in obj) && param["gOption"] !== undefined) {
      jsonRes["$options"] = param["gOption"];
    }
    return jsonRes;
  }
  
  function fillJsonObjWithKeyAfter(jsonRes, key, val, obj, listfields, param) {
    if (CONDITIONAL_OPERATORS.indexOf(key) != -1) {
      jsonRes = getConditionBefore(val, obj, listfields, param);
    } else if (isKeyCondOkForThisTypeOfValue(key, val, listfields, param)) {
      if ( typeof  obj[key] === 'object' && canBeMultiVal(getRealKeyNeeded(key, obj[key], obj, param)))
      {
        var jsontab = [];
        Object.keys(obj[key]).forEach(function (key1) {
          jsontab.push(getConvertValueByTypeKeyname(obj[key][key1], val, listfields,param));
          
        });
        jsonRes[getRealKeyNeeded(key, obj[key], obj, param)] = jsontab;
        jsonRes = addObjOptionIfNeeded(jsonRes, key, obj, param );
      }
      else {
        jsonRes[getRealKeyNeeded(key, obj[key], obj, param)] = getConvertValueByTypeKeyname(obj[key], val, listfields, param);
        jsonRes = addObjOptionIfNeeded(jsonRes, key, obj, param );
      }
    }
    return jsonRes;
  }
  
  function getConditionAfter(val, obj, listfields, param) {
    var jsonRes = {};
    var value;
    Object.keys(obj).forEach(function (key) {
      if (key[0] === '$') {
        jsonRes = fillJsonObjWithKeyAfter(jsonRes, key, val, obj, listfields, param);
      }
      else if ((value = getValIfValExistInArray(key, listfields)) !== undefined)
      {
          jsonRes[value] = (getConditionAfter(value, obj[key], listfields, param));
      }
      else {
        param["errors"].push("key: "+ key + " need to be a condition started with '$'");
        jsonRes = undefined;
        return undefined;
      }
    });
    return (jsonRes);
  }
  
  function getConditionBeforeArray(currentKey, array, listfields, param) {
    var jsontab = [];
    for(var i = 0; i < array.length; i++) {
      var value = array[i];
      if (typeof value !== 'object') {
        value = {'$eq': value};
      }
      var res = getConditionAfter(currentKey, value, listfields, param);
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
  
  function fillJsonObjWithKeyBefore(jsonRes, currentKey, key, obj, listfields, param) {
    jsonRes[getRealKeyNeeded(key, obj[key], obj, param)] = getConditionBefore(currentKey, obj[key], listfields, param);
    jsonRes = addObjOptionIfNeeded(jsonRes, key, obj, param );
    if (jsonRes[getRealKeyNeeded(key, obj[key], obj, param)] === undefined || !isKeyCondOkForThisTypeOfValue(key, jsonRes[key], listfields, param)) {
      return undefined;
    }
    return jsonRes;
  }
  
  function getConditionBeforeObjOperator(jsontab, currentKey, key, obj, listfields, param) {
    var jsonRes = {};
    jsonRes = fillJsonObjWithKeyBefore(jsonRes, currentKey, key, obj, listfields, param);
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
  
  function getConditionBeforeObjSpeOp(jsontab, currentKey, key, obj, listfields, param) {
    var kval = getValIfValExistInArray(key, listfields, param);
    if (kval === undefined) {
      param["errors"].push("value : " + key + " is not a field in your model");
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
        jsonRes[getRealKeyNeeded(key, obj[key], obj, param)] = getConditionAfter(kval, value, listfields, param);
        jsonRes = addObjOptionIfNeeded(jsonRes, key, obj, param );
        jsontab.push(jsonRes);
      }
    } else {
      var jsonRes = {};
      jsonRes[kval] = getConditionAfter(kval, obj[kval], listfields, param);
      jsontab.push(jsonRes);
    }
    return jsontab;
  }
  
  function getSpeOPeratorObj(key, obj, param) {
    var jsonRes = {};
    Object.keys(obj).forEach(function (key1) {
      if (SPE_OPERATORS[key].indexOf(key1) != -1) {
        jsonRes[key1] = getconvertedVal(obj[key1], SPE_COND_TYPES[key1], param);
      }
      else {
        param["errors"].push("cond : " + key1 + " is not an option of " + key);
      }
    });
    return jsonRes;
  }
  
  function getConditionBeforeObj(currentKey, array, listfields, param) {
    var jsontab = [];
    Object.keys(array).forEach(function (key) {
      var jsonRes = {};
      if (CONDITIONAL_OPERATORS.indexOf(key) != -1) {
        jsontab = getConditionBeforeObjOperator(jsontab, currentKey, key, array, listfields, param);
        if (jsontab === undefined)
          return undefined;
      }
      else if (key[0] !== '$') {
        if ((getConditionBeforeObjSpeOp(jsontab, currentKey, key, array, listfields, param)) === undefined) {
          jsontab = undefined;
          return undefined;
        }
      }
      else if (key in SPE_OPERATORS) {
        var jsonRes2 = {};
        jsonRes2[key] = getSpeOPeratorObj(key, array[key], param);
        jsontab.push(jsonRes2);
      }
      else {
        var jsonRes2 = {};
        jsonRes2[key] = array[key];
        var jsontmp = getConditionAfter(currentKey, jsonRes2, listfields, param);
        if (jsontmp === undefined) {
          jsontab = undefined;
          return undefined;
        }
        jsontab.push(jsontmp);
      }
    });
    return jsontab;
  }
  
  function getConditionBefore(currentKey, array, listfields, param) {
    var jsontab = [];
    if (Array.isArray(array) === true) {
      var tabtmp = [];
      if ((tabtmp = getConditionBeforeArray(currentKey, array, listfields, param)) === undefined)
        return undefined;
      jsontab = jsontab.concat(tabtmp);
    } else if (typeof array === 'object') {
      var tabtmp = [];
      if ((tabtmp = getConditionBeforeObj(currentKey, array, listfields, param)) === undefined)
        return undefined;
      if (currentKey !== null && currentKey !== undefined) {
        return tabtmp;
      }
      jsontab = jsontab.concat(tabtmp);
    }
    return jsontab;
  }
  
  this.buildMongoQuery = function (jsonRes, filters, listfields) {
    var param = {};
    param["gOption"]  = undefined;
    param["errors"] = [];
    if (typeof filters !== 'undefined') {
      if ("$options" in filters) {
        param["gOption"] = filters["$options"];
        delete filters.$options;
      }
      var jsonVal = {};
      // if ("$text" in filters) {
      //   //var jsonRes2 = {};
      //   jsonRes["$text"] = getSpeOPeratorObj("$text", filters["$text"], param);
      //   if (jsonRes["$text"] === undefined || param["errors"].length > 0 )
      //   {
      //     param["errors"].unshift("filters error");
      //     jsonRes["ERRORS"] = param["errors"];
      //
      //   }
      //   return jsonRes;
      // }
      // else
      {
        jsonVal["$and"] = getConditionBefore(null, filters, listfields, param);
        if (jsonVal["$and"] === undefined || param["errors"].length > 0 )
        {
          param["errors"].unshift("filters error");
          jsonVal["ERRORS"] = param["errors"];
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
    }
    else {
      jsonVal = jsonRes;
    }
    return jsonVal;
  }
}
