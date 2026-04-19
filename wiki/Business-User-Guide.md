# Business User Guide

This page is the business-facing and operational overview of the EOEX-DUNEX project.

## Who This Is For

This page is intended for:

- business stakeholders
- product owners
- operations leads
- UAT participants
- non-developer reviewers

## What This Project Delivers

EOEX-DUNEX currently provides a baseline Salesforce CRM for four DUNEX divisions:

- Studio
- Academy
- Events
- Publishing Kiosk

The current implementation gives each division:

- its own Lightning app
- dedicated business records
- navigation tabs
- page layouts
- Lightning record pages
- an app home page for entry into the division workflow

## Current Business Scope

Implemented business entities:

- Studio Project
- Shoot Schedule
- Academy Course
- Academy Enrollment
- Event Service
- Event Booking
- Publication
- Distribution Channel

See [[CRM Scaffold]] for the technical summary.

## What Reviewers Should Validate

During business review or UAT, confirm:

- the correct apps appear in the App Launcher
- the right tabs are visible for each division
- the app opens on the expected home page
- records open on the correct Lightning record page
- page layout fields support the intended business process
- the session language is correct for the testing user

## Current Known Limitations

- app home pages can require manual activation in the org
- that activation is operationally real in the org, but may not appear as meaningful retrieved metadata in source control
- some scratch-org CLI behavior around custom-field visibility is inconsistent, so certain automated sample-data paths may not reflect the full runtime UI state

## Signoff Expectations

A business signoff should confirm:

- the division apps are usable
- the data model matches the intended workflow scope
- the navigation and page experience are acceptable
- there are no blocking access issues for the assigned test user

## Where To Look Next

- [[CRM Scaffold]] for the current solution footprint
- [[Release History]] for what has been released or validated
- [[Troubleshooting]] for known issues that can affect testing