# AI Agent Logging Format

## Overview

This document defines the logging standards for the multi-agent system. Proper logging ensures traceability, debugging capability, and audit compliance.

---

## Log Types

| Log Type | Purpose | Retention |
|----------|---------|-----------|
| Session Log | Track conversation session | 30 days |
| Task Log | Track individual tasks | 90 days |
| Decision Log | Record key decisions | 1 year |
| Error Log | Track errors and issues | 90 days |
| Audit Log | Security and compliance | 1 year+ |

---

## Directory Structure

```
.ai-logs/
├── sessions/
│   └── YYYY-MM-DD_HHMMSS/
│       ├── session-summary.md
│       ├── task-log.json
│       └── decisions.md
├── archive/
│   └── [old sessions]
└── templates/
    ├── task-entry.md
    ├── decision-entry.md
    └── session-summary.md
```

---

## Session Log Format

### session-summary.md
```markdown
# Session Summary

## Session Information
| Field | Value |
|-------|-------|
| Session ID | [UUID] |
| Started | [ISO 8601 timestamp] |
| Ended | [ISO 8601 timestamp] |
| Duration | [HH:MM:SS] |

## User Request
[Original user request]

## Tasks Completed
| Task ID | Description | Agent | Status |
|---------|-------------|-------|--------|
| TASK-001 | [Description] | [Agent] | Complete |
| TASK-002 | [Description] | [Agent] | Complete |

## Decisions Made
- [Decision 1 summary]
- [Decision 2 summary]

## Agents Involved
- Manager (coordinator)
- [Agent 1]
- [Agent 2]

## Outcome
[Final outcome/deliverables]

## Notes
[Any important observations]
```

---

## Task Log Format (JSON)

### task-log.json
```json
{
  "session_id": "uuid-here",
  "tasks": [
    {
      "task_id": "TASK-001",
      "parent_task_id": null,
      "created_at": "2026-01-19T10:30:00Z",
      "completed_at": "2026-01-19T10:45:00Z",
      "status": "complete",
      "description": "Design authentication flow",
      "assigned_to": "architect",
      "assigned_by": "manager",
      "priority": "P1",
      "dependencies": [],
      "deliverables": [
        {
          "type": "document",
          "path": "docs/auth-design.md"
        }
      ],
      "subtasks": ["TASK-001-A", "TASK-001-B"],
      "timeline": [
        {
          "timestamp": "2026-01-19T10:30:00Z",
          "event": "created",
          "details": "Task created by Manager"
        },
        {
          "timestamp": "2026-01-19T10:30:05Z",
          "event": "assigned",
          "details": "Assigned to Architect"
        },
        {
          "timestamp": "2026-01-19T10:30:10Z",
          "event": "started",
          "details": "Architect began work"
        },
        {
          "timestamp": "2026-01-19T10:45:00Z",
          "event": "completed",
          "details": "Design document created"
        }
      ],
      "notes": "Clean design, approved by security"
    }
  ]
}
```

---

## Task Entry Format (Markdown)

### task-entry.md
```markdown
## Task Entry

### Task Information
| Field | Value |
|-------|-------|
| Task ID | TASK-001 |
| Created | 2026-01-19 10:30:00 UTC |
| Status | In Progress / Complete / Blocked |

### Assignment
| Field | Value |
|-------|-------|
| Assigned To | [Agent ID] |
| Assigned By | Manager |
| Priority | P0 / P1 / P2 |

### Description
[Detailed task description]

### Deliverables
- [ ] Deliverable 1
- [ ] Deliverable 2

### Dependencies
- Depends on: [Task IDs]
- Blocks: [Task IDs]

### Timeline
| Timestamp | Event | Details |
|-----------|-------|---------|
| [Time] | Created | [Notes] |
| [Time] | Assigned | [Notes] |
| [Time] | Started | [Notes] |
| [Time] | Completed | [Notes] |

### Output
[Description of output/deliverables]

### Notes
[Any relevant notes]
```

---

## Decision Log Format

### decisions.md
```markdown
# Decision Log

## Decision #001

### Metadata
| Field | Value |
|-------|-------|
| Decision ID | DEC-001 |
| Timestamp | 2026-01-19 10:35:00 UTC |
| Made By | Manager / [Agent] |
| Related Task | TASK-001 |

### Context
[What situation required this decision?]

### Options Considered
1. **Option A**: [Description]
   - Pros: [List]
   - Cons: [List]

2. **Option B**: [Description]
   - Pros: [List]
   - Cons: [List]

### Decision
[Which option was chosen]

### Rationale
[Why this option was selected]

### Impact
- Affected agents: [List]
- Affected tasks: [List]
- Timeline impact: [Description]

### Follow-up Actions
- [ ] [Action 1]
- [ ] [Action 2]

---

## Decision #002
[Next decision...]
```

---

## Event Types

### Task Events
| Event | Description |
|-------|-------------|
| `created` | Task was created |
| `assigned` | Task assigned to agent |
| `started` | Agent began work |
| `paused` | Work temporarily stopped |
| `resumed` | Work resumed |
| `blocked` | Task is blocked |
| `unblocked` | Block resolved |
| `submitted` | Submitted for review |
| `reviewed` | Review completed |
| `revision_requested` | Changes needed |
| `completed` | Task finished |
| `cancelled` | Task cancelled |

### Status Values
| Status | Description |
|--------|-------------|
| `pending` | Not yet started |
| `in_progress` | Currently being worked on |
| `blocked` | Cannot proceed |
| `review` | Awaiting review |
| `revision` | Changes requested |
| `complete` | Successfully finished |
| `cancelled` | Terminated |
| `failed` | Could not complete |

---

## Log Entry Schema

### Standard Log Entry
```json
{
  "timestamp": "2026-01-19T10:30:00.000Z",
  "level": "info",
  "session_id": "uuid",
  "task_id": "TASK-001",
  "agent": "manager",
  "event": "task_assigned",
  "message": "Assigned TASK-001 to backend agent",
  "metadata": {
    "target_agent": "backend",
    "priority": "P1"
  }
}
```

### Log Levels
| Level | Use Case |
|-------|----------|
| `debug` | Detailed debugging info |
| `info` | General operational events |
| `warn` | Potential issues |
| `error` | Errors requiring attention |
| `critical` | System failures |

---

## Error Logging

### Error Entry Format
```json
{
  "timestamp": "2026-01-19T10:30:00.000Z",
  "level": "error",
  "session_id": "uuid",
  "task_id": "TASK-001",
  "agent": "backend",
  "error": {
    "type": "ValidationError",
    "message": "Invalid API response format",
    "code": "ERR_VALIDATION_001",
    "stack": "[stack trace if available]"
  },
  "context": {
    "endpoint": "/api/users",
    "input": "[sanitized input]"
  },
  "resolution": {
    "status": "resolved",
    "action": "Fixed validation schema",
    "resolved_at": "2026-01-19T10:45:00.000Z"
  }
}
```

---

## Audit Log Requirements

### Security-Relevant Events
Must log:
- Authentication decisions
- Authorization checks
- Data access (sensitive)
- Configuration changes
- Error conditions
- Security decisions

### Audit Entry Format
```json
{
  "timestamp": "2026-01-19T10:30:00.000Z",
  "type": "audit",
  "session_id": "uuid",
  "event": "security_review_completed",
  "agent": "security",
  "task_id": "TASK-001",
  "details": {
    "review_type": "code_review",
    "outcome": "approved",
    "findings": 0,
    "scope": ["auth/routes.py", "auth/middleware.py"]
  }
}
```

---

## Log Aggregation

### Session Summary Generation
At session end, Manager generates summary:

```python
def generate_session_summary(session_id: str) -> str:
    """Generate session summary from logs."""
    tasks = load_task_log(session_id)
    decisions = load_decisions(session_id)

    summary = {
        "session_id": session_id,
        "total_tasks": len(tasks),
        "completed_tasks": sum(1 for t in tasks if t["status"] == "complete"),
        "agents_involved": list(set(t["assigned_to"] for t in tasks)),
        "decisions_made": len(decisions),
        "duration": calculate_duration(tasks)
    }

    return render_summary_template(summary)
```

---

## Log Retention Policy

| Log Type | Retention | Archive |
|----------|-----------|---------|
| Debug | 7 days | No |
| Info | 30 days | Optional |
| Task logs | 90 days | Yes |
| Decisions | 1 year | Yes |
| Audit | 1+ years | Yes |
| Errors | 90 days | Yes |

---

## Privacy Considerations

### Never Log
- API keys or secrets
- Passwords
- Full credit card numbers
- Unencrypted PII (unless necessary)

### Always Sanitize
- User input (log truncated/hashed)
- File contents (log metadata only)
- Request/response bodies (truncate large payloads)

### Log Reference Template
```json
{
  "user_input": "[SANITIZED - 150 chars]",
  "file_processed": {"name": "doc.pdf", "size": 1024, "hash": "abc123"},
  "api_response": "[TRUNCATED - see full in secure storage]"
}
```
