# Multi-Agent Template System

A comprehensive template and configuration framework for orchestrating AI agent teams in software development workflows. This system provides structured personas, routing logic, project templates, and operational documentation for running collaborative multi-agent development projects.

## Overview

This repository establishes a hierarchical AI agent team structure designed for:

- **Task Routing & Orchestration** - Intelligent routing of development tasks to specialized agents
- **Standardized Workflows** - Documented processes for features, bug fixes, deployments, and code reviews
- **Project Scaffolding** - Ready-to-use templates for common tech stacks
- **Audit & Logging** - Structured logging formats for traceability and compliance

```
User Request
     │
     ▼
┌─────────────┐
│   Router    │  ← Main entry point
└──────┬──────┘
       ▼
┌─────────────┐
│   Manager   │  ← Analyzes, breaks down, delegates
└──────┬──────┘
       ▼
┌─────────────────────────────────────────────────┐
│              Specialized Agents                  │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐   │
│  │Backend │ │Frontend│ │ DevOps │ │Security│...│
│  └────────┘ └────────┘ └────────┘ └────────┘   │
└─────────────────────────────────────────────────┘
```

## Directory Structure

```
├── ai-team/                    # Agent system configuration
│   ├── personas/               # 24 specialized agent definitions
│   │   ├── core/               # Manager, Architect, Backend, Frontend, DevOps, QA, Docs, Security
│   │   ├── data/               # SQL-DB, NoSQL-DB, Vector-DB, Data-Engineer
│   │   ├── documents/          # Doc-Parser, Doc-Writer, OCR, Markdown
│   │   ├── integration/        # API, Auth, Cloud, LLM integrations
│   │   └── media/              # Image, Video, Audio, 3D asset generation
│   ├── workflows/              # Standard operating procedures
│   │   ├── deployment.md       # 7-stage deployment process
│   │   ├── new-feature.md      # Feature development workflow
│   │   ├── bug-fix.md          # Bug fix process
│   │   └── code-review.md      # Code review procedures
│   ├── routing-rules.md        # Task routing logic
│   └── logging-format.md       # Audit trail specifications
│
├── templates/                  # Project starter templates
│   ├── api/                    # Python REST API template
│   ├── webapp/                 # Static web application template
│   ├── python/                 # Python package template
│   └── powershell/             # PowerShell module template
│
├── project-docs/               # Documentation templates
│   ├── PRD-template.md         # Product Requirements Document
│   ├── technical-spec-template.md
│   └── changelog-template.md
│
├── config/                     # Configuration templates
│   ├── .editorconfig           # Editor standardization
│   └── .gitignore-templates/   # Language-specific gitignores
│
├── .github/                    # GitHub integration
│   ├── workflows/              # CI/CD pipeline templates
│   ├── ISSUE_TEMPLATE/         # Bug, feature, task templates
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
│
├── .ai-logs/                   # Logging infrastructure
│   └── templates/              # Session, task, decision log templates
│
├── docs/                       # Additional documentation
│   └── github-setup/           # Git/GitHub beginner guide
│
└── infrastructure/             # Deployment infrastructure
    ├── docker/                 # Container configurations
    ├── terraform/              # Infrastructure as Code
    └── scripts/                # Deployment automation
```

## Agent Personas

### Core Agents (Always Available)
| Agent | Role | Primary Responsibilities |
|-------|------|--------------------------|
| **Manager** | Orchestrator | Task analysis, delegation, progress tracking |
| **Architect** | System Design | Architecture decisions, technical specifications |
| **Backend** | Server Development | APIs, business logic, server-side code |
| **Frontend** | UI Development | User interfaces, client-side code |
| **DevOps** | Infrastructure | CI/CD, deployment, monitoring |
| **QA** | Quality Assurance | Testing, bug diagnosis, quality gates |
| **Docs** | Documentation | Technical writing, API docs, guides |
| **Security** | Security Review | Vulnerability assessment, compliance |

### Specialized Agents (On-Demand)

**Data Specialists**
- SQL-DB, NoSQL-DB, Vector-DB, Data-Engineer

**Media Specialists**
- Image-Gen, Video-Gen, Audio-Gen, 3D-Assets

**Document Specialists**
- Doc-Parser, Doc-Writer, OCR, Markdown

**Integration Specialists**
- API-Integration, Auth-Integration, Cloud, LLM-Integration

## Project Templates

### API Template (`/templates/api/`)
Python-based REST API with:
- Flask/FastAPI-ready structure
- Controller/Route/Model separation
- Middleware support
- Test scaffolding

### Web App Template (`/templates/webapp/`)
Static web application with:
- HTML/CSS/JavaScript structure
- npm build scripts
- Development server setup

### Python Template (`/templates/python/`)
Python package with:
- src/tests layout
- setup.py configuration
- Requirements management

### PowerShell Template (`/templates/powershell/`)
PowerShell module with:
- Public/Private function separation
- Module manifest
- Pester test structure

## Workflows

### Deployment Workflow
Seven-stage deployment process:
1. **PREPARE** - Pre-deployment checks
2. **STAGING** - Deploy to staging environment
3. **VALIDATE** - Automated validation
4. **APPROVE** - Manual approval gate
5. **DEPLOY** - Production deployment
6. **MONITOR** - Post-deployment monitoring
7. **ROLLBACK** - Emergency rollback procedures

### Feature Development
1. Requirements analysis
2. Architecture design
3. Implementation
4. Code review
5. Testing
6. Documentation
7. Deployment

### Bug Fix Process
1. Reproduction
2. Diagnosis
3. Fix implementation
4. Regression testing
5. Deployment

## Getting Started

### One-Line Setup (Debian/Ubuntu)

For a fresh Debian 13 or Ubuntu system, run the interactive setup script:

```bash
./setup.sh
```

This will install all dependencies, configure Git/SSH, and set up the project.

### Prerequisites
- Git
- Docker & Docker Compose
- Your preferred language runtime (Python 3.9+, Node.js 18+, etc.)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd multi-agent-template
   ```

2. **Choose a project template**
   ```bash
   # Copy the template you need
   cp -r templates/api my-new-api
   cd my-new-api
   ```

3. **Set up environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Install dependencies**
   ```bash
   # For Python projects
   pip install -r requirements.txt

   # For Node.js projects
   npm install
   ```

5. **Run the development server**
   ```bash
   # For API template
   python src/app.py

   # For webapp template
   npm run dev
   ```

### Using with Docker

```bash
# Build the container
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Configuration

### Editor Configuration
Copy `.editorconfig` to your project root for consistent formatting across IDEs.

### Git Ignore
Choose the appropriate gitignore template from `config/.gitignore-templates/`:
```bash
cp config/.gitignore-templates/python.gitignore .gitignore
```

### CI/CD Setup
1. Copy workflows from `.github/workflows/`
2. Uncomment sections for your language/framework
3. Configure secrets in repository settings

## Task Routing

Tasks are routed based on domain and keywords:

| Domain | Keywords | Primary Agent |
|--------|----------|---------------|
| API Development | "API", "endpoint", "REST" | Backend |
| UI Development | "UI", "component", "React" | Frontend |
| Database | "schema", "query", "migration" | SQL-DB / NoSQL-DB |
| Infrastructure | "deploy", "Docker", "CI/CD" | DevOps |
| Security | "vulnerability", "auth", "encryption" | Security |
| Documentation | "README", "guide", "changelog" | Docs |

See [routing-rules.md](ai-team/routing-rules.md) for complete routing logic.

## Logging & Audit

All agent activities are logged using structured formats:

- **Session Logs** - Overall session tracking
- **Task Logs** - Individual task progress
- **Decision Logs** - Architecture and design decisions

Templates available in `.ai-logs/templates/`.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Message Format
```
<type>: <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for AI-assisted development workflows
- Designed for use with Claude and similar LLM-based coding assistants
- Inspired by modern DevOps and platform engineering practices
