# Migrate Mosyle to Jamf Pro

> Migrate 450 Macs from Mosyle MDM to Jamf Pro

## Status

| Field | Value |
|-------|-------|
| **Status** | active |
| **Priority** | P1 |
| **Progress** | 0% |
| **Created** | 2026-02-10 |
| **Deadline** | 2026-05-01 |
| **Slug** | migrate-mosyle-to-jamf-pro |

## Goals

- [ ] **G1: Jamf Pro environment fully configured and validated** — Jamf Pro instance is production-ready with all Smart Groups, configuration profiles, policies, and scripts replicated from Mosyle before any devices migrate.
- [ ] **G2: All 450 Macs enrolled in Jamf Pro with zero data loss** — Every Mac is unenrolled from Mosyle and enrolled in Jamf Pro with its configuration profiles, apps, and security baselines intact.
- [ ] **G3: End-user disruption kept under 30 minutes per device** — Migration workflow is optimized so no user loses more than 30 minutes of productivity during their device's switchover.
- [ ] **G4: Security and compliance posture maintained throughout** — FileVault, firewall, OS patching, and endpoint protection remain enforced on every device at every stage of migration with no compliance gaps.
- [ ] **G5: Mosyle fully decommissioned** — Mosyle subscription cancelled, all API tokens revoked, APN certificate transitioned, and documentation archived by deadline.

## Milestones

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Project kickoff | 2026-02-10 | done |
| Jamf Pro environment build-out complete | 2026-02-28 | pending |
| Pilot migration (25 devices) complete | 2026-03-14 | pending |
| Wave 1 migration (150 devices) complete | 2026-03-28 | pending |
| Wave 2 migration (150 devices) complete | 2026-04-11 | pending |
| Wave 3 migration (125 devices) complete | 2026-04-25 | pending |
| Mosyle decommissioned and project closed | 2026-05-01 | pending |

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| APN certificate transition fails | High — devices lose push capability | Test APN renewal in Jamf Pro sandbox first; keep Mosyle APN active until cutover verified |
| User resistance or no-shows for migration windows | Medium — schedule slips | Communicate early, offer flexible windows, executive sponsor reinforcement |
| Configuration profile conflicts during dual-enrollment period | High — security policy violations | Use scoped exclusion groups; never dual-enroll a single device |
| Network bandwidth saturation during bulk enrollment | Medium — slow enrollments, timeouts | Stagger migrations across sites/VLANs; use Jamf distribution points |
| Jamf Pro license or infrastructure capacity issues | High — blocks migration | Confirm license count and cloud instance sizing before pilot |

## Links

_Add relevant links here._
