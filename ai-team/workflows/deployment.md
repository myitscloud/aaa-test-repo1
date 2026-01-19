# Deployment Workflow

## Overview

This workflow defines the process for deploying code to production using the multi-agent system.

---

## Workflow Stages

```
┌─────────────┐
│   PREPARE   │ Prepare deployment
└──────┬──────┘
       ▼
┌─────────────┐
│   STAGING   │ Deploy to staging
└──────┬──────┘
       ▼
┌─────────────┐
│  VALIDATE   │ Test in staging
└──────┬──────┘
       ▼
┌─────────────┐
│   APPROVE   │ Get deployment approval
└──────┬──────┘
       ▼
┌─────────────┐
│   DEPLOY    │ Deploy to production
└──────┬──────┘
       ▼
┌─────────────┐
│   MONITOR   │ Post-deploy monitoring
└──────┬──────┘
       ▼
┌─────────────┐
│  ROLLBACK?  │ Rollback if needed
└─────────────┘
```

---

## Deployment Types

| Type | Description | Process | Approval |
|------|-------------|---------|----------|
| Standard | Normal release | Full process | Manager |
| Hotfix | Critical fix | Expedited | Manager + Security |
| Rollback | Revert deployment | Immediate | DevOps |
| Scheduled | Planned release | Full + window | Manager |

---

## Stage Details

### 1. PREPARE
**Agents:** DevOps, Backend/Frontend
**Output:** Deployment-ready artifacts

**DevOps Actions:**
1. Verify all tests pass
2. Build deployment artifacts
3. Update deployment configuration
4. Prepare database migrations (if any)
5. Update environment variables
6. Create deployment checklist

**Pre-Deployment Checklist:**
```markdown
## Deployment Checklist

### Code
- [ ] All tests passing
- [ ] Code review approved
- [ ] Security review approved
- [ ] No critical vulnerabilities

### Configuration
- [ ] Environment variables updated
- [ ] Feature flags configured
- [ ] Secrets rotated (if needed)

### Database
- [ ] Migrations tested
- [ ] Rollback migration ready
- [ ] Backup verified

### Dependencies
- [ ] No breaking changes in dependencies
- [ ] API contracts verified

### Documentation
- [ ] Changelog updated
- [ ] Release notes prepared
- [ ] Runbook updated
```

---

### 2. STAGING
**Agents:** DevOps
**Output:** Staging deployment

**Deployment Steps:**
1. Deploy to staging environment
2. Run database migrations
3. Verify deployment succeeded
4. Run smoke tests

**Staging Verification:**
```markdown
## Staging Deployment

### Deployment Info
- Version: [Version]
- Timestamp: [Time]
- Deployed By: DevOps Agent

### Verification
- [ ] Application starts successfully
- [ ] Health endpoints responding
- [ ] Database migrations complete
- [ ] External services connected
- [ ] Smoke tests pass
```

---

### 3. VALIDATE
**Agents:** QA
**Output:** Staging validation report

**QA Actions:**
1. Execute test suite in staging
2. Perform exploratory testing
3. Validate new features
4. Check for regressions
5. Performance spot-check

**Validation Report:**
```markdown
## Staging Validation Report

### Test Results
| Suite | Passed | Failed | Skipped |
|-------|--------|--------|---------|
| Unit | 150 | 0 | 2 |
| Integration | 45 | 0 | 0 |
| E2E | 20 | 0 | 1 |

### New Features Validated
- [ ] Feature 1: [Status]
- [ ] Feature 2: [Status]

### Issues Found
- [None / List issues]

### Recommendation
- [ ] Ready for production
- [ ] Needs fixes before production
```

---

### 4. APPROVE
**Agent:** Manager
**Output:** Deployment approval

**Approval Criteria:**
- All tests passing
- QA validation complete
- No blocking issues
- Stakeholder notification sent
- Rollback plan verified

**Approval Record:**
```markdown
## Deployment Approval

### Version: [Version]
### Approver: Manager Agent
### Timestamp: [Time]

### Checklist Verified
- [x] Tests passing
- [x] QA approved
- [x] Security approved
- [x] Rollback plan ready
- [x] Stakeholders notified

### Approval: GRANTED

### Notes
[Any deployment notes or restrictions]
```

---

### 5. DEPLOY
**Agents:** DevOps
**Output:** Production deployment

**Deployment Strategy Options:**

#### Blue-Green
```
1. Deploy to inactive environment (Green)
2. Run health checks
3. Switch traffic to Green
4. Keep Blue as rollback
5. Decommission Blue after verification
```

#### Canary
```
1. Deploy to canary instances (5%)
2. Monitor for errors
3. Gradually increase (25%, 50%, 100%)
4. Rollback at any stage if issues
```

#### Rolling
```
1. Update instances incrementally
2. One instance at a time
3. Health check each instance
4. Continue until complete
```

**Production Deployment Log:**
```markdown
## Production Deployment

### Deployment Info
- Version: [Version]
- Strategy: [Blue-Green/Canary/Rolling]
- Start Time: [Timestamp]
- End Time: [Timestamp]

### Steps Completed
- [x] Backup created
- [x] Traffic drained (if applicable)
- [x] Deployment initiated
- [x] Database migrations run
- [x] Health checks passed
- [x] Traffic restored

### Verification
- [ ] Application responding
- [ ] No error spikes
- [ ] Performance normal
- [ ] Monitoring active
```

---

### 6. MONITOR
**Agents:** DevOps, Manager
**Output:** Post-deployment monitoring

**Monitoring Period:** First 30-60 minutes critical

**Metrics to Watch:**
| Metric | Threshold | Action if Exceeded |
|--------|-----------|-------------------|
| Error rate | > 1% | Investigate |
| Error rate | > 5% | Prepare rollback |
| Latency p99 | > 2x normal | Investigate |
| CPU/Memory | > 80% | Scale/Investigate |

**Monitoring Checkpoints:**
- [ ] 5 minutes: Initial health check
- [ ] 15 minutes: Error rate check
- [ ] 30 minutes: Performance check
- [ ] 60 minutes: All systems normal

---

### 7. ROLLBACK (If Needed)
**Agents:** DevOps
**Output:** Reverted deployment

**Rollback Triggers:**
- Error rate exceeds threshold
- Critical functionality broken
- Security vulnerability discovered
- Performance degradation severe

**Rollback Process:**
```markdown
## Rollback Procedure

### Immediate Actions
1. Initiate rollback to previous version
2. Revert database migrations (if safe)
3. Clear caches
4. Verify rollback successful

### Post-Rollback
1. Notify stakeholders
2. Investigate root cause
3. Document incident
4. Plan fix

### Rollback Log
- Initiated: [Timestamp]
- Reason: [Description]
- Completed: [Timestamp]
- Previous Version: [Version]
```

---

## Deployment Schedule

### Recommended Windows
| Day | Window | Type |
|-----|--------|------|
| Tuesday | 10am-12pm | Standard |
| Wednesday | 10am-12pm | Standard |
| Thursday | 10am-12pm | Standard |

### Avoid
- Fridays (limited support)
- Holidays
- Major events
- End of month (if business-critical)

---

## Communication Template

### Pre-Deployment
```
Subject: [Scheduled] Deployment v[Version] - [Date] [Time]

Deployment of v[Version] is scheduled for [Date] at [Time].

Changes included:
- [Change 1]
- [Change 2]

Expected duration: [Time]
Impact: [None/Minimal/Downtime expected]

Contact: [Who to contact]
```

### Post-Deployment
```
Subject: [Complete] Deployment v[Version]

Deployment of v[Version] completed successfully at [Time].

Status: All systems operational
Changes deployed:
- [Change 1]
- [Change 2]

Any issues: Contact [Who]
```

---

## Deployment Log Template

```markdown
## Deployment Record

### Summary
- Version: [Version]
- Date: [Date]
- Type: [Standard/Hotfix/Rollback]
- Duration: [Start to End]

### Team
- Deployer: DevOps Agent
- Approver: Manager Agent
- QA: QA Agent

### Changes
- [List of changes]

### Timeline
| Time | Event |
|------|-------|
| [Time] | Deployment started |
| [Time] | Staging deployed |
| [Time] | QA validation complete |
| [Time] | Production deployed |
| [Time] | Monitoring complete |

### Issues
- [None / Issues encountered]

### Metrics
- Error rate: [%]
- Latency change: [+/- %]

### Status: SUCCESS / ROLLBACK
```

---

## Escalation

Escalate when:
- Deployment fails repeatedly
- Unexpected errors in production
- Performance degradation
- Security incident
- Unable to rollback
