# Migrate Mosyle to Jamf Pro — Board

> Columns: backlog | research | in-progress | review | done

## Backlog

### Environment Setup & Configuration
- [ ] Provision Jamf Pro cloud instance and confirm license covers 450+ devices `P0` `#infrastructure` `due:2026-02-14`
- [ ] Configure Jamf Pro LDAP/IdP integration (Azure AD or Okta) for directory-based scoping `P0` `#infrastructure` `due:2026-02-17`
- [ ] Generate and upload APNs certificate to Jamf Pro using existing Apple ID `P0` `#infrastructure` `due:2026-02-14`
- [ ] Create Jamf Pro administrator accounts with role-based access `P1` `#infrastructure` `due:2026-02-17`
- [ ] Set up Jamf Pro distribution point(s) for package hosting `P1` `#infrastructure` `due:2026-02-21`
- [ ] Configure Jamf Pro network segments and site structure `P2` `#infrastructure` `due:2026-02-21`

### Inventory & Audit
- [ ] Export full device inventory from Mosyle (serial numbers, users, OS versions, installed apps) `P0` `#audit` `due:2026-02-14`
- [ ] Audit Mosyle configuration profiles and document each profile's purpose and payload `P0` `#audit` `due:2026-02-17`
- [ ] Audit Mosyle policies, scripts, and custom commands in use `P0` `#audit` `due:2026-02-17`
- [ ] Audit Mosyle-managed apps (VPP/ABM assignments) and document App Store vs. custom apps `P1` `#audit` `due:2026-02-19`
- [ ] Identify devices with DEP/ABM enrollment vs. user-initiated enrollment `P1` `#audit` `due:2026-02-19`
- [ ] Build migration wave roster — assign each device to Pilot, Wave 1, Wave 2, or Wave 3 `P1` `#planning` `due:2026-02-21`

### Jamf Pro Policy & Profile Build
- [ ] Recreate all security configuration profiles in Jamf Pro (FileVault, Firewall, Gatekeeper, etc.) `P0` `#profiles` `due:2026-02-24`
- [ ] Recreate Wi-Fi, VPN, and certificate profiles in Jamf Pro `P0` `#profiles` `due:2026-02-24`
- [ ] Recreate restrictions and privacy preferences (PPPC/TCC) profiles in Jamf Pro `P1` `#profiles` `due:2026-02-26`
- [ ] Build Smart Groups in Jamf Pro mirroring Mosyle device groups `P1` `#profiles` `due:2026-02-26`
- [ ] Configure software deployment policies (browsers, productivity apps, internal tools) `P1` `#profiles` `due:2026-02-26`
- [ ] Create OS update policies and deferral settings in Jamf Pro `P2` `#profiles` `due:2026-02-28`
- [ ] Build Jamf Pro Extension Attributes for any custom inventory data collected in Mosyle `P2` `#profiles` `due:2026-02-28`

### Migration Tooling & Automation
- [ ] Build migration script: unenroll from Mosyle MDM, trigger Jamf enrollment `P0` `#migration` `#automation` `due:2026-02-28`
- [ ] Create Jamf Pro PreStage Enrollment for DEP/ABM devices `P0` `#migration` `due:2026-02-21`
- [ ] Reassign DEP/ABM devices from Mosyle to Jamf Pro in Apple Business Manager `P0` `#migration` `due:2026-02-24`
- [ ] Build enrollment verification script (checks MDM profile, config profiles, apps) `P1` `#migration` `#automation` `due:2026-02-28`
- [ ] Create rollback procedure if migration fails on a device `P1` `#migration` `due:2026-02-28`
- [ ] Build post-enrollment Self Service configuration and branding in Jamf Pro `P2` `#migration` `due:2026-02-28`

### Communication & Change Management
- [ ] Draft migration communication plan (emails, Slack announcements, FAQ) `P1` `#comms` `due:2026-02-21`
- [ ] Send first notification to all Mac users about upcoming MDM migration `P1` `#comms` `due:2026-02-24`
- [ ] Create step-by-step end-user migration guide (with screenshots) `P1` `#comms` `due:2026-02-28`
- [ ] Schedule migration windows with pilot group users `P1` `#comms` `#pilot` `due:2026-03-03`

### Pilot Migration (25 devices)
- [ ] Validate Jamf Pro environment readiness — run pre-pilot checklist `P0` `#pilot` `due:2026-03-05`
- [ ] Migrate 25 pilot devices from Mosyle to Jamf Pro `P0` `#pilot` `#migration` `due:2026-03-10`
- [ ] Verify all configuration profiles applied correctly on pilot devices `P0` `#pilot` `#validation` `due:2026-03-11`
- [ ] Verify VPP apps and managed software installed on pilot devices `P1` `#pilot` `#validation` `due:2026-03-11`
- [ ] Collect pilot user feedback and document issues `P1` `#pilot` `due:2026-03-12`
- [ ] Remediate any issues found during pilot and update migration scripts `P0` `#pilot` `due:2026-03-14`

### Wave 1 Migration (150 devices)
- [ ] Send migration scheduling email to Wave 1 users `P1` `#comms` `#wave1` `due:2026-03-17`
- [ ] Migrate Wave 1 devices (150 Macs) from Mosyle to Jamf Pro `P0` `#wave1` `#migration` `due:2026-03-26`
- [ ] Run enrollment verification script on all Wave 1 devices `P0` `#wave1` `#validation` `due:2026-03-27`
- [ ] Resolve any Wave 1 migration failures or config drift `P0` `#wave1` `due:2026-03-28`

### Wave 2 Migration (150 devices)
- [ ] Send migration scheduling email to Wave 2 users `P1` `#comms` `#wave2` `due:2026-03-30`
- [ ] Migrate Wave 2 devices (150 Macs) from Mosyle to Jamf Pro `P0` `#wave2` `#migration` `due:2026-04-09`
- [ ] Run enrollment verification script on all Wave 2 devices `P0` `#wave2` `#validation` `due:2026-04-10`
- [ ] Resolve any Wave 2 migration failures or config drift `P0` `#wave2` `due:2026-04-11`

### Wave 3 Migration (125 devices)
- [ ] Send migration scheduling email to Wave 3 users `P1` `#comms` `#wave3` `due:2026-04-13`
- [ ] Migrate Wave 3 devices (125 Macs) from Mosyle to Jamf Pro `P0` `#wave3` `#migration` `due:2026-04-23`
- [ ] Run enrollment verification script on all Wave 3 devices `P0` `#wave3` `#validation` `due:2026-04-24`
- [ ] Resolve any Wave 3 migration failures or config drift `P0` `#wave3` `due:2026-04-25`

### Decommission & Close-Out
- [ ] Confirm all 450 devices enrolled and compliant in Jamf Pro `P0` `#validation` `due:2026-04-27`
- [ ] Remove all devices from Mosyle and delete configuration profiles `P1` `#decommission` `due:2026-04-28`
- [ ] Revoke Mosyle API tokens and disable Mosyle admin accounts `P1` `#decommission` `due:2026-04-29`
- [ ] Cancel Mosyle subscription `P1` `#decommission` `due:2026-04-30`
- [ ] Archive Mosyle documentation and export audit logs `P2` `#decommission` `due:2026-04-30`
- [ ] Write post-migration summary report and lessons learned `P2` `#documentation` `due:2026-05-01`
- [ ] Close project and mark all milestones done `P2` `#documentation` `due:2026-05-01`
- [ ] Test DEP token transfer `P1` `#testing`

## Research

## In Progress

## Review

## Done
