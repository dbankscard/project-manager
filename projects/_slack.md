# Slack Integration

## Channel

| Setting | Value |
|---------|-------|
| **Channel name** | #project-updates |
| **Channel ID** | _auto-discovered — create the channel in Slack and the system will find it_ |
| **Purpose** | All project manager output — standups, blockers, dashboards, milestone notifications |

## Features

| Feature | Trigger | Direction |
|---------|---------|-----------|
| Post standup | `/standup --slack` | Output |
| Post dashboard | `/dash --slack` | Output |
| Post blocker | `/log {slug} blocker ... --slack` | Output |
| Post milestone | `/log {slug} milestone ... --slack` | Output |
| Capture thread | `/capture {slack-thread-url} {slug}` | Input |
| Search Slack | `/search "query" --slack` | Input |
