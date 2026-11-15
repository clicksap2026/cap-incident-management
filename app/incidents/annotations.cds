using IncidentService as service from '../../srv/incident-service';

// Draft: create and edit incidents safely, with Save and Discard
annotate service.Incidents with @odata.draft.enabled;

annotate service.Incidents with @(

  // Filters at the top of the list
  UI.SelectionFields: [ status_code, urgency_code, customer_ID ],

  // Columns of the list, with colors for urgency and status
  UI.LineItem: [
    { Value: title },
    { Value: customer_ID },
    { Value: urgency_code, Criticality: urgency.criticality },
    { Value: status_code,  Criticality: status.criticality },
    { Value: engineer },
    { Value: createdAt, Label: '{i18n>ReportedOn}' }
  ],

  // Header of the object page
  UI.HeaderInfo: {
    TypeName      : '{i18n>Incident}',
    TypeNamePlural: '{i18n>Incidents}',
    Title         : { Value: title },
    Description   : { Value: customer.name }
  },

  // Section 1: what the problem is
  UI.FieldGroup #Problem: { Data: [
    { Value: customer_ID },
    { Value: description }
  ]},

  // Section 2: how we handle it
  UI.FieldGroup #Handling: { Data: [
    { Value: urgency_code, Criticality: urgency.criticality },
    { Value: status_code,  Criticality: status.criticality },
    { Value: engineer }
  ]},

  // Sections of the object page
  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', Label: '{i18n>Problem}',      Target: '@UI.FieldGroup#Problem' },
    { $Type: 'UI.ReferenceFacet', Label: '{i18n>Handling}',     Target: '@UI.FieldGroup#Handling' },
    { $Type: 'UI.ReferenceFacet', Label: '{i18n>Conversation}', Target: 'conversation/@UI.LineItem' }
  ]
);

annotate service.Incidents with {

  // Show the customer's name instead of the ID, and let the user search for a customer
  customer @Common: {
    Text           : customer.name,
    TextArrangement: #TextOnly,
    ValueList: {
      CollectionPath: 'Customers',
      Parameters    : [
        { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: customer_ID, ValueListProperty: 'ID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'city' }
      ]
    }
  };

  // Show the urgency name instead of its code, picked from a dropdown
  urgency @Common: {
    Text                    : urgency.name,
    TextArrangement         : #TextOnly,
    ValueListWithFixedValues: true,
    ValueList: {
      CollectionPath: 'Urgency',
      Parameters    : [
        { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: urgency_code, ValueListProperty: 'code' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
      ]
    }
  };

  // Show the status name instead of its code, picked from a dropdown
  status @Common: {
    Text                    : status.name,
    TextArrangement         : #TextOnly,
    ValueListWithFixedValues: true,
    ValueList: {
      CollectionPath: 'Status',
      Parameters    : [
        { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: status_code, ValueListProperty: 'code' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
      ]
    }
  };

  description @UI.MultiLineText;
};

// Columns of the conversation table on the object page
annotate service.Conversations with @(UI.LineItem: [
  { Value: author },
  { Value: message },
  { Value: createdAt, Label: '{i18n>AddedOn}' }
]);

annotate service.Conversations with {
  message @UI.MultiLineText;
};
