# Bug Fix Workflow

## Overview

This workflow defines the process for fixing bugs using the multi-agent system. Bug fixes prioritize speed and minimal changes.

---

## Workflow Stages

```
┌─────────────┐
│   REPORT    │ Bug reported
└──────┬──────┘
       ▼
┌─────────────┐
│  REPRODUCE  │ Verify and reproduce bug
└──────┬──────┘
       ▼
┌─────────────┐
│  DIAGNOSE   │ Identify root cause
└──────┬──────┘
       ▼
┌─────────────┐
│    FIX      │ Implement fix
└──────┬──────┘
       ▼
┌─────────────┐
│   VERIFY    │ Test fix and regression
└──────┬──────┘
       ▼
┌─────────────┐
│   DEPLOY    │ Deploy fix (if urgent)
└─────────────┘
```

---

## Severity Classification

| Severity | Description | Response Time | Process |
|----------|-------------|---------------|---------|
| Critical | System down, data loss | Immediate | Hotfix |
| High | Major feature broken | Same day | Priority fix |
| Medium | Feature degraded | Next sprint | Standard fix |
| Low | Minor inconvenience | Backlog | When convenient |

---

## Stage Details

### 1. REPORT
**Input:** Bug report from user or monitoring
**Output:** Documented bug with severity

**Manager Actions:**
- Log bug report
- Assign severity level
- Gather initial information
- Create bug tracking entry

**Required Information:**
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Screenshots/logs (if available)

---

### 2. REPRODUCE
**Agents:** QA (Primary), Backend/Frontend (Supporting)
**Output:** Confirmed reproduction steps

**QA Actions:**
1. Attempt to reproduce bug
2. Document exact steps
3. Identify affected areas
4. Confirm severity assessment

**Outcomes:**
- Reproduced → Continue to Diagnose
- Cannot Reproduce → Request more information
- Intermittent → Note conditions, continue investigating

---

### 3. DIAGNOSE
**Agents:** Backend/Frontend (Based on bug type), Architect (if complex)
**Output:** Root cause identification

**Developer Actions:**
1. Review reproduction steps
2. Examine relevant code
3. Check logs and error messages
4. Identify root cause
5. Document findings

**For Complex Bugs:**
- Architect may assist with diagnosis
- May require multiple agents to investigate

---

### 4. FIX
**Agents:** Backend/Frontend (Based on bug type)
**Output:** Fix implementation

**Fix Principles:**
- Minimal change to fix the issue
- No scope creep (don't refactor)
- Address root cause, not symptoms
- Add regression test

**Developer Actions:**
1. Implement fix
2. Write regression test
3. Self-test the fix
4. Submit for review

---

### 5. VERIFY
**Agents:** QA, Security (if security-related)
**Output:** Verification report

**QA Actions:**
1. Verify fix resolves the bug
2. Run regression tests
3. Check for side effects
4. Test edge cases

**Security Actions (if applicable):**
- Verify security fix is complete
- Check for related vulnerabilities
- Confirm no new vulnerabilities introduced

---

### 6. DEPLOY
**Agents:** DevOps
**Output:** Deployed fix

**Standard Process:**
1. Merge to main branch
2. Deploy to staging
3. Smoke test
4. Deploy to production
5. Monitor

**Hotfix Process (Critical bugs):**
1. Create hotfix branch
2. Implement and test
3. Deploy directly to production
4. Backport to main branch
5. Close monitoring

---

## Parallel Execution

### Bug Fix (Mostly Sequential)

Bug fixes are primarily sequential due to dependencies:
1. Must reproduce before diagnosing
2. Must diagnose before fixing
3. Must fix before verifying

### Can Parallelize:
- Writing regression test while implementing fix
- Documentation update while deploying

---

## Bug Report Template

```markdown
## Bug Report

### Summary
[One-line description]

### Severity
- [ ] Critical
- [ ] High
- [ ] Medium
- [ ] Low

### Environment
- Version: [App version]
- Browser/OS: [Details]
- Environment: [dev/staging/prod]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Logs/Screenshots
[Attach if available]

### Additional Context
[Any other information]
```

---

## Bug Fix Log Template

```markdown
## Bug Fix: [Bug ID] - [Summary]

### Bug Details
- Severity: [Level]
- Reported: [Timestamp]
- Reporter: [User/System]

### Reproduction
- Status: [Reproduced/Cannot Reproduce]
- Steps: [Confirmed steps]
- Environment: [Where reproduced]

### Diagnosis
- Root Cause: [Description]
- Affected Code: [Files/functions]
- Related Issues: [If any]

### Fix
- Agent: [Who fixed]
- Changes: [Brief description]
- Files Modified: [List]
- Regression Test: [Added Y/N]

### Verification
- QA Status: [Passed/Failed]
- Regression: [Passed/Failed]
- Security Review: [N/A/Passed]

### Deployment
- Deployed: [Timestamp]
- Method: [Standard/Hotfix]
- Verified in Production: [Y/N]

### Resolution
- Status: [Resolved]
- Time to Fix: [Duration]
- Notes: [Any lessons learned]
```

---

## Escalation Triggers

Escalate when:
- Cannot reproduce the bug
- Root cause unclear after investigation
- Fix requires architectural changes
- Security vulnerability discovered
- Fix would cause breaking changes
- Critical bug with no clear solution

---

## Quality Gates

| Gate | Criteria |
|------|----------|
| Reproduction | Bug confirmed reproducible |
| Root Cause | Clear understanding of cause |
| Fix Review | Code reviewed, minimal changes |
| Verification | Bug fixed, no regression |
| Security | No security issues (if applicable) |

---

## Hotfix Criteria

Use hotfix process when:
- Critical severity (system down)
- High severity with significant user impact
- Security vulnerability being exploited
- Data corruption occurring

Hotfix differs from standard:
- Bypasses normal code review (expedited review)
- Deploys directly to production
- Requires immediate backport to main
- Post-mortem required
