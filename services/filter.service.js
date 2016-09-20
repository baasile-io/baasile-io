'use strict';

const StandardError = require('standard-error');

module.exports = FilterService;

function FilterService(options)
{
	options = options || {};
    const logger = options.logger;

	function getDefaultOr(key, array, prefix)
    {
    	var jsonRes = new Array();
    	array.forEach(function(value)
    	{
    		var jsonval = {};
    		if (value[0] == '$')
    		  jsonval[key] = getConditionConstruct(value, prefix);
    		else
    		  jsonval[prefix+"."+key] = value;
  		jsonRes.push(jsonval);
    	});
    	return jsonRes;
    }

    function getDefaultAnd(key, array, prefix)
    {

    	var jsonRes = new Array();
    	var jsonval = {};
    	if (array[0][0] == '$') {
    	  jsonval[key] = getConditionConstruct(array[0], prefix);
    	}
    	else {
    	  jsonval[prefix+"."+key] = array[0];
    	}
  	jsonRes.push(jsonval);
    	return jsonRes;
    }


    function getComasValueOrValue(key, val, prefix)
    {
  	 var jsontab = [];
    	var jsonRes = {};
    	var array = val.split(',');
    	if (array.length > 1)
    	{
    	  jsonRes['$or'] = getDefaultOr(key, array, prefix);
    	}
    	else if (array.length == 1)
    	{
    	  jsonRes['$or'] = getDefaultAnd(key, array, prefix);
    	}
  	jsontab.push(jsonRes);
    	return jsontab;
    }

    function getConditionConstruct(array, prefix)
    {
    	var jsontab = [];
    	Object.keys(array).forEach(function(key)
    	{
  	  var jsonRes = {};
    	  if (key[0] == '$') {
    		 jsonRes[key] = getConditionConstruct(array[key], prefix);
    	  }
    	  else {
    		jsonRes["$and"] = getComasValueOrValue(key, array[key], prefix);
    	  }
  	  jsontab.push(jsonRes);
    	});
    	return jsontab;
    }

    this.getConstructedJson = function(req, res, prefix)
    {
      var jsonRes = {};
      jsonRes["route"] = req.data.route._id;
      if (typeof res._request.params.filter !== 'undefined')
      {
    	  jsonRes["$and"] = getConditionConstruct(res._request.params.filter, prefix);
      }
	  return jsonRes;
    }
}
