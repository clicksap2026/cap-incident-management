namespace support;

using { cuid, managed, sap.common.CodeList } from '@sap/cds/common';

// A customer who bought an appliance from us
entity Customers : cuid {
  name      : String(100) @title: '{i18n>Customer}' @mandatory;
  email     : String(200) @title: '{i18n>Email}';
  phone     : String(30)  @title: '{i18n>Phone}';
  city      : String(60)  @title: '{i18n>City}';
  incidents : Association to many Incidents on incidents.customer = $self;
}

// A problem a customer reports, like "Washing machine leaks water"
entity Incidents : cuid, managed {
  title        : String(111)  @title: '{i18n>Title}' @mandatory;
  description  : String(1000) @title: '{i18n>Description}';
  customer     : Association to Customers @title: '{i18n>Customer}' @mandatory @assert.target;
  urgency      : Association to Urgency   @title: '{i18n>Urgency}' default 'M';
  status       : Association to Status    @title: '{i18n>Status}'  default 'N';
  engineer     : String(100)  @title: '{i18n>Engineer}';
  conversation : Composition of many Conversations on conversation.incident = $self;
}

// One message in the conversation about an incident
entity Conversations : cuid, managed {
  incident : Association to Incidents;
  author   : String(100)  @title: '{i18n>Author}';
  message  : String(1000) @title: '{i18n>Message}';
}

// How fast we must react: High, Medium or Low
entity Urgency : CodeList {
  key code        : String(1) @title: '{i18n>Urgency}' enum { high = 'H'; medium = 'M'; low = 'L' };
      criticality : Integer; // the color in the app: 1 red, 2 amber, 3 green
}

// Where the incident is in its life
entity Status : CodeList {
  key code        : String(1) @title: '{i18n>Status}' enum { new = 'N'; inProcess = 'I'; onHold = 'H'; resolved = 'R'; closed = 'C' };
      criticality : Integer; // the color in the app: 1 red, 2 amber, 3 green, 0 grey
}
