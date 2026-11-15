using support from '../db/schema';

service IncidentService {
  entity Incidents     as projection on support.Incidents;
  entity Conversations as projection on support.Conversations;
  @readonly entity Customers as projection on support.Customers;
  @readonly entity Urgency   as projection on support.Urgency;
  @readonly entity Status    as projection on support.Status;
}
