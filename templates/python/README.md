# Python Project Template

Minimal starter template for Python projects.

## Structure

```
project-name/
├── src/
│   └── __init__.py
├── tests/
│   └── __init__.py
├── requirements.txt
├── requirements-dev.txt
├── setup.py
├── .gitignore
├── .env.example
└── README.md
```

## Quick Start

```bash
# Clone and rename
cp -r templates/python my-project
cd my-project

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# or: venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt  # For development

# Run tests
pytest
```

## Files Included

- `src/` - Main source code directory
- `tests/` - Test files
- `requirements.txt` - Production dependencies
- `requirements-dev.txt` - Development dependencies (pytest, linting, etc.)
- `setup.py` - Package configuration
- `.gitignore` - Python-specific ignores
- `.env.example` - Environment variable template
