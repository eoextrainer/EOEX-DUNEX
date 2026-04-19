# CRM Scaffold

This page documents the currently implemented DUNEX CRM baseline in the repository.

## Overview

The current functional implementation is the DUNEX multi-division CRM scaffold introduced by `US-CRM-001`.

Its purpose is to provide a reusable baseline for four business divisions:

- Studio
- Academy
- Events
- Publishing Kiosk

## Applications

- `DUNEX_Studio`
- `DUNEX_Academy`
- `DUNEX_Events`
- `DUNEX_Publishing_Kiosk`

## Custom Objects

### Studio

- `Studio_Project__c`
- `Shoot_Schedule__c`

### Academy

- `Academy_Course__c`
- `Academy_Enrollment__c`

### Events

- `Event_Service__c`
- `Event_Booking__c`

### Publishing Kiosk

- `Publication__c`
- `Distribution_Channel__c`

## Experience Layer

Implemented UI metadata includes:

- eight object page layouts
- eight Lightning record pages
- four app home pages

Record pages:

- `Studio_Project_Record_Page`
- `Shoot_Schedule_Record_Page`
- `Academy_Course_Record_Page`
- `Academy_Enrollment_Record_Page`
- `Event_Service_Record_Page`
- `Event_Booking_Record_Page`
- `Publication_Record_Page`
- `Distribution_Channel_Record_Page`

App home pages:

- `DUNEX_Studio_Home`
- `DUNEX_Academy_Home`
- `DUNEX_Events_Home`
- `DUNEX_Publishing_Kiosk_Home`

## Security

The current shared access model is:

- permission set: `DUNEX_CRM_Access`

This grants application visibility, object access, and tab visibility for the scaffold.

## Important Runtime Notes

- the app home pages are deployable as `FlexiPage` metadata
- app home activation can require manual in-org activation in Lightning App Builder
- record page assignments are represented successfully in retrieved `CustomApplication` metadata
- app-home activation has not been observed to round-trip back as meaningful source metadata in this repository

## Validation Summary

The scaffold was validated in the scratch org by confirming:

- apps are available
- objects and tabs are present
- layouts and record pages deploy successfully
- app home pages exist and can be manually activated
- the test/admin user can access the experience in English

## Future Extension Areas

This scaffold is intended to support later additions such as:

- automation
- reports and dashboards
- richer sample data
- more granular security
- additional objects and flows per division