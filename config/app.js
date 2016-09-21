'use strict';

module.exports = {
  api: {
    current_version: '1.0',
    current_version_url: 'v1',
    v1: {
      resources: {
        "Field": {
          type: "champs"
        },
        "Data": {
          type: "donnees"
        },
        "Page": {
          type: "pages"
        },
        "Relation": {
          type: "relations"
        },
        "Route": {
          type: "collections"
        },
        "Service": {
          type: "services"
        },
        "Token": {
          type: "tokens"
        }
      }
    }
  }
};