'use strict';

const StandardError = require('standard-error');

module.exports = FilterService;

function FilterService(options)
{
  const CONDITIONAL_OPERATORS = ['$and', '$or'];

  const COND_TYPES = {
    'ALL': [],
    'ID': [],
    'STRING': [],
    'NUMERIC': ["$gt", "$lt", "$gte", "$lte"],
    'PERCENT': ["$gt", "$lt", "$gte", "$lte"],
    'AMOUNT': ["$gt", "$lt", "$gte", "$lte"],
    'BOOLEAN': [],
    'DATE': ["$gt", "$lt", "$gte", "$lte"],
    'ENCODED': [],
    'JSON': []
	};
  options = options || {};
  const logger = options.logger;



  // const FIELD_TYPES = [
    //   {key: 'STRING', name: 'prenom'},
  //   {key: 'STRING', name: 'name'},
    //   {key: 'NUMERIC', name: 'age'}
    // ];

  function searchByVal(key, nameKey, myArray)
  {
	if (key === undefined || nameKey === undefined || myArray === undefined)
  	  return undefined;
    for (var i=0; i < myArray.length; i++) {
      if (myArray[i][key] === nameKey) {
        return myArray[i];
      }
    }
	return undefined;
  }

  function searchBykey(nameKey, myArray)
  {
	if (nameKey === undefined || myArray === undefined)
	  return undefined;
    for (var i=0; i < myArray.length; i++)
	{
      if (myArray[i] === nameKey)
      {
        return myArray[i];
      }
    }
	return undefined;
  }

  function getValIfValExist( value, listfields)
  {
	  logger.info("try\"" + value + "\" in base model");
    var typeTab = searchByVal("name", value, listfields);
	 logger.info("type tabe\"" + JSON.stringify(typeTab) + "\"");
    if ( typeTab !== undefined)
	{
		return value;
  	}
    else {
      logger.info("field \"" + value + "\" is not in base model");
      return (undefined);
    }
  }

  function getTableTypeOf(value, listfields)
  {
    if ((value === undefined) || Array.isArray(value) || (value[0] == '$'))
      return CONDITIONAL_OPERATORS;
    else
    {
      var objson = searchByVal("name", getValIfValExist( value, listfields), listfields);
	  if (objson === undefined)
	  	return undefined;
	  return COND_TYPES[objson.key];
    }
  }

  function getTypeOf(value, listfields)
  {
    if ((value === undefined) || Array.isArray(value) || (value[0] == '$'))
      return undefined;
    else
    {
      var objson = searchByVal("name", getValIfValExist( value, listfields), listfields);
	  if (objson === undefined)
	  	return undefined;
	  return objson.key;
    }
  }

  function tryKeyByType(key, value, listfields)
  {
	var type = getTableTypeOf(value, listfields);
	logger.info("type : => "+JSON.stringify(type));
    if (type !== undefined && (type.indexOf(key) != -1)) {
      return true;
    }
    logger.info("condition \"" + key + "\" of value \"" + value + "\" of type \"" + type + "\" is not allowed in this case");
    return false;
  }

  function getValueByFieldType(val, keyname, listfields)
  {
	  var type = getTypeOf(keyname, listfields);
	  if (type == 'NUMERIC' || type == 'PERCENT' || type == 'AMOUNT')
	  	return Number(val);
	 else {
	 	return val;
	 }
  }

  function getConditionAfter(val, obj, listfields)
  {
  	var jsonRes = {};
  	Object.keys(obj).forEach(function(key)
  	{
	  if (key[0] === '$' && tryKeyByType(key, val, listfields)) {
		  jsonRes[key] = getValueByFieldType(obj[key], val, listfields);
	  }
	  else {
	  	return undefined;
	  }
  	});
	return (jsonRes);
  }

  function getConditionBefore(array, listfields)
  {
    var jsontab = [];
    Object.keys(array).forEach(function(key)
    {
      var jsonRes = {};
      if (key === "$or" || key === "$and")
	  {
        if ((jsonRes[key] = getConditionConstruct(array[key], listfields)) === undefined || !tryKeyByType(key, jsonRes[key], listfields))
          return undefined;
      }
	  else if (key[0] !== '$')
	  {
		 var kval = getValIfValExist(key, listfields);
		 if (kval === undefined)
		 	return (undefined);
		if (Array.isArray(array[kval]))
		logger.info("it s an array");
		if (typeof array[kval] === 'object')
		logger.info("it s an object");
		 jsonRes[kval] = (typeof array[kval] === 'object' ||  Array.isArray(array[kval])) ? getConditionAfter(kval, array[kval], listfields) : getValueByFieldType(array[kval], kval, listfields); ;
      }
	  else
	  {
	  	return (undefined);
	  }
      jsontab.push(jsonRes);
    });
    return jsontab;
  }

  this.buildMongoQuery = function(jsonRes, filters, listfields)
  {
    if (typeof filters !== 'undefined')
    {
      //var jsonVal = {};
      if ((jsonRes["$and"] = getConditionBefore(filters, listfields)) === undefined)
        return undefined;
    }
    return jsonRes;
  }
}
