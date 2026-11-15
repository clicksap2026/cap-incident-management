# Project P3: Customer Incident Management

**Goal:** turn a plain CAP service into a real business app. Support staff see a list of incidents, open one, change it, and save it, all in a Fiori app. You write **no JavaScript**. Everything comes from annotations.

**Time:** about 100 minutes.

**You need:** Unit 4 (Fiori elements, annotations, value helps, draft, i18n). In class you built the IT Helpdesk. This project uses the same ideas on a new business case, on your own.

---

## Words you will meet

| Word | Meaning in one sentence |
| --- | --- |
| **Incident** | A problem a customer reports, like "My fridge is not cooling". |
| **Fiori elements** | SAP's ready-made screens that build themselves from your service and its annotations. |
| **Annotation** | A note in a `.cds` file, starting with `@`, that tells the app how to show something. |
| **List Report** | The first page of the app: filters on top, a table below. |
| **Object Page** | The page that opens when you click a row. It shows one record in sections. |
| **Value help** | A list the user picks from, so they don't have to type an ID or a code. |
| **Code list** | A small table of fixed choices, like High, Medium, Low. |
| **Criticality** | A number that gives a field a color: 1 red, 2 amber, 3 green, 0 grey. |
| **Draft** | A private, unfinished copy of a record. Nobody else sees it until you press Save. |
| **i18n** | Short for "internationalization": keeping all screen texts in a file, so you can translate them. |

---

## The use case

We sell and repair home appliances: washing machines, fridges, ovens. When something breaks, the customer calls us. The support team asks for an app with these features:

| # | The support team wants | How you build it |
| --- | --- | --- |
| 1 | Clear labels, not technical names like `customer_ID` | `@title` with i18n texts |
| 2 | A list of incidents with filters for status, urgency and customer | `@UI.SelectionFields`, `@UI.LineItem` |
| 3 | Urgency and status in color, so the red ones jump out | `Criticality` |
| 4 | Click an incident to see the problem, how we handle it, and the conversation | `@UI.HeaderInfo`, `@UI.FieldGroup`, `@UI.Facets` |
| 5 | See the customer's **name**, not a long ID, and search for a customer | `@Common.Text`, `@Common.ValueList` |
| 6 | Pick urgency and status from a dropdown | `@Common.ValueListWithFixedValues` |
| 7 | Edit safely: nothing is saved until I press Save, and I can Discard | `@odata.draft.enabled` |
| 8 | A new incident needs a title and a customer | `@mandatory` |
| 9 | Our team in Germany wants the app in German | `i18n_de.properties` and `_texts` CSV files |

---

## Your checklist

Try each step alone first. The code under each step is there when you need it.

- [ ] Run the starter and look at the raw data.
- [ ] Add labels and mandatory fields.
- [ ] Generate a Fiori elements app called `incidents`.
- [ ] Build the list page: filters and colored columns.
- [ ] Build the object page: header, two sections and a conversation table.
- [ ] Add value helps for customer, urgency and status.
- [ ] Turn on draft and try Create, Edit, Save and Discard.
- [ ] Translate the app into German.
- [ ] Push your work to your own GitHub repo.

---

## Step 1: run the starter (5 min)

In the BAS terminal:

```sh
cd ~/projects
git clone https://github.com/clicksap2026/cap-incident-management.git
cd cap-incident-management
npm install
cds watch
```

Open the link that BAS shows for port 4004. Click **Incidents**.

You see JSON. A support person can't work with this. Notice three problems:

1. `customer_ID` is a long ID, not a name.
2. `urgency_code` is `H`, not "High".
3. There's no way to edit anything, except by writing HTTP requests.

**What is in the starter:**

| File | What it has |
| --- | --- |
| `db/schema.cds` | Customers, Incidents, Conversations, and two code lists: Urgency and Status |
| `db/data/` | 6 customers, 12 incidents, 6 conversation messages, 3 urgencies, 5 statuses |
| `srv/incident-service.cds` | The `IncidentService`, served at `/odata/v4/incident` |
| `test.http` | Four read requests |

Open `db/schema.cds` and read it. Two things are new:

- `Urgency : CodeList` uses SAP's ready-made **code list** aspect. It gives each entry a `name` and a `descr`, both translatable.
- Each code list has a `criticality` column. The color lives with the status. "New" is red, "Resolved" is green.

---

## Step 2: labels and mandatory fields (10 min)

Create a folder `_i18n` in the project root, and a file `_i18n/i18n.properties` in it:

```properties
# Labels for the Incidents app, in English (the default language)
Incident=Incident
Incidents=Incidents
Title=Title
Description=Description
Customer=Customer
Email=Email
Phone=Phone
City=City
Urgency=Urgency
Status=Status
Engineer=Engineer
ReportedOn=Reported on
Problem=Problem
Handling=Handling
Conversation=Conversation
Author=Author
Message=Message
AddedOn=Added on
```

Now replace the whole `db/schema.cds` with this:

```cds
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
```

| Code | Meaning |
| --- | --- |
| `@title: '{i18n>Customer}'` | The label is the text with the key `Customer` in the i18n file. |
| `@mandatory` | The field must have a value before the record is saved. |
| `@assert.target` | The customer must really exist. |

**Check:** `cds watch` restarts by itself. There are no errors in the terminal.

---

## Step 3: generate the Fiori app (10 min)

1. Press **Ctrl+Shift+P** (Mac: **Cmd+Shift+P**) and run **Fiori: Open Application Generator**.
2. Choose **List Report Page**. Click **Next**.
3. Data source: **Use a Local CAP Project**. Pick `cap-incident-management`. Service: `IncidentService (Node.js)`.
4. Main entity: **Incidents**. Navigation entity: **None**.
5. "Automatically add table columns...": choose **No**. We write our own annotations.
6. Module name: `incidents`. Application title: `Customer Incidents`. Namespace: `support`.
7. Click **Finish** and wait for it to install.

The generator creates:

- `app/incidents/webapp/`: the app itself. You will not change these files.
- `app/incidents/annotations.cds`: where your annotations go.
- `app/services.cds`: one line that loads your annotations.

> The generator may also add a few lines to `package.json`. That is fine.

**Check:** reload the `cds watch` page. Under **Web Applications** you see a link for `incidents`. Click it, then click **Go**. You see a table, but it may be empty or show only one or two columns. That's what you fix next.

---

## Step 4: the list page (15 min)

Open `app/incidents/annotations.cds`. Delete everything in it and start with this:

```cds
using IncidentService as service from '../../srv/incident-service';

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
  ]
);
```

| Code | Meaning |
| --- | --- |
| `using IncidentService as service` | Use the short name `service` for our service in this file. |
| `UI.SelectionFields` | The filter fields above the table. |
| `UI.LineItem` | The columns of the table, in this order. |
| `Criticality: urgency.criticality` | Color this cell with the `criticality` of the urgency, from the code list. |

**Check:** reload the app and click **Go**. You see 12 incidents. Urgency and status have colors. But the customer still shows an ID, and urgency shows `H`. Step 6 fixes that.

---

## Step 5: the object page (15 min)

Click a row. The object page is empty. An object page needs three things:

- a **header**: what is this record called?
- **field groups**: which fields go together?
- **facets**: which sections does the page have, in which order?

Add this inside the same `@( ... )`, right after the `UI.LineItem` block. Put a comma after the `]` of `UI.LineItem` first.

```cds
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
```

The third section points to `conversation/@UI.LineItem`: "show the conversation as a table, with the columns of the Conversations line item". So the Conversations entity needs its own line item. Add this at the end of the file, **after** the closing `);`:

```cds
// Columns of the conversation table on the object page
annotate service.Conversations with @(UI.LineItem: [
  { Value: author },
  { Value: message },
  { Value: createdAt, Label: '{i18n>AddedOn}' }
]);
```

| Code | Meaning |
| --- | --- |
| `#Problem` | A qualifier: a name, so one entity can have two field groups. |
| `Description: { Value: customer.name }` | The small line under the title shows the customer's name. |
| `Target: '@UI.FieldGroup#Problem'` | This section shows the field group called Problem. |

**Check:** click "Washing machine leaks water". You see the title, the customer's name under it, and three sections. The conversation has two messages.

---

## Step 6: value helps (15 min)

Now show names instead of codes and IDs, and let the user pick them. Add this at the end of the file:

```cds
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

annotate service.Conversations with {
  message @UI.MultiLineText;
};
```

| Code | Meaning |
| --- | --- |
| `Text: customer.name` | Show the name that belongs to this ID. |
| `TextArrangement: #TextOnly` | Show only the name, hide the ID. |
| `ValueList` | Where to find the choices: the `Customers` entity of our service. |
| `ValueListParameterInOut` | When the user picks a row, copy its `ID` into `customer_ID`. |
| `ValueListParameterDisplayOnly` | Show this column in the list, but don't copy it. |
| `ValueListWithFixedValues: true` | Show a simple dropdown, not a search dialog. Good for short lists. |
| `@UI.MultiLineText` | A big text box instead of one line. |

**Check:** the list shows "Priya Sharma" and "High", not IDs and codes. The customer filter opens a search dialog. The urgency and status filters are dropdowns.

---

## Step 7: draft (10 min)

Try to edit an incident. There's no **Edit** button, and no **Create** button either. Draft adds both, safely.

Add this line near the top of `annotations.cds`, right after the `using` line:

```cds
// Draft: create and edit incidents safely, with Save and Discard
annotate service.Incidents with @odata.draft.enabled;
```

The Conversations are a **composition** of Incidents, so they become part of the same draft. You don't annotate them.

**Check in the app:**

1. Click **Create**. Type only a description. Click **Save**. You get two errors: title and customer are missing. That is `@mandatory` at work.
2. Fill in a title, pick a customer, and click **Save**. The new incident is in the list with urgency "Medium" and status "New". Those came from `default`.
3. Open "Fridge is not cooling". Click **Edit**. Set the engineer to `Suresh Patil` and the status to "In process". Add a conversation line. Click **Discard**. Nothing changed.
4. Do the same again, and click **Save** this time. The change is saved.

**Check with test.http:** add these requests at the end of `test.http` and send them one by one.

```http
### 5. Draft step 1: create a new incident as a draft (like pressing Create)
# @name draft
POST {{svc}}/Incidents
Content-Type: application/json

{ "title": "Fridge door alarm keeps beeping", "customer_ID": "a1000000-0000-4000-8000-000000000004" }

### 6. Draft step 2: change the draft (like typing in the form)
PATCH {{svc}}/Incidents(ID={{draft.response.body.ID}},IsActiveEntity=false)
Content-Type: application/json

{ "urgency_code": "L", "engineer": "Deepa Nair" }

### 7. Draft step 3: add a conversation line to the draft
POST {{svc}}/Incidents(ID={{draft.response.body.ID}},IsActiveEntity=false)/conversation
Content-Type: application/json

{ "author": "Arjun Mehta", "message": "It beeps even when the door is closed." }

### 8. Draft step 4: activate the draft (like pressing Save)
POST {{svc}}/Incidents(ID={{draft.response.body.ID}},IsActiveEntity=false)/IncidentService.draftActivate
Content-Type: application/json

{}

### 9. Read it back: status is New and the message is there
GET {{svc}}/Incidents(ID={{draft.response.body.ID}},IsActiveEntity=true)?$expand=status,conversation
```

| Code | Meaning |
| --- | --- |
| `IsActiveEntity=false` | The draft copy. Only you see it. |
| `IsActiveEntity=true` | The saved copy that everyone sees. |
| `draftActivate` | Turn the draft into the saved copy. This is what **Save** does. |

---

## Step 8: German (10 min)

Create `_i18n/i18n_de.properties`:

```properties
# Labels for the Incidents app, in German
Incident=Störung
Incidents=Störungen
Title=Titel
Description=Beschreibung
Customer=Kunde
Email=E-Mail
Phone=Telefon
City=Stadt
Urgency=Dringlichkeit
Status=Status
Engineer=Techniker
ReportedOn=Gemeldet am
Problem=Problem
Handling=Bearbeitung
Conversation=Verlauf
Author=Autor
Message=Nachricht
AddedOn=Hinzugefügt am
```

That translates the labels. The urgency and status **names** are data, not labels. They are translated in `_texts` files. Create `db/data/support-Urgency_texts.csv`:

```csv
code;locale;name
H;de;Hoch
M;de;Mittel
L;de;Niedrig
```

And `db/data/support-Status_texts.csv`:

```csv
code;locale;name
N;de;Neu
I;de;In Bearbeitung
H;de;Angehalten
R;de;Gelöst
C;de;Geschlossen
```

**Check:** open the app and add `?sap-language=de` to the end of the address, before any `#`. Labels and the urgency and status names are now German. The incident titles stay English, because they are normal data, typed by people.

Also add this request to `test.http`:

```http
### 10. Status names in German (localized data). Try en and de.
GET {{svc}}/Status
Accept-Language: de
```

---

## Step 9: AI task in BAS (10 min)

Ask Claude in BAS:

> Look at app/incidents/annotations.cds. Explain each annotation to a beginner in one sentence. Then add a header data point that shows the urgency in color at the top of the object page. Show me the change before you make it.

Then:

1. Read Claude's change. Do you understand every line? If not, ask.
2. Reload the app and check that the urgency now shows in the header.

---

## Step 10: push to your own GitHub repo (5 min)

On GitHub, create a new empty repo called `incident-management`. Then, in the BAS terminal:

```sh
git remote set-url origin https://github.com/<your-username>/incident-management.git
git add .
git commit -m "Incident Management app with Fiori elements and draft"
git push -u origin main
```

`git remote set-url origin` points your project at **your** repo instead of ours.

---

## Common errors

| What you see | Why | Fix |
| --- | --- | --- |
| The app shows no columns, or your changes don't appear | The browser keeps an old copy of the annotations | Reload with **Ctrl+Shift+R**. Still nothing? Open `/odata/v4/incident/$metadata` and search for `UI.LineItem`. |
| Annotations are not in `$metadata` at all | `app/services.cds` is missing, or doesn't load your file | It must contain `using from './incidents/annotations';` |
| A label shows a key like `ReportedOn` instead of a real text | The key is missing or misspelled in `i18n.properties` | Keys are case-sensitive. Check the folder is `_i18n` with an underscore. |
| No **Create** or **Edit** button | Draft is not on | Add `annotate service.Incidents with @odata.draft.enabled;` |
| `404` when you send request 6 in `test.http` | Request 5 was not sent first, so `draft` has no ID | Send request 5, then 6. |
| Customer shows an ID, not a name | `Text` is missing, or points to the wrong field | `Text: customer.name` and `TextArrangement: #TextOnly` |
| The urgency dropdown is a search dialog | `ValueListWithFixedValues` is missing | Add `ValueListWithFixedValues: true` |
| No colors | `Criticality` path is wrong | It is `urgency.criticality`, with a dot |
| `Mismatched ‹Identifier›, expecting ‘,’` when `cds watch` starts | A missing comma between two `UI.` blocks | Each block inside `@( ... )` ends with a comma, except the last |
| German text doesn't show | The URL parameter is after `#` | Put `?sap-language=de` before the `#` |

**Debugging tip:** press **F12** in the browser and open the **Network** tab. Reload. Click the `$batch` requests to see exactly what the app asked for and what CAP answered. An error message from CAP is often clearer than the one in the app.

---

## Done?

Your project is done when:

- the list shows 12 incidents with names, not IDs, and colored urgency and status,
- the object page has a header and three sections,
- you can create an incident, and Save refuses it without a title,
- Discard throws away your changes,
- the app works in German with `?sap-language=de`.

The finished project is on the branch `final`:

```sh
git checkout final
```

## Stretch goals

- Add `engineer` as a fourth filter.
- Show the number of incidents per customer: add a Customers list page to the same app.
- Ask Claude in BAS to add 6 more incidents to the CSV file, then check every `customer_ID` really exists.

## What's next

Unit 5: the app saves anything that passes `@mandatory`. But what if an incident is closed with no engineer? Rules like that need code. Next, you learn JavaScript event handlers.
