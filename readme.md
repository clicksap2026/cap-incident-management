# Customer Incident Management in SAP CAP (Project P3)

We sell and repair home appliances. When a washing machine leaks or a fridge stops cooling, the customer reports an **incident**. In this project you build the Fiori app that the support team uses to track and fix those incidents.

A practice project from the **clickERP** live SAP CAP course, for **Unit 4: Fiori elements and draft**. You write no JavaScript. Everything comes from annotations.

## Start in SAP Business Application Studio

```sh
git clone https://github.com/clicksap2026/cap-incident-management.git
cd cap-incident-management
npm install
cds watch
```

Open the link that BAS shows for port 4004.

## What is in the starter (branch `main`)

- `db/schema.cds`: Customers, Incidents, Conversations, and two code lists: Urgency and Status
- `db/data/`: 6 customers, 12 incidents, 6 conversation messages
- `srv/incident-service.cds`: the IncidentService
- `test.http`: four read requests

There is no app yet. You only see JSON. That is the problem you fix.

Follow `guide.md` step by step.

## What you build

- A **List Report** with filters and colored urgency and status
- An **Object Page** with a header, two field groups and a conversation table
- **Value helps**: search for a customer, dropdowns for urgency and status
- **Draft**: Create, Edit, Save and Discard
- **German** labels and code list names

## Finished code

The complete result is on the `final` branch:

```sh
git checkout final
```

On `final`, open the app with the **/incidents/webapp/index.html** link on the `cds watch` page.

---

🎓 Want live, instructor-led SAP training? Request a live session here: https://forms.gle/ovT9EgQquL5ERW2c6
