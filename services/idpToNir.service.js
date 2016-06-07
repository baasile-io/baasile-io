'use strict';

module.exports = IdpToNirService;

function IdpToNirService(options) {
  options = options || {};
  const logger = options.logger;

  this.process = function(infoJson)
  {
    if (!infoJson)
      throw new Error("json null");
    if (infoJson == "")
      throw new Error("json empty");
    if (!infoJson.hasOwnProperty('gender'))
      throw new Error("json no gender KEY");
    if (!infoJson.hasOwnProperty('birthdate'))
      throw new Error("json no birthdate KEY");
    if (!infoJson.hasOwnProperty('birthplace'))
      throw new Error("json no birthplace KEY");
    var nir = "";
    if (infoJson.gender === "male")
      nir += '1';
    else if (infoJson.gender === "female")
      nir += '2';
    else
      return "gender not ok";
    nir += infoJson.birthdate.substr(2, 2);
    nir += infoJson.birthdate.substr(5, 2);
    if (infoJson.birthplace === "")
      nir += "99000";
    else
      nir += infoJson.birthplace;
    return nir;
  }
};
