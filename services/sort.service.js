'use strict';

const CONFIG = require('../config/app.js');

module.exports = SortService;

function getTabByKeyVal(key, val, myArray, myarray2) {
  if (key === undefined || val === undefined || (myArray === undefined && myarray2 === undefined) ) {
    return undefined;
  }
  if (myArray !== undefined) {
    for (var i = 0; i < myArray.length; i++) {
      if (myArray[i][key] === val) {
        return myArray[i];
      }
    }
  }
  if (myarray2 !== undefined) {
    for (var i = 0; i < myarray2.length; i++) {
      if (myarray2[i][key] === val) {
        return myarray2[i];
      }
      else if (("aliases" in myarray2[i]))
      {
        for (var j = 0; j < myarray2[i]["aliases"].length; j++) {
          if (myarray2[i]["aliases"][j] === val) {
            return myarray2[i];
          }
        }
      }
    }
  }
  return undefined;
}

function getValIfValExistInArray(value, param) {
  if (param["model"] === undefined && param["modelName"] === undefined)
    return value;
  var typeTab = getTabByKeyVal("name", value, param["model"], param["modelName"]);
  if (typeTab !== undefined) {
    return value;
  }
  else {
    return (undefined);
  }
}

function SortService(options) {
  function checkSortParam(sorts, param)
  {
    var objRes = {};
    if (typeof sorts === 'string')
    {
      var tab = sorts.split(',');
      Object.keys(tab).every(function (key) {
        
        var sign = 1;
        if (tab[key][0] === '-') {
          sign = -1;
          tab[key] = tab[key].substring(1);
        }
        if (tab[key] in objRes) {
          param["errors"].push("you allready set a sort by the field" + tab[key] + " you can only set one type of sort for one field");
        }
        else if (getValIfValExistInArray(tab[key], param)) {
          objRes[tab[key]] = sign;
        }
        else {
          param["errors"].push("the name " + tab[key] + " is not in the field model");
        }
      });
    }
    else {
      param["errors"].push("sort need to be a string : ?sort=value1 or ?sort=-value1 or ?sort=value1,value2,value3");
    }
    return objRes;
  }
  
  this.buildMongoQuery = function (jsonRes, sorts, modelName, listfields) {
    var param = {};
    var jsonVal = jsonRes;
    param["gOption"]  = undefined;
    param["errors"] = [];
    param["modelName"] = undefined;
    param["model"] = undefined;
    if (modelName != undefined && modelName != null)
      param["modelName"] = CONFIG.api.v1.resources[modelName].authorizedsorts;
    if (listfields != undefined && listfields != null)
      param["model"] = listfields;
    if (typeof sorts !== 'undefined') {
        jsonVal["sort"] = checkSortParam(sorts, param);
        if (jsonVal["sort"] === undefined || param["errors"].length > 0 )
        {
          param["errors"].unshift("invalid_sort");
          jsonVal["ERRORS"] = param["errors"];
        }
    }
    else {
      jsonVal["sort"] = {updatedAt: -1, createdAt: -1};
    }
    return jsonVal;
  }
}