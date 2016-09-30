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
    website: 'http://mywebsite.com',
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
      }, {
        name: 'Field3',
        required: true,
        fieldId: 'my_field_id3',
        type: 'NUMERIC'
      }, {
        name: 'Field4',
        required: true,
        fieldId: 'my_field_id4',
        type: 'JSON'
      }, {
        name: 'Field5',
        required: true,
        fieldId: 'my_field_id5',
        type: 'AMOUNT'
      }],
      "DATAS": [{
        dataId: 'my_data_id1',
        data: {
          field1: 'first string',
          field2: 'second string',
          field3: 12,
          field4: {'key' : 'value'},
          field5: 75
        }
      }, {
        dataId: 'my_data_id2',
        data: {
          field1: 'second',
          field2: 'test1',
          field3: 1,
          field4: {'key' : 'value'},
          field5: 2
        }
      }, {
        dataId: 'my_data_id3',
        data: {
          field1: 'third',
          field2: 'test2',
          field3: 70,
          field4: {'key' : 'value'},
          field5: 85
        }
      }, {
        dataId: 'my_data_id4',
        data: {
          field1: 'fours',
          field2: 'test3',
          field3: 43,
          field4: {'key' : 'value'},
          field5: 35
        }
      }, {
        dataId: 'my_data_id5',
        data: {
          field1: 'fives',
          field2: 'test4',
          field3: 80,
          field4: {'key' : 'value'},
          field5: 2
        }
      }, {
        dataId: 'my_data_id6',
        data: {
          field1: 'sixs',
          field2: 'test5',
          field3: 125,
          field4: {'key' : 'value'},
          field5: 185
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