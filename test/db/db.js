'use strict';

module.exports = {
  "USERS": [{
    firstname: 'Firstname',
    lastname: 'Lastname',
    email: 'apicpa@apicpa.apicpa',
    password: 'password10'
  },{
    firstname: 'secondaryFirstname',
    lastname: 'secondaryLastname',
    email: 'secondaryapicpa@apicpa.apicpa',
    password: 'secondarypassword10'
  }],
  "SERVICES": [{
    "CREATOR_INDEX": 0,
    "USERS_INDEX": [0, 1],
    name: 'Test',
    description: 'Description',
    public: true,
    users: [],
    clientSecret: 'my_client_secret',
    clientId: 'my_client_id',
    validated: true,
    "ROUTES": [{
      name: 'Collection1',
      description: 'description',
      routeId: 'my_route_id1',
      public: true,
      isIdentified: false,
      isCollection: false,
      "FIELDS": [{
        name: 'Field1',
        required: true,
        fieldId: 'my_field_id1',
        type: 'STRING'
      }, {
        name: 'Field2',
        required: true,
        fieldId: 'my_field_id2',
        type: 'STRING'
      }],
      "DATAS": [{
        dataId: 'my_data_id1',
        data: {
          field1: 'first string',
          field2: 'second string'
        }
      }]
    }]
  },{
    "CREATOR_INDEX": 1,
    "USERS_INDEX": [1],
    name: 'Private service',
    description: 'Description',
    public: false,
    users: [],
    clientSecret: 'my_client_secret_private',
    clientId: 'my_client_id_private',
    validated: true,
    "ROUTES": []
  }]
};