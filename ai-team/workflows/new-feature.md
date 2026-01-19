# New Feature Workflow

## Overview

This workflow defines the process for implementing new features using the multi-agent system.

---

## Workflow Stages

```
┌─────────────┐
│   REQUEST   │ User submits feature request
└──────┬──────┘
       ▼
┌─────────────┐
│   ANALYZE   │ Manager analyzes and breaks down task
└──────┬──────┘
       ▼
┌─────────────┐
│   DESIGN    │ Architect designs solution
└──────┬──────┘
       ▼
┌─────────────┐
│  IMPLEMENT  │ Development agents build feature
└──────┬──────┘
       ▼
┌─────────────┐
│   REVIEW    │ Code review and security check
└──────┬──────┘
       ▼
┌─────────────┐
│    TEST     │ QA validates implementation
└──────┬──────┘
       ▼
┌─────────────┐
│  DOCUMENT   │ Documentation updated
└──────┬──────┘
       ▼
┌─────────────┐
│   DEPLOY    │ Feature deployed (if requested)
└─────────────┘
```

---

## Stage Details

### 1. REQUEST
**Input:** Feature request from user
**Output:** Documented request with acceptance criteria

**Manager Actions:**
- Log incoming request
- Clarify requirements if ambiguous
- Document acceptance criteria
- Assign priority level

---

### 2. ANALYZE
**Agents:** Manager
**Output:** Task breakdown and agent assignments

**Manager Actions:**
1. Analyze scope and complexity
2. Identify required agents
3. Break into subtasks
4. Determine parallelization opportunities
5. Create assignments

**Decision Points:**
- Is the request clear enough? → Ask for clarification
- Is it feasible? → Discuss constraints with user
- What agents are needed? → Based on task analysis

---

### 3. DESIGN
**Agents:** Architect (Primary), Security (Supporting)
**Output:** Technical design document

**Architect Actions:**
1. Review existing architecture
2. Design component structure
3. Define API contracts (if applicable)
4. Identify database changes (if applicable)
5. Document design decisions

**Security Actions:**
- Review security implications
- Identify potential vulnerabilities
- Recommend security controls

**Parallel:** Can begin while Manager finalizes analysis

---

### 4. IMPLEMENT
**Agents:** Backend, Frontend, Database Agents (as needed)
**Output:** Working code

**Implementation Flow:**
```
Parallel Execution (when independent):
├── Backend: API endpoints, business logic
├── Frontend: UI components, integration
├── SQL-DB: Schema changes, migrations
└── Other specialists as needed

Sequential (when dependent):
1. Database migrations first
2. Backend implementation
3. Frontend integration
```

**Agent Responsibilities:**

| Agent | Typical Tasks |
|-------|---------------|
| Backend | API endpoints, services, business logic |
| Frontend | UI components, state management, API integration |
| SQL-DB | Schema design, migrations, queries |
| NoSQL-DB | Document schema, queries |

---

### 5. REVIEW
**Agents:** Architect (Code Review), Security (Security Review)
**Output:** Review feedback, approved code

**Architect Review:**
- Architecture compliance
- Code quality
- Design patterns
- Performance considerations

**Security Review:**
- OWASP top 10 check
- Authentication/authorization
- Input validation
- Data protection

**Process:**
1. Agent submits code for review
2. Reviews run in parallel
3. Feedback provided
4. Agent addresses feedback
5. Re-review if needed
6. Approval granted

---

### 6. TEST
**Agents:** QA
**Output:** Test results, bug reports

**QA Actions:**
1. Write/update test cases
2. Execute unit tests
3. Execute integration tests
4. Perform exploratory testing
5. Validate acceptance criteria
6. Report bugs (if any)

**Bug Handling:**
1. QA reports bug to Manager
2. Manager assigns fix to appropriate agent
3. Agent fixes and re-submits
4. QA verifies fix

---

### 7. DOCUMENT
**Agents:** Docs, Markdown
**Output:** Updated documentation

**Documentation Tasks:**
- Update README if needed
- Document new API endpoints
- Update user guides
- Add code comments
- Update changelog

---

### 8. DEPLOY (Optional)
**Agents:** DevOps
**Output:** Deployed feature

**Deployment Actions:**
1. Prepare deployment configuration
2. Deploy to staging
3. Run smoke tests
4. Deploy to production (if approved)
5. Monitor for issues

---

## Parallel Execution Opportunities

### Can Run in Parallel
- Backend and Frontend (after API contract defined)
- Unit tests and documentation
- Multiple independent components

### Must Be Sequential
- Database migration → Backend code
- Implementation → Code review
- Code review → Testing
- Testing → Documentation (for test results)

---

## Communication Flow

```
User ──► Router ──► Manager ──► [Agents]
                        ▲           │
                        └───────────┘
                         (Reports)
```

---

## Task Log Template

```markdown
## Feature: [Feature Name]

### Request
- Received: [Timestamp]
- Priority: [P0/P1/P2]
- Description: [Feature description]

### Analysis
- Complexity: [Low/Medium/High]
- Agents Required: [List]
- Estimated Subtasks: [Number]

### Assignments
| Agent | Subtask | Status | Notes |
|-------|---------|--------|-------|
| Architect | Design solution | Complete | |
| Backend | Implement API | In Progress | |

### Timeline
- Design: [Completed/In Progress]
- Implementation: [Completed/In Progress]
- Review: [Pending/In Progress]
- Testing: [Pending/In Progress]
- Documentation: [Pending/In Progress]

### Blockers
- [Any blockers]

### Decisions
- [Key decisions made]

### Completion
- Status: [In Progress/Complete]
- Final Notes: [Summary]
```

---

## Escalation Triggers

Escalate to User/Router when:
- Requirements are ambiguous
- Scope change is needed
- Technical blockers discovered
- Security concerns identified
- Timeline cannot be met

---

## Quality Gates

| Gate | Criteria |
|------|----------|
| Design Approval | Architect approves design |
| Code Review | No critical issues, style compliant |
| Security Review | No high/critical vulnerabilities |
| QA Approval | All tests pass, acceptance criteria met |
| Documentation | All required docs updated |
