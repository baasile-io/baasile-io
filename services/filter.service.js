'use strict';

const StandardError = require('standard-error');

module.exports = FilterService;

function FilterService(options)
{
	const COND_TYPES = [
		{'ALL': ["$and", "$or"]},
		{'ID': ["$and", "$or", "$gt", "$lt"]},
		{'STRING': ["$and", "$or"]},
		{'NUMERIC': ["$and", "$or", "$gt", "$lt"]},
		{'PERCENT': ["$and", "$or", "$gt", "$lt"]},
		{'AMOUNT': ["$and", "$or", "$gt", "$lt"]},
		{'BOOLEAN': ["$and", "$or"]},
		{'DATE': ["$and", "$or", "$gt", "$lt"]},
		{'ENCODED': ["$and", "$or"]},
		{'JSON': ["$and", "$or"]}
    ];
	options = options || {};
    const logger = options.logger;

	function getValIfValExist( value, listfields)
	{
		return value;
		var tabVal = value.split('.');
		if (listfields.indexOf(tabVal[tabVal.length-1]) != -1)
			return value;
		else {
			logger.info("field \"" + tabVal[tabVal.length-1] + "\" is not in base model");
			return (undefined);
		}
	}

	// const FIELD_TYPES = [
    //   {key: 'STRING', name: 'prenom'},
	//   {key: 'STRING', name: 'name'},
    //   {key: 'NUMERIC', name: 'age'}
    // ];

	function searchByVal(key, nameKey, myArray)
	{
		for (var i=0; i < myArray.length; i++) {
			if (myArray[i][key] === nameKey) {
				return myArray[i];
			}
		}
	}

	function searchBykey(nameKey, myArray)
	{
		for (var i=0; i < myArray.length; i++) {
			if (myArray[i][nameKey] !== undefined)
			{
				return myArray[i];
			}
		}
	}

	function getTypeOf(value, listfields)
	{
		if ((value === undefined) || Array.isArray(value) || (value[0] == '$'))
			return "ALL";
		else
		{
			var objson = search("name", getValIfValExist( value, listfields), listfields);
			return objson.key;
		}
	}

	function tryKeyByType(key, value, listfields)
	{
		var type = getTypeOf(value);
		logger.info(JSON.stringify(COND_TYPES));
		var tabKey = searchBykey(type, COND_TYPES);
		if (tabKey !== undefined) {
			return true;
		}
		logger.info("condition \"" + key + "\" of value \"" + value + "\" of type \"" + type + "\" is not allowed in this case");
		return false;
	}

	function getDefaultOr(key, array, listfields)
    {
    	var jsonRes = new Array();
    	array.forEach(function(value)
    	{
    		var jsonval = {};
    		if (value[0] == '$')
			{
			  if ((jsonval[key] = getConditionConstruct(value, listfields)) === undefined ||  !tryKeyByType(value, jsonval[key], listfields))
			  	return undefined;
			}
			else
			{
				if ((jsonval[key] = getValIfValExist(value, listfields)) === undefined)
					return (undefined);
			}
  			jsonRes.push(jsonval);
    	});
    	return jsonRes;
    }

    function getDefaultAnd(key, array, listfields)
    {

    	var jsonRes = new Array();
    	var jsonval = {};
    	if (array[0][0] == '$') {
		  if ((jsonval[key] = getConditionConstruct(array[0], listfields)) === undefined || !tryKeyByType(array[0], jsonval[key], listfields))
		  	return undefined;
    	}
    	else {
			if ((jsonval[key] = getValIfValExist(array[0], listfields)) === undefined)
				return (undefined);
    	}
  		jsonRes.push(jsonval);
    	return jsonRes;
    }


    function getComasValueOrValue(key, val, listfields)
    {
  	 var jsontab = [];
    	var jsonRes = {};
    	var array = val.split(',');
    	if (array.length > 1) {
    	  if ((jsonRes['$or'] = getDefaultOr(key, array, listfields)) === undefined)
		  	 return undefined;
    	}
    	else if (array.length == 1) {
    	  if ((jsonRes['$and'] = getDefaultAnd(key, array, listfields)) === undefined)
		  		 return undefined;
    	}
  		jsontab.push(jsonRes);
    	return jsontab;
    }

    function getConditionConstruct(array, listfields)
    {
    	var jsontab = [];
    	Object.keys(array).forEach(function(key)
    	{
  	  	  var jsonRes = {};
    	  if (key[0] == '$') {
			 if ((jsonRes[key] = getConditionConstruct(array[key], listfields)) === undefined || !tryKeyByType(key, jsonRes[key], listfields))
			 	return undefined;
    	  }
    	  else {
			if ((jsonRes["$and"] = getComasValueOrValue(key, array[key], listfields)) === undefined)
			   return undefined;
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
		  if ((jsonRes["$and"] = getConditionConstruct(filters, listfields)) === undefined)
			 return undefined;
      }
	  return jsonRes;
    }
}
