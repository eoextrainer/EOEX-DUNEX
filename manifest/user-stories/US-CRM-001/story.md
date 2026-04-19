# US-CRM-001 - DUNEX Multi-Division CRM Scaffold

## Story

As a DUNEX operations leader,
I want a Salesforce CRM foundation organized by business division,
so that Studio, Academy, Events, and Publishing Kiosk teams can manage their work in dedicated apps with consistent records, navigation, and access control.

## Background

DUNEX requested a fresh CRM scaffold in the active scratch org to support four business divisions:

- Studio
- Academy
- Events
- Publishing Kiosk

The implementation established one Lightning app per division, custom objects to represent the core operational records for each division, tabs to expose those records in navigation, page layouts and Lightning pages to improve usability, and a shared permission set so the test user can access the scaffold during validation.

## Business Value

- Gives each division a dedicated operating surface in Salesforce.
- Creates a reusable baseline for later layouts, automation, reporting, and sample-data work.
- Gives each division a starting Lightning experience with dedicated record pages and app home pages.
- Standardizes access to all newly introduced CRM components for unit testing and stakeholder review.

## Scope

### Applications

- DUNEX Studio
- DUNEX Academy
- DUNEX Events
- DUNEX Publishing Kiosk

### Data Model

- Studio Project and Shoot Schedule
- Academy Course and Academy Enrollment
- Event Service and Event Booking
- Publication and Distribution Channel

### Security

- DUNEX CRM Access permission set with app visibility, object permissions, and tab visibility for the new scaffold

### Experience Layer

- Eight custom object page layouts
- Eight Lightning record pages
- Four Lightning app home pages

## Acceptance Criteria

1. Four Lightning applications exist for the DUNEX divisions and can be opened in the scratch org.
2. Eight custom objects exist to support the division workflows.
3. Custom fields exist on those objects to capture the baseline operational data required by each division.
4. Each custom object has a custom tab so users can navigate directly from the division app.
5. Each division has page layouts and Lightning record pages assigned for its custom objects.
6. Each Lightning app has a dedicated app home page assigned for the administrator profile.
7. The DUNEX CRM Access permission set grants visibility to the apps, objects, and tabs needed for unit testing.
8. All metadata deploys successfully to the target scratch org.

## Implemented Metadata Summary

### Applications

- DUNEX_Studio
- DUNEX_Academy
- DUNEX_Events
- DUNEX_Publishing_Kiosk

### Custom Objects

- Studio_Project__c
- Shoot_Schedule__c
- Academy_Course__c
- Academy_Enrollment__c
- Event_Service__c
- Event_Booking__c
- Publication__c
- Distribution_Channel__c

### Tabs

- Studio_Project__c
- Shoot_Schedule__c
- Academy_Course__c
- Academy_Enrollment__c
- Event_Service__c
- Event_Booking__c
- Publication__c
- Distribution_Channel__c

### Layouts

- Studio Project Layout
- Shoot Schedule Layout
- Academy Course Layout
- Academy Enrollment Layout
- Event Service Layout
- Event Booking Layout
- Publication Layout
- Distribution Channel Layout

### Lightning Pages

- Studio_Project_Record_Page
- Shoot_Schedule_Record_Page
- Academy_Course_Record_Page
- Academy_Enrollment_Record_Page
- Event_Service_Record_Page
- Event_Booking_Record_Page
- Publication_Record_Page
- Distribution_Channel_Record_Page
- DUNEX_Studio_Home
- DUNEX_Academy_Home
- DUNEX_Events_Home
- DUNEX_Publishing_Kiosk_Home

### Permission Set

- DUNEX_CRM_Access

## Unit Test Deployment Notes

- Deployment target: `dunex-scratch-1`
- Deployment method: `sf project deploy start --manifest manifest/user-stories/US-CRM-001/package.xml --target-org dunex-scratch-1 --wait 60 --test-level RunLocalTests`
- Validation focus: successful metadata deployment and availability of the apps, objects, layouts, Lightning pages, and permission set in the scratch org