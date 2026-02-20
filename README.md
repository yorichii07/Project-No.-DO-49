# Group 10D12 DO-48: Hospitality Management Application
## Division
D12
## Group
Group 10D12
## Project Number
DO-48
## Problem Statement
CI/CD for Vue.js Technology App

## Description	
Design and implement a professional CI/CD pipeline for a a Vue.js Technology application using GitHub Actions or Jenkins. The workflow automates the entire software delivery lifecycle, including
automated unit testing upon every commit and containerized artifact creation upon merging to the production branch. This setup ensures high code quality and rapid, reliable deployment cycles for the enterprise environment.
Tools	Git, Docker, Jenkins/Actions, K8s

# Task Atlas

A clean, focused task manager built with Flask, SQLAlchemy, and Flask-Login.

Task Atlas is a lightweight, multi-user to-do app with a modern glassy UI. Each user gets a private task list with simple actions to add, complete, and delete tasks.

## Features
- User registration and login
- Personal task list per user
- Task completion toggles and deletion
- Modern glassy UI
- Simple SQLite persistence
- Minimal dependencies and fast setup

## Tech Stack
- Python 3.12
- Flask
- Flask-Login
- Flask-SQLAlchemy
- SQLite (local database)

## Setup
```bash
python -m venv .venv
```

Activate the virtual environment:

Windows (PowerShell):
```bash
.\.venv\Scripts\Activate.ps1
```

Install dependencies:
```bash
python -m pip install -r requirements.txt
```

## Run
```bash
python app.py
```

The app starts a development server at http://127.0.0.1:5000 by default.

## Project Structure
- [app.py](app.py) - Flask app, routes, models, auth
- [templates/](templates) - Jinja2 templates for auth and dashboard
- [static/style.css](static/style.css) - UI styling
- [requirements.txt](requirements.txt) - Python dependencies

## Routes
- `/` - Dashboard (login required)
- `/login` - Login screen
- `/register` - Create account
- `/logout` - End session
- `/add` - Add a task (POST)
- `/complete/<id>` - Toggle completion
- `/delete/<id>` - Delete task

## Data Model
Two tables are created automatically on first run:
- `User` with `id`, `username`, `password`
- `Task` with `id`, `content`, `completed`, `user_id`

## Configuration
Default configuration is defined in [app.py](app.py):
- `SECRET_KEY` for session security
- `SQLALCHEMY_DATABASE_URI` for SQLite storage

For production, set a strong `SECRET_KEY` and use a production WSGI server.

## UI Preview
Add screenshots here when ready:
- `docs/screenshots/login.png`
- `docs/screenshots/dashboard.png`

## Troubleshooting
- If you see a database error, delete `database.db` and restart the app.
- If dependencies fail, recreate the venv and reinstall requirements.
- If the UI looks stale, hard-refresh the browser to clear cached CSS.

## Notes
- The SQLite database file is created automatically on first run.
- This app uses Flask's debug server for development only.

## CI/CD Pipeline Added

This project now includes a complete CI/CD pipeline using:
- Jenkins
- Docker
- Pytest
- Flask

## Group Members
 - Suzal Devani
 - Aryan Gangrade
 - Ayushi Jat
 - Naina Sahu
 - Aditi Singh
 - Preeti Prajapat

