namespace support;

using { cuid, managed, sap.common.CodeList } from '@sap/cds/common';

// A customer who bought an appliance from us
entity Customers : cuid {
  name      : String(100);
  email     : String(200);
  phone     : String(30);
  city      : String(60);
  incidents : Association to many Incidents on incidents.customer = $self;
}

// A problem a customer reports, like "Washing machine leaks water"
entity Incidents : cuid, managed {
  title        : String(111);
  description  : String(1000);
  customer     : Association to Customers;
  urgency      : Association to Urgency default 'M';
  status       : Association to Status  default 'N';
  engineer     : String(100);
  conversation : Composition of many Conversations on conversation.incident = $self;
}

// One message in the conversation about an incident
entity Conversations : cuid, managed {
  incident : Association to Incidents;
  author   : String(100);
  message  : String(1000);
}

// How fast we must react: High, Medium or Low
entity Urgency : CodeList {
  key code        : String(1) enum { high = 'H'; medium = 'M'; low = 'L' };
      criticality : Integer; // the color in the app: 1 red, 2 amber, 3 green
}

// Where the incident is in its life
entity Status : CodeList {
  key code        : String(1) enum { new = 'N'; inProcess = 'I'; onHold = 'H'; resolved = 'R'; closed = 'C' };
      criticality : Integer; // the color in the app: 1 red, 2 amber, 3 green, 0 grey
}
