# Code Review Workflow

## Overview

This workflow defines the process for code reviews using the multi-agent system. Code reviews ensure quality, maintainability, and security.

---

## Workflow Stages

```
┌─────────────┐
│   SUBMIT    │ Code submitted for review
└──────┬──────┘
       ▼
┌─────────────┐
│   ASSIGN    │ Manager assigns reviewers
└──────┬──────┘
       ▼
┌─────────────────────────────┐
│         REVIEW              │
│  ┌─────────┐  ┌──────────┐ │
│  │Architect│  │ Security │ │  (Parallel)
│  │ Review  │  │  Review  │ │
│  └─────────┘  └──────────┘ │
└──────┬──────────────────────┘
       ▼
┌─────────────┐
│  FEEDBACK   │ Consolidate feedback
└──────┬──────┘
       ▼
┌─────────────┐
│   ADDRESS   │ Author addresses feedback
└──────┬──────┘
       ▼
┌─────────────┐
│   APPROVE   │ Final approval
└─────────────┘
```

---

## Review Types

| Type | Reviewer | Focus | When Required |
|------|----------|-------|---------------|
| Architecture | Architect | Design, patterns, structure | All features |
| Security | Security | Vulnerabilities, auth, data | All changes |
| Performance | Architect | Efficiency, scalability | When relevant |
| Accessibility | Frontend | a11y compliance | UI changes |

---

## Stage Details

### 1. SUBMIT
**Agent:** Implementing Agent
**Output:** Code ready for review

**Submission Checklist:**
- [ ] Code complete and tested locally
- [ ] Self-review completed
- [ ] Tests written/updated
- [ ] Documentation updated
- [ ] Commit messages clear

**Submission Format:**
```markdown
## Code Review Request

### Summary
[Brief description of changes]

### Type
- [ ] New feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation

### Changes
- [File 1]: [Description]
- [File 2]: [Description]

### Testing Done
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

### Review Focus
[Any specific areas to focus on]
```

---

### 2. ASSIGN
**Agent:** Manager
**Output:** Review assignments

**Assignment Criteria:**
| Change Type | Primary Reviewer | Secondary |
|-------------|------------------|-----------|
| Backend API | Architect | Security |
| Frontend UI | Architect | Frontend (peer) |
| Database | Architect | SQL-DB |
| Security-related | Security | Architect |
| Infrastructure | DevOps | Security |

---

### 3. REVIEW
**Agents:** Architect, Security (in parallel)
**Output:** Review comments

#### Architect Review Checklist

**Design & Architecture:**
- [ ] Follows established patterns
- [ ] Appropriate separation of concerns
- [ ] No unnecessary complexity
- [ ] Consistent with existing codebase

**Code Quality:**
- [ ] Readable and maintainable
- [ ] Meaningful names
- [ ] No code duplication
- [ ] Appropriate error handling

**Performance:**
- [ ] No obvious performance issues
- [ ] Efficient algorithms
- [ ] Appropriate data structures
- [ ] No N+1 queries

**Testing:**
- [ ] Adequate test coverage
- [ ] Tests are meaningful
- [ ] Edge cases covered

#### Security Review Checklist

**Authentication & Authorization:**
- [ ] Proper authentication required
- [ ] Authorization checks in place
- [ ] No privilege escalation possible

**Input Validation:**
- [ ] All input validated
- [ ] No SQL injection
- [ ] No command injection
- [ ] No XSS vulnerabilities

**Data Protection:**
- [ ] Sensitive data handled properly
- [ ] No secrets in code
- [ ] Encryption where needed
- [ ] No PII in logs

**General Security:**
- [ ] No known vulnerable dependencies
- [ ] Secure defaults
- [ ] Proper error handling (no info leakage)

---

### 4. FEEDBACK
**Agent:** Manager
**Output:** Consolidated review feedback

**Feedback Categories:**
| Category | Symbol | Action Required |
|----------|--------|-----------------|
| Blocker | 🔴 | Must fix before merge |
| Concern | 🟡 | Should address |
| Suggestion | 🟢 | Nice to have |
| Question | ❓ | Needs clarification |
| Praise | 👍 | Positive feedback |

**Feedback Format:**
```markdown
## Review Feedback

### Summary
[Overall assessment]

### Blockers 🔴
1. [Issue and location]
   - Recommendation: [How to fix]

### Concerns 🟡
1. [Issue and location]
   - Recommendation: [Suggestion]

### Suggestions 🟢
1. [Improvement idea]

### Questions ❓
1. [Clarification needed]

### Positive Notes 👍
- [Good practices observed]
```

---

### 5. ADDRESS
**Agent:** Implementing Agent
**Output:** Updated code

**Process:**
1. Review all feedback
2. Address blockers (required)
3. Address concerns (recommended)
4. Consider suggestions (optional)
5. Respond to questions
6. Re-submit for review

**Response Format:**
```markdown
## Feedback Response

### Blockers Addressed
- [Issue]: [How addressed]

### Concerns Addressed
- [Issue]: [How addressed or why not]

### Questions Answered
- [Question]: [Answer]

### Ready for Re-review
[Any notes for reviewers]
```

---

### 6. APPROVE
**Agent:** Reviewers (Architect, Security)
**Output:** Approval or request for more changes

**Approval Criteria:**
- All blockers resolved
- No new issues introduced
- Code meets quality standards
- Security requirements satisfied

**Approval Status:**
| Status | Meaning | Action |
|--------|---------|--------|
| Approved | Ready to merge | Proceed with merge |
| Approved with comments | Minor issues | Address post-merge |
| Changes requested | Issues remain | Return to Address |
| Blocked | Critical issues | Escalate to Manager |

---

## Review Timeline Expectations

| Review Type | Initial Review | Re-review |
|-------------|----------------|-----------|
| Standard | Same day | 2-4 hours |
| Large change | 1-2 days | Same day |
| Urgent/hotfix | 1-2 hours | 30 minutes |

---

## Review Log Template

```markdown
## Code Review: [PR/Change ID]

### Submission
- Author: [Agent]
- Submitted: [Timestamp]
- Type: [Feature/Bug/Refactor]

### Review Assignments
| Reviewer | Type | Status |
|----------|------|--------|
| Architect | Architecture | Pending |
| Security | Security | Pending |

### Review Rounds

#### Round 1
- Architect: [Approved/Changes Requested]
  - Blockers: [Count]
  - Concerns: [Count]
- Security: [Approved/Changes Requested]
  - Blockers: [Count]

#### Round 2 (if needed)
- [Review notes]

### Final Status
- Outcome: [Approved/Rejected]
- Approved By: [Reviewers]
- Merged: [Timestamp]
```

---

## Best Practices

### For Authors:
- Keep changes small and focused
- Write clear descriptions
- Self-review before submitting
- Respond to all feedback
- Don't take feedback personally

### For Reviewers:
- Be constructive and specific
- Explain the "why" not just the "what"
- Acknowledge good code
- Focus on important issues
- Be timely with reviews

---

## Escalation Triggers

Escalate to Manager when:
- Fundamental disagreement on approach
- Review blocked for extended time
- Security vulnerability with no clear fix
- Changes require architectural decisions
