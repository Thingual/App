# Thingual Backend

FastAPI backend for Thingual authentication.

## Setup

1. Create a virtual environment:

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Set up PostgreSQL database and update `.env` file with your credentials.

4. Run the application:

```bash
uvicorn app.main:app --reload
```

## API Endpoints

- `POST /auth/signup` - Create new user account
- `POST /auth/login` - Login with email/password
- `POST /auth/google` - Login with Google ID token

## Environment Variables

Create a `.env` file with the following variables:

```
DATABASE_URL=postgresql://user:password@localhost:5432/thingual
SECRET_KEY=your-secret-key-here
GOOGLE_CLIENT_ID=your-google-client-id
```
