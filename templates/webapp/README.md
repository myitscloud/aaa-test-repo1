# Web Application Template

Minimal starter template for web application projects.

## Structure

```
project-name/
├── public/
│   ├── index.html
│   ├── css/
│   │   └── styles.css
│   ├── js/
│   │   └── app.js
│   └── assets/
│       └── images/
├── src/                  # Source files (if using build tools)
├── tests/
├── .gitignore
├── .env.example
├── package.json
└── README.md
```

## Quick Start

```bash
# Clone and rename
cp -r templates/webapp my-project
cd my-project

# Install dependencies (if using npm)
npm install

# Start development server
npm run dev

# Or simply open public/index.html in browser
```

## Files Included

- `public/` - Static files served directly
- `public/index.html` - Main HTML entry point
- `public/css/` - Stylesheets
- `public/js/` - JavaScript files
- `public/assets/` - Images, fonts, etc.
- `src/` - Source files for build process
- `package.json` - Node.js dependencies and scripts

## Development Options

This template can be used with:
- Vanilla HTML/CSS/JS (no build required)
- Vite, Webpack, or other bundlers
- React, Vue, Svelte (add framework dependencies)
