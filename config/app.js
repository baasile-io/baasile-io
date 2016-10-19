'use strict';

module.exports = {
  api: {
    current_version: '1.0',
    current_version_url: 'v1',
    v1: {
      resources: {
        "Field": {
          type: "champs",
          authorizedFilters: [
            {"name": "fieldId", "key": "String", "Alias" : ["id"] },
            {"name": "name", "key": "String", "Alias" : ["nom"] },
            {"name": "nameNormalized", "key": "String" },
            {"name": "description", "key": "String" , "Alias" : ["desc"] },
            {"name": "required", "key": "Boolean" },
            {"name": "order", "key": "Number" },
            {"name": "type", "key": "String" },
            {"name": "routeId", "key": "String" },
            {"name": "clientId", "key": "String" },
            {"name": "createdAt", "key": "Date" , "Alias" : ["created", "created_at"] },
            {"name": "updatedAt", "key": "Date" , "Alias" : ["updated", "updated_at"] },
          ]
        },
        "Data": {
          type: "donnees",
          authorizedFilters: [
            {"name": "dataId", "key": "String" },
            {"name": "routeId", "key": "String" },
            {"name": "clientId", "key": "String" },
            {"name": "createdAt", "key": "Date" },
            {"name": "updatedAt", "key": "Date" }
          ]
        },
        "Page": {
          type: "pages",
          authorizedFilters: [
            {"name": "pageId", "key": "String" },
            {"name": "type", "key": "String" },
            {"name": "name", "key": "String" },
            {"name": "nameNormalized", "key": "String" },
            {"name": "parentPageId", "key": "String" },
            {"name": "relationType", "key": "String" },
            {"name": "description", "key": "String" },
            {"name": "smallDescription", "key": "String" },
            {"name": "routeId", "key": "String" },
            {"name": "clientId", "key": "String" },
            {"name": "createdAt", "key": "Date" },
            {"name": "updatedAt", "key": "Date" }
          ]
        },
        "Relation": {
          type: "relations",
          authorizedFilters: [
            {"name": "relationId", "key": "String" },
            {"name": "type", "key": "String" },
            {"name": "parentRouteId", "key": "String" },
            {"name": "childRouteId", "key": "String" },
            {"name": "clientId", "key": "String" },
            {"name": "createdAt", "key": "Date" },
            {"name": "updatedAt", "key": "Date" }
          ]
        },
        "Route": {
          type: "collections",
          authorizedFilters: [
            {"name": "routeId", "key": "String" },
            {"name": "name", "key": "String" },
            {"name": "nameNormalized", "key": "String" },
            {"name": "description", "key": "String" },
            {"name": "type", "key": "String" },
            {"name": "isCollection", "key": "Boolean" },
            {"name": "isIdentified", "key": "Boolean" },
            {"name": "method", "key": "String" },
            {"name": "fcRequired", "key": "Boolean" },
            {"name": "fcRestricted", "key": "Boolean" },
            {"name": "public", "key": "Boolean" },
            {"name": "clientId", "key": "String" },
            {"name": "createdAt", "key": "Date" },
            {"name": "updatedAt", "key": "Date" }
          ]
        },
        "Service": {
          type: "services",
          authorizedFilters: [
            {"name": "name", "key": "String" },
            {"name": "nameNormalized", "key": "String" },
            {"name": "description", "key": "String" },
            {"name": "website", "key": "String" },
            {"name": "public", "key": "Boolean" },
            {"name": "clientSecret", "key": "String" },
            {"name": "clientId", "key": "String" },
            {"name": "validated", "key": "Boolean" },
            {"name": "createdAt", "key": "Date" },
            {"name": "updatedAt", "key": "Date" }
          ]
        },
        "Token": {
          type: "tokens",
          authorizedFilters: [
            {"name": "accessToken", "key": "String" },
            {"name": "accessTokenExpiresOn", "key": "Date" },
            {"name": "production", "key": "Boolean" },
            {"name": "nbOfUse", "key": "Number" },
            {"name": "createdAt", "key": "Date" },
            {"name": "updatedAt", "key": "Date" }
          ]
        }
      }
    },
    pagination: {
      offset: 0,
      limit: 25,
      max: {
        limit: 200
      }
    }
  }
};