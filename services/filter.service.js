'use strict';

const StandardError = require('standard-error');

module.exports = FilterService;

function FilterService(options)
{
  const CONDITIONAL_OPERATORS = ['$and', '$or'];

  const COND_TYPES = [
    {'ALL': []},
    {'ID': []},
    {'STRING': []},
    {'NUMERIC': ["$gt", "$lt", "$gte", "$lte"]},
    {'PERCENT': ["$gt", "$lt", "$gte", "$lte"]},
    {'AMOUNT': ["$gt", "$lt", "$gte", "$lte"]},
    {'BOOLEAN': []},
    {'DATE': ["$gt", "$lt", "$gte", "$lte"]},
    {'ENCODED': []},
    {'JSON': []}
    ];
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
    return value;
    if (searchByVal("name", value, listfields) !== undefined)
      return value;
    else {
      logger.info("field \"" + value + "\" is not in base model");
      return (undefined);
    }
  }

  function getTypeOf(value, listfields)
  {
    if ((value === undefined) || Array.isArray(value) || (value[0] == '$'))
      return CONDITIONAL_OPERATORS;
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
	var type = getTypeOf(value, listfields);
    if (type !== undefined && (type.indexOf(key) != -1)) {
      return true;
    }
    logger.info("condition \"" + key + "\" of value \"" + value + "\" of type \"" + type + "\" is not allowed in this case");
    return false;
  }

  function getConditionAfter(val, obj, listfields)
  {
  	var jsonRes = {};
  	Object.keys(obj).forEach(function(key)
  	{
	  if (key[0] === '$' && tryKeyByType(key, val, listfields)) {
		  jsonRes[key] = obj[key];
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
		 jsonRes[kval] = (typeof array[kval] === 'object') ? getConditionAfter(kval, array[kval], listfields) : array[kval] ;
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
