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
            {"name": "fieldId", "key": "STRING", "aliases" : ["id"] },
            {"name": "name", "key": "STRING", "aliases" : ["nom"] },
            {"name": "nameNormalized", "key": "STRING" },
            {"name": "description", "key": "STRING" , "aliases" : ["desc"] },
            {"name": "required", "key": "BOOLEAN" },
            {"name": "order", "key": "NUMERIC" },
            {"name": "type", "key": "STRING" },
            {"name": "routeId", "key": "STRING" },
            {"name": "clientId", "key": "STRING" },
            {"name": "createdAt", "key": "DATE" , "aliases" : ["created", "created_at"] },
            {"name": "updatedAt", "key": "DATE" , "aliases" : ["updated", "updated_at"] },
          ]
        },
        "Data": {
          type: "donnees",
          authorizedFilters: [
            {"name": "dataId", "key": "STRING" },
            {"name": "routeId", "key": "STRING" },
            {"name": "clientId", "key": "STRING" },
            {"name": "createdAt", "key": "DATE" },
            {"name": "updatedAt", "key": "DATE" }
          ]
        },
        "Page": {
          type: "pages",
          authorizedFilters: [
            {"name": "pageId", "key": "STRING" },
            {"name": "type", "key": "STRING" },
            {"name": "name", "key": "STRING" },
            {"name": "nameNormalized", "key": "STRING" },
            {"name": "parentPageId", "key": "STRING" },
            {"name": "relationType", "key": "STRING" },
            {"name": "description", "key": "STRING" },
            {"name": "smallDescription", "key": "STRING" },
            {"name": "routeId", "key": "STRING" },
            {"name": "clientId", "key": "STRING" },
            {"name": "createdAt", "key": "DATE" },
            {"name": "updatedAt", "key": "DATE" }
          ]
        },
        "Relation": {
          type: "relations",
          authorizedFilters: [
            {"name": "relationId", "key": "STRING" },
            {"name": "type", "key": "STRING" },
            {"name": "parentRouteId", "key": "STRING" },
            {"name": "childRouteId", "key": "STRING" },
            {"name": "clientId", "key": "STRING" },
            {"name": "createdAt", "key": "DATE" },
            {"name": "updatedAt", "key": "DATE" }
          ]
        },
        "Route": {
          type: "collections",
          authorizedFilters: [
            {"name": "routeId", "key": "STRING" },
            {"name": "name", "key": "STRING" },
            {"name": "nameNormalized", "key": "STRING" },
            {"name": "description", "key": "STRING" },
            {"name": "type", "key": "STRING" },
            {"name": "isCollection", "key": "BOOLEAN" },
            {"name": "isIdentified", "key": "BOOLEAN" },
            {"name": "method", "key": "STRING" },
            {"name": "fcRequired", "key": "BOOLEAN" },
            {"name": "fcRestricted", "key": "BOOLEAN" },
            {"name": "public", "key": "BOOLEAN" },
            {"name": "clientId", "key": "STRING" },
            {"name": "createdAt", "key": "DATE" },
            {"name": "updatedAt", "key": "DATE" }
          ]
        },
        "Service": {
          type: "services",
          authorizedFilters: [
            {"name": "name", "key": "STRING" },
            {"name": "nameNormalized", "key": "STRING" },
            {"name": "description", "key": "STRING" },
            {"name": "website", "key": "STRING" },
            {"name": "public", "key": "BOOLEAN" },
            {"name": "clientSecret", "key": "STRING" },
            {"name": "clientId", "key": "STRING" },
            {"name": "validated", "key": "BOOLEAN" },
            {"name": "createdAt", "key": "DATE" },
            {"name": "updatedAt", "key": "DATE" }
          ]
        },
        "Token": {
          type: "tokens"
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