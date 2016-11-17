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
        name: 'field1',
        required: true,
        fieldId: 'my_field_id1',
        type: 'STRING'
      }, {
        name: 'field2',
        required: true,
        fieldId: 'my_field_id2',
        type: 'STRING'
      }, {
        name: 'field3',
        required: true,
        fieldId: 'my_field_id3',
        type: 'NUMERIC'
      }, {
        name: 'field4',
        required: true,
        fieldId: 'my_field_id4',
        type: 'JSON'
      }, {
        name: 'field5',
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
      },{
        dataId: 'my_data_id7',
        data: {
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
  },{
    "CREATOR_INDEX": 1,
    "USERS_INDEX": [1],
    name: 'service 1',
    description: 'Description',
    public: true,
    users: [],
    clientSecret: 'client_secret_number_1',
    clientId: 'client_id_number_1',
    validated: true,
    "ROUTES": [{
      name: 'CollectionWithAllTypes',
      description: 'description',
      routeId: 'my_route_with_all_types_id',
      public: false,
      isIdentified: false,
      isCollection: false,
      "FIELDS": [{
        name: 'id',
        required: true,
        fieldId: 'my_field_all_types_id1',
        type: 'ID'
      }, {
        name: 'my_string',
        required: false,
        fieldId: 'my_field_all_types_id2',
        type: 'STRING'
      }, {
        name: 'my_numeric',
        required: false,
        fieldId: 'my_field_all_types_id3',
        type: 'NUMERIC'
      }, {
        name: 'my_json',
        required: false,
        fieldId: 'my_field_all_types_id4',
        type: 'JSON'
      }, {
        name: 'my_percent',
        required: false,
        fieldId: 'my_field_all_types_id5',
        type: 'PERCENT'
      }, {
        name: 'my_amount',
        required: false,
        fieldId: 'my_field_all_types_id6',
        type: 'AMOUNT'
      }, {
        name: 'my_boolean',
        required: false,
        fieldId: 'my_field_all_types_id7',
        type: 'BOOLEAN'
      }, {
        name: 'my_encoded',
        required: false,
        fieldId: 'my_field_all_types_id8',
        type: 'ENCODED'
      }, {
        name: 'my_date',
        required: false,
        fieldId: 'my_field_all_types_id9',
        type: 'DATE'
      }],
      "DATAS": []
    }]
  },{
    "CREATOR_INDEX": 1,
    "USERS_INDEX": [1],
    name: 'service 2',
    description: 'Description',
    public: true,
    users: [],
    clientSecret: 'client_secret_number_2',
    clientId: 'client_id_number_2',
    validated: true,
    "ROUTES": []
  },{
    "CREATOR_INDEX": 1,
    "USERS_INDEX": [1],
    name: 'service 3',
    description: 'Description',
    public: true,
    users: [],
    clientSecret: 'client_secret_number_3',
    clientId: 'client_id_number_3',
    validated: true,
    "ROUTES": []
  },{
    "CREATOR_INDEX": 1,
    "USERS_INDEX": [1],
    name: 'service 4',
    description: 'Description',
    public: true,
    users: [],
    clientSecret: 'client_secret_number_4',
    clientId: 'client_id_number_4',
    validated: true,
    "ROUTES": []
  }]
};