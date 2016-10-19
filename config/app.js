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
            {"name": "fieldId", "key": "STRING", "aliases" : ["id_champ", "id_field", "field_id"] },
            {"name": "name", "key": "STRING", "aliases" : ["nom"] },
            {"name": "nameNormalized", "key": "STRING", "aliases" : ["alias", "name_normalized"] },
            {"name": "description", "key": "STRING" },
            {"name": "required", "key": "BOOLEAN", "aliases" : ["obligatoire"] },
            {"name": "order", "key": "NUMERIC", "aliases" : ["ordre"] },
            {"name": "type", "key": "STRING" },
            {"name": "routeId", "key": "STRING", "aliases" : ["id_collection", "id_route", "route_id"] },
            {"name": "clientId", "key": "STRING", "aliases" : ["id_service", "service_id", "client_id"] },
            {"name": "createdAt", "key": "DATE", "aliases" : ["created_at", "created", "creation"] },
            {"name": "updatedAt", "key": "DATE", "aliases" : ["updated_at", "updated", "modification"] }
          ]
        },
        "Data": {
          type: "donnees",
          authorizedFilters: [
            {"name": "dataId", "key": "STRING", "aliases" : ["id_donnee", "id_data", "data_id"] },
            {"name": "routeId", "key": "STRING", "aliases" : ["id_collection", "id_route", "route_id"] },
            {"name": "clientId", "key": "STRING", "aliases" : ["id_service", "service_id", "client_id"] },
            {"name": "createdAt", "key": "DATE", "aliases" : ["created_at", "created", "creation"] },
            {"name": "updatedAt", "key": "DATE", "aliases" : ["updated_at", "updated", "modification"] }
          ]
        },
        "Page": {
          type: "pages",
          authorizedFilters: [
            {"name": "pageId", "key": "STRING", "aliases" : ["id_page", "page_id"] },
            {"name": "type", "key": "STRING" },
            {"name": "name", "key": "STRING" },
            {"name": "nameNormalized", "key": "STRING", "aliases" : ["alias", "name_normalized"] },
            {"name": "parentPageId", "key": "STRING", "aliases" : ["id_page_parente", "parent_page_id"] },
            {"name": "relationType", "key": "STRING", "aliases" : ["relation_type"] },
            {"name": "description", "key": "STRING" },
            {"name": "smallDescription", "key": "STRING", "aliases" : ["description_courte", "small_description"] },
            {"name": "routeId", "key": "STRING", "aliases" : ["id_collection", "id_route", "route_id"] },
            {"name": "clientId", "key": "STRING", "aliases" : ["id_service", "service_id", "client_id"] },
            {"name": "createdAt", "key": "DATE", "aliases" : ["created_at", "created", "creation"] },
            {"name": "updatedAt", "key": "DATE", "aliases" : ["updated_at", "updated", "modification"] }
          ]
        },
        "Relation": {
          type: "relations",
          authorizedFilters: [
            {"name": "relationId", "key": "STRING", "aliases": ["id_relation", "relation_id"] },
            {"name": "type", "key": "STRING" },
            {"name": "parentRouteId", "key": "STRING", "aliases" : ["id_collection_parente", "parent_route_id"] },
            {"name": "childRouteId", "key": "STRING", "aliases" : ["id_collection_enfant", "child_route_id"] },
            {"name": "clientId", "key": "STRING", "aliases" : ["id_service", "service_id", "client_id"] },
            {"name": "createdAt", "key": "DATE", "aliases" : ["created_at", "created", "creation"] },
            {"name": "updatedAt", "key": "DATE", "aliases" : ["updated_at", "updated", "modification"] }
          ]
        },
        "Route": {
          type: "collections",
          authorizedFilters: [
            {"name": "routeId", "key": "STRING", "aliases" : ["id_collection", "id_route", "route_id"] },
            {"name": "name", "key": "STRING", "aliases" : ["nom"] },
            {"name": "nameNormalized", "key": "STRING", "aliases" : ["alias", "name_normalized"] },
            {"name": "description", "key": "STRING" },
            {"name": "type", "key": "STRING" },
            {"name": "isCollection", "key": "BOOLEAN", "aliases" : ["tableau_de_donnees", "is_collection"] },
            {"name": "isIdentified", "key": "BOOLEAN", "aliases" : ["donnees_identifiees", "is_identified"] },
            {"name": "method", "key": "STRING" },
            {"name": "fcRequired", "key": "BOOLEAN", "aliases": ["jeton_fc_lecture_seulement"] },
            {"name": "fcRestricted", "key": "BOOLEAN", "aliases": ["jeton_fc_lecture_ecriture"] },
            {"name": "public", "key": "BOOLEAN" },
            {"name": "clientId", "key": "STRING", "aliases" : ["id_service", "service_id", "client_id"] },
            {"name": "createdAt", "key": "DATE", "aliases" : ["created_at", "created", "creation"] },
            {"name": "updatedAt", "key": "DATE", "aliases" : ["updated_at", "updated", "modification"] }
          ]
        },
        "Service": {
          type: "services",
          authorizedFilters: [
            {"name": "name", "key": "STRING" },
            {"name": "nameNormalized", "key": "STRING", "aliases" : ["alias", "name_normalized"] },
            {"name": "description", "key": "STRING" },
            {"name": "website", "key": "STRING", "aliases": ["site_internet"] },
            {"name": "public", "key": "BOOLEAN" },
            {"name": "clientSecret", "key": "STRING", "aliases": ["client_secret"] },
            {"name": "clientId", "key": "STRING", "aliases" : ["id_service", "service_id", "client_id"] },
            {"name": "validated", "key": "BOOLEAN" },
            {"name": "createdAt", "key": "DATE", "aliases" : ["created_at", "created", "creation"] },
            {"name": "updatedAt", "key": "DATE", "aliases" : ["updated_at", "updated", "modification"] }
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
  },
  dashboard: {
    thumbnail: {
      versions: [
        {
          maxHeight: 1040,
          maxWidth: 1040,
          format: 'png',
          suffix: '-1040x1040'
        },
        {
          maxWidth: 780,
          format: 'png',
          aspect: '3:2!h',
          suffix: '-720x'
        },
        {
          maxWidth: 320,
          format: 'png',
          aspect: '16:9!h',
          suffix: '-320x'
        },
        {
          maxHeight: 100,
          maxWidth: 100,
          format: 'png',
          aspect: '1:1',
          suffix: '-100x100'
        },
        {
          maxHeight: 250,
          maxWidth: 250,
          format: 'png',
          aspect: '1:1',
          suffix: '-250x250'
        },
        {
          maxHeight: 100,
          maxWidth: 100,
          format: 'png',
          aspect: '1:1',
          background: 'white',
          flatten: true,
          suffix: '-100x100bg'
        },
        {
          maxHeight: 250,
          maxWidth: 250,
          format: 'png',
          aspect: '1:1',
          background: 'white',
          flatten: true,
          suffix: '-250x250bg'
        }
      ]
    }
  }
};