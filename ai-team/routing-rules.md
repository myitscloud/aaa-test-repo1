# Agent Routing Rules

## Overview

This document defines how the Manager Agent routes tasks to specialized agents. The Router (Main Claude Code) passes all tasks to the Manager, which then analyzes and delegates work.

---

## Routing Flow

```
User Request
     ↓
┌─────────────┐
│   Router    │  ← Main Claude Code (minimal processing)
└──────┬──────┘
       ↓
┌─────────────┐
│   Manager   │  ← Analyzes, breaks down, routes
└──────┬──────┘
       ↓
┌─────────────────────────────────────┐
│         Agent Selection             │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
│  │ A1 │ │ A2 │ │ A3 │ │ A4 │ ...   │
│  └────┘ └────┘ └────┘ └────┘       │
└─────────────────────────────────────┘
```

---

## Task Classification

### By Domain

| Domain | Primary Agent | Supporting Agents |
|--------|---------------|-------------------|
| API Development | Backend | Security, SQL-DB |
| UI Development | Frontend | Architect |
| Database Design | SQL-DB / NoSQL-DB | Architect, Backend |
| Infrastructure | DevOps | Security, Cloud |
| Documentation | Docs | Markdown |
| Testing | QA | Backend, Frontend |
| Security Review | Security | Architect |
| AI/ML Features | LLM-Integration | Vector-DB, Backend |
| File Processing | Doc-Parser | OCR, Data-Engineer |
| Media Creation | Image/Video/Audio-Gen | Frontend |

---

## Keyword-Based Routing

### Backend Triggers
- "API", "endpoint", "REST", "GraphQL"
- "server", "backend", "service"
- "authentication", "authorization"
- "business logic", "validation"

### Frontend Triggers
- "UI", "interface", "component"
- "React", "Vue", "Angular", "CSS"
- "responsive", "mobile", "design"
- "button", "form", "page", "layout"

### Database Triggers
- "database", "schema", "table", "query"
- "SQL", "PostgreSQL", "MySQL"
- "MongoDB", "NoSQL", "document"
- "migration", "index", "relationship"

### DevOps Triggers
- "deploy", "CI/CD", "pipeline"
- "Docker", "Kubernetes", "container"
- "infrastructure", "AWS", "Azure", "GCP"
- "monitoring", "logging", "alerting"

### Security Triggers
- "security", "vulnerability", "OWASP"
- "encryption", "auth", "permission"
- "audit", "compliance", "penetration"
- "secret", "credential", "token"

### Documentation Triggers
- "document", "README", "guide"
- "API docs", "changelog", "tutorial"
- "comment", "explain", "describe"

---

## Complex Task Routing

### Multi-Agent Tasks

Some tasks require multiple agents working together:

```
Task: "Build user authentication"
     ↓
Manager Analysis:
├── Architect: Design auth flow
├── Backend: Implement auth API (after design)
├── SQL-DB: User/session schema (parallel with Backend)
├── Frontend: Login UI (after API)
├── Security: Review (after implementation)
└── QA: Test auth flows (after review)
```

### Parallel vs Sequential

**Can Run in Parallel:**
```
┌─────────────────────────────────────┐
│  Backend API  │  Database Schema    │
│  (endpoints)  │  (tables/indexes)   │
└───────────────┴─────────────────────┘
         │ Both depend on: Design
         ▼
┌─────────────────────────────────────┐
│           Frontend UI               │
│    (depends on API contract)        │
└─────────────────────────────────────┘
```

**Must Run Sequential:**
```
Design → Implementation → Review → Testing → Documentation
```

---

## Routing Decision Matrix

| If Task Involves... | And Also... | Route To |
|---------------------|-------------|----------|
| API + Database | New feature | Architect → Backend + SQL-DB |
| API + Security | Auth/permissions | Backend + Security |
| UI + API | Full feature | Frontend + Backend |
| Bug + Backend | Server error | Backend |
| Bug + Frontend | UI issue | Frontend |
| Bug + Unknown | Unclear source | QA (to diagnose) |
| Performance | Database | SQL-DB + Architect |
| Performance | Application | Architect + Backend |
| New service | Cloud | Cloud + DevOps |
| Data processing | Files | Doc-Parser + Data-Engineer |
| AI feature | LLM | LLM-Integration + Vector-DB |
| Image/Media | Generation | Image/Video/Audio-Gen |

---

## Escalation Rules

### When to Escalate to Router (User)

1. **Ambiguous Requirements**
   - Multiple valid interpretations
   - Missing critical information
   - Conflicting requirements

2. **Scope Decisions**
   - Feature larger than expected
   - Requires architectural changes
   - Timeline concerns

3. **Technical Blockers**
   - External dependency issues
   - Platform limitations
   - Requires access/permissions

4. **Security Concerns**
   - Potential vulnerability
   - Compliance questions
   - Data handling unclear

### When Manager Can Decide

1. Technical implementation details
2. Agent assignment
3. Task breakdown
4. Parallelization strategy
5. Review assignments

---

## Agent Availability

### Always Available (Core)
- Manager
- Architect
- Backend
- Frontend
- DevOps
- QA
- Docs
- Security

### Specialized (On-Demand)
- Database Agents (SQL, NoSQL, Vector)
- Media Agents (Image, Video, Audio, 3D)
- Document Agents (Parser, Writer, OCR, Markdown)
- Integration Agents (API, Auth, Cloud, LLM)

---

## Load Balancing

When an agent is busy:

1. **Queue Task** - If task can wait
2. **Parallel Work** - Split if possible
3. **Alternative Agent** - If skills overlap
4. **Escalate** - If urgent and blocked

---

## Routing Examples

### Example 1: Simple API Endpoint
```
Request: "Add GET /api/users endpoint"

Manager Analysis:
- Domain: Backend
- Complexity: Low
- Single agent sufficient

Routing:
- Primary: Backend
- Supporting: None (may involve SQL-DB if needed)
```

### Example 2: Full Feature
```
Request: "Build password reset feature"

Manager Analysis:
- Domain: Full-stack
- Complexity: Medium
- Multiple agents needed

Routing:
1. Architect: Design reset flow
2. Backend: Reset API, email service (parallel)
3. SQL-DB: Reset token schema (parallel with Backend)
4. Frontend: Reset UI (after API)
5. Security: Review token handling
6. QA: Test full flow
7. Docs: Update user guide
```

### Example 3: Bug Fix
```
Request: "Login button not working"

Manager Analysis:
- Domain: Unknown (need diagnosis)
- Type: Bug

Routing:
1. QA: Reproduce and diagnose
2. [Based on diagnosis]:
   - Frontend issue → Frontend
   - API issue → Backend
   - Auth issue → Backend + Security
```

### Example 4: AI Feature
```
Request: "Add AI-powered search"

Manager Analysis:
- Domain: AI/Search
- Complexity: High
- Specialized agents needed

Routing:
1. Architect: Design search architecture
2. Vector-DB: Embedding schema, indexing
3. LLM-Integration: Embedding pipeline, query processing
4. Backend: Search API
5. Frontend: Search UI
6. QA: Test search quality
```

---

## Agent Communication Protocol

### Task Assignment Format
```json
{
  "task_id": "TASK-001",
  "from": "manager",
  "to": "backend",
  "type": "assignment",
  "task": {
    "description": "Implement user authentication API",
    "deliverables": ["POST /auth/login", "POST /auth/logout"],
    "dependencies": ["TASK-000 (Architect design)"],
    "deadline": null,
    "priority": "P1"
  }
}
```

### Status Report Format
```json
{
  "task_id": "TASK-001",
  "from": "backend",
  "to": "manager",
  "type": "status",
  "status": "complete",
  "output": {
    "files_created": ["src/auth/routes.py"],
    "tests_written": true,
    "notes": "Ready for security review"
  }
}
```

---

## Routing Performance Metrics

Track and optimize:
- Average time to route
- Routing accuracy (correct agent first time)
- Re-routing frequency
- Parallel execution efficiency
- Agent utilization
