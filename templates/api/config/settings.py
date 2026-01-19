"""
Application Configuration

Load settings from environment variables with sensible defaults.
"""

import os
from pathlib import Path

# Base directory
BASE_DIR = Path(__file__).resolve().parent.parent

# Environment
ENV = os.getenv('APP_ENV', 'development')
DEBUG = os.getenv('DEBUG', 'true').lower() == 'true'

# Server
HOST = os.getenv('HOST', 'localhost')
PORT = int(os.getenv('PORT', 8000))

# Database
DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///app.db')

# Security
SECRET_KEY = os.getenv('SECRET_KEY', 'change-me-in-production')
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', 'localhost,127.0.0.1').split(',')

# CORS
CORS_ORIGINS = os.getenv('CORS_ORIGINS', '*').split(',')

# Logging
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
