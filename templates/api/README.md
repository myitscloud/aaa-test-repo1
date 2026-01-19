# API Project Template

Minimal starter template for REST API projects.

## Structure

```
project-name/
├── src/
│   ├── routes/           # API route handlers
│   ├── controllers/      # Business logic
│   ├── models/           # Data models
│   ├── middleware/       # Request middleware
│   ├── utils/            # Utility functions
│   └── app.py            # Application entry point
├── tests/
│   └── test_api.py
├── config/
│   └── settings.py
├── requirements.txt
├── .gitignore
├── .env.example
└── README.md
```

## Quick Start

```bash
# Clone and rename
cp -r templates/api my-project
cd my-project

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set up environment
cp .env.example .env

# Run development server
python src/app.py
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/api/v1/items` | List items |
| GET | `/api/v1/items/{id}` | Get item by ID |
| POST | `/api/v1/items` | Create item |
| PUT | `/api/v1/items/{id}` | Update item |
| DELETE | `/api/v1/items/{id}` | Delete item |

## Files Included

- `src/routes/` - API endpoint definitions
- `src/controllers/` - Request handling logic
- `src/models/` - Data structures and validation
- `src/middleware/` - Auth, logging, error handling
- `config/` - Application configuration

## Framework Options

This template structure works with:
- Flask
- FastAPI
- Django REST Framework
- Express.js (Node.js)
