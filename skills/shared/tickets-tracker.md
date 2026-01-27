---
name: tickets-tracker
description: Personal ticket tracking across organizations
triggers:
  - /ticket command
  - When working on a ticket mentioned in conversation
---

# Tickets Tracker

Personal ticket tracking repository for work across multiple organizations.

## Repository Location

- **Local**: `/Users/jonathandiaz/projects/tickets-tracker/`
- **Remote**: `https://github.com/jonthdiaz/tickets-tracker` (private)

## Structure

```
tickets-tracker/
├── flexera/           # Flexera/NetApp FinOps tickets (CCM-XXXX)
├── transnetwork/      # Transnetwork tickets (TN-XXXX)
├── playvox/           # Playvox tickets (PV-XXXX)
└── templates/
    ├── ticket.md      # Ticket template
    └── session.md     # Session log template
```

## Ticket Format

Each ticket has:
- `<org>/<TICKET-ID>/ticket.md` - Main ticket file
- `<org>/<TICKET-ID>/sessions/` - Session logs

## When to Use

1. **Starting work on a ticket**: Read the ticket file for context
2. **Making progress**: Update ticket checklist items
3. **Ending a session**: Create session log with work done
4. **Continuing later**: Read session logs to pick up where you left off

## Organization Mapping

| Path Pattern | Ticket Prefix |
|--------------|---------------|
| `/Users/jonathandiaz/flexera/*` | CCM-XXXX |
| `/Users/jonathandiaz/transnetwork/*` | TN-XXXX |
| `/Users/jonathandiaz/playvox/*` | PV-XXXX |

## Commands

### Load Ticket
```
/ticket CCM-3474
```
Reads and loads the ticket context into the conversation.

### Update Ticket
When completing checklist items, update the ticket file:
```markdown
- [x] Completed task
- [ ] Pending task
```

### Create Session Log
At end of significant work, create `sessions/YYYY-MM-DD-summary.md`.

## Session Log Content

- Work completed
- Key decisions made
- Files modified
- Blockers encountered
- Next steps
