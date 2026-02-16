# /enrich

Manage vendor contact files. Track account reps, contract renewals, escalation paths, and flag vendors overdue for check-ins based on tier cadence.

## Usage

```
/enrich [mode]
```

## Parameters

- **mode** (optional): One of `all`, `stale`, `renewals`, or a vendor name. Default: `stale`.
  - **all** — Full scan. Update every vendor file with recent interactions from available channels.
  - **stale** — Staleness check only. List vendors overdue for check-ins based on tier cadence.
  - **renewals** — Show upcoming contract renewals in the next 90 days.
  - **\<vendor-name\>** — Enrich a specific vendor. If no file exists, offer to create one.

## Vendor Tiers and Cadence

| Tier | Label | Cadence | Description |
|------|-------|---------|-------------|
| T1 | Critical | 30 days | MDM, identity, security, core infrastructure |
| T2 | Important | 90 days | Productivity, collaboration, secondary tools |
| T3 | Peripheral | 180 days | Misc tools, low-touch, niche utilities |

## Execution

Delegate to the **chief-of-staff** agent to:

1. **Load vendor contacts**:
   - Read all `.md` files in the `contacts/` directory at the project root.
   - Parse each file for tier, last interaction date, renewal date, and account rep info.
   - If `contacts/` doesn't exist and mode is a specific name, create the directory.

2. **Scan channels** (for `all` mode or specific vendor):
   - If Slack MCP available: search for recent messages mentioning the vendor or account rep.
   - If email MCP available: search for recent correspondence with the vendor.
   - Collect: last interaction date, topics discussed, any issues or action items.

3. **Update vendor files**:
   - Update the "Last Interaction" section if a more recent one is found.
   - Add new entries to the Interaction History table.
   - Update Talking Points based on recent topics.
   - Flag any contract or rep changes detected.

4. **Staleness check** (for `stale` or `all` mode):
   - Compare each vendor's last interaction date against their tier cadence.
   - Calculate days since last check-in and days overdue.
   - Suggest outreach actions for stale vendors.

5. **Renewal check** (for `renewals` or `all` mode):
   - Scan all vendor files for renewal dates.
   - Flag contracts renewing in the next 90 days.
   - Suggest: schedule QBR, review pricing, evaluate alternatives.

6. **New vendor creation** (when enriching an unknown vendor):
   - Search channels for information about the vendor.
   - Offer to create a vendor file from the template in `contacts/example-contact.md`.
   - Ask user to confirm tier assignment and fill in contract details.

## Vendor File Format

Vendor files are stored at `contacts/{vendor-slug}.md`. See `contacts/example-contact.md` for the full template. Key sections:

- **Account Rep** — Name, title, email, phone
- **Vendor Details** — Company, product, category, tier, support info
- **Contract** — License type/count, spend, renewal date, PO reference
- **Escalation Path** — Ordered support → rep → SE → manager
- **Notes** — Pricing intel, feature roadmap, integration details
- **Interaction History** — Date, type, summary table
- **Talking Points** — Topics for next interaction
- **Last Interaction** — Date, channel, pending follow-ups

## Output Format

### Stale Mode

```markdown
# Vendor Check-In — YYYY-MM-DD

## Overdue
- **Acme Corp** (T1) — Last: YYYY-MM-DD (45 days ago, 15 days overdue)
  Rep: Jane Smith | Renewal: 2026-12-01
  Suggest: Schedule QBR, review usage metrics

## Upcoming
- **Beta Tools** (T2) — Last: YYYY-MM-DD (80 days ago, due in 10 days)
  Rep: Bob Lee | Renewal: 2026-09-15

## Current
- N vendors up to date
```

### Renewals Mode

```markdown
# Upcoming Renewals — Next 90 Days

- **Acme Corp** — Renews 2026-05-01 (44 days) — $XX,000/yr — T1
  Action: Schedule renewal review, get updated quote
- **Delta SaaS** — Renews 2026-06-15 (89 days) — $X,000/yr — T3
  Action: Evaluate if still needed, check alternatives

## Summary
- N renewals in next 90 days | $XX,000 total annual spend at risk
```

## Examples

```
/enrich
/enrich stale
/enrich renewals
/enrich all
/enrich "Acme Corp"
/enrich acme-corp
```
