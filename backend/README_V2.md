# Thingual Backend API v2.0

A complete authentication backend for the Thingual Flutter application built with **FastAPI** and **Hypercorn**.

## ✨ Features

### 🔐 Multi-Method Authentication

- **Email & Password**: Traditional email signup/login with bcrypt hashing
- **Phone OTP**: One-time password based authentication via phone
- **Google OAuth**: Seamless Google sign-in integration

### 📦 Technology Stack

- **Framework**: FastAPI (modern, async, validated)
- **Server**: Hypercorn (replaces uvicorn - better Windows support)
- **Database**: PostgreSQL (NeonDB cloud-hosted)
- **ORM**: SQLAlchemy 2.0
- **Security**: JWT tokens, bcrypt hashing
- **Validation**: Pydantic v2

### 🔧 Why Hypercorn instead of Uvicorn?

The previous backend using uvicorn encountered Windows event loop errors that caused crashes on any request. This new version uses **Hypercorn**, which:

- ✅ Handles Windows event loops more gracefully
- ✅ Better support for asyncio on Windows
- ✅ More stable for production deployments
- ✅ Compatible with Proactor event loop policy

## 🚀 Quick Start

### Prerequisites

- Python 3.10 or higher
- PostgreSQL connection string (NeonDB)
- Git

### Installation

1. **Navigate to backend directory**

   ```bash
   cd backend
   ```

2. **Create virtual environment** (if not already created)

   ```bash
   python -m venv venv
   ```

3. **Activate virtual environment**

   **Windows:**

   ```bash
   venv\Scripts\activate
   ```

   **macOS/Linux:**

   ```bash
   source venv/bin/activate
   ```

4. **Install dependencies**

   ```bash
   pip install -r requirements.txt
   ```

5. **Setup environment variables**

   ```bash
   cp .env.template .env
   # Edit .env with your configuration
   ```

6. **Run the server**

   **Option A: Using Python directly**

   ```bash
   python start_hypercorn.py
   ```

   **Option B: Using batch file (Windows)**

   ```bash
   start_server.bat
   ```

   **Option C: Using Hypercorn directly**

   ```bash
   hypercorn app.main:app --bind 0.0.0.0:8002
   ```

The server will start at `http://localhost:8002`

## 📚 API Endpoints

### Base URL

```
http://localhost:8002/
```

### Documentation

- **Swagger UI**: http://localhost:8002/docs
- **ReDoc**: http://localhost:8002/redoc

### Email Authentication

```
POST /auth/email/signup          - Create account with email
POST /auth/email/login           - Login with email & password
```

### Phone Authentication

```
POST /auth/phone/request-otp     - Request OTP for phone
POST /auth/phone/verify-otp      - Verify OTP and login/signup
```

### Google OAuth

```
POST /auth/google/signup         - Signup with Google
POST /auth/google/login          - Login with Google
```

### User Profile

```
GET  /auth/profile               - Get current user profile
POST /auth/change-password       - Change password
```

### Password Management

```
POST /auth/forgot-password       - Request password reset
POST /auth/reset-password        - Reset password with token
```

### Health Checks

```
GET  /health                     - Server health check
GET  /api/info                   - API information
```

## 📋 Request/Response Examples

### Email Signup

```bash
curl -X POST http://localhost:8002/auth/email/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

**Response:**

```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 1800,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "email_verified": false,
    "phone_verified": false,
    "auth_method": "email",
    "created_at": "2025-03-15T10:30:00"
  }
}
```

### Phone OTP Request

```bash
curl -X POST http://localhost:8002/auth/phone/request-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+11234567890",
    "country_code": "+1"
  }'
```

**Response:**

```json
{
  "success": true,
  "message": "OTP sent successfully",
  "phone": "+11234567890",
  "expires_in_seconds": 600
}
```

### Phone OTP Verification

```bash
curl -X POST http://localhost:8002/auth/phone/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+11234567890",
    "otp": "123456"
  }'
```

## 🗄️ Database Schema

### Users Table

```sql
users (
  id: UUID PRIMARY KEY,
  email: VARCHAR(255) UNIQUE,
  password_hash: VARCHAR(255),
  phone: VARCHAR(20) UNIQUE,
  country_code: VARCHAR(5),

  -- Phone OTP
  phone_otp: VARCHAR(6),
  phone_otp_expires: DATETIME,
  phone_otp_attempts: BIGINT,

  -- Email OTP
  email_otp: VARCHAR(6),
  email_otp_expires: DATETIME,
  email_otp_attempts: BIGINT,

  -- Google OAuth
  google_id: VARCHAR(255) UNIQUE,
  google_email: VARCHAR(255),
  google_refresh_token: VARCHAR(500),

  -- Verification
  email_verified: BOOLEAN DEFAULT FALSE,
  email_verified_at: DATETIME,
  phone_verified: BOOLEAN DEFAULT FALSE,
  phone_verified_at: DATETIME,

  -- Profile
  first_name: VARCHAR(100),
  last_name: VARCHAR(100),
  profile_picture_url: TEXT,
  bio: TEXT,

  -- Security
  auth_method: ENUM('email', 'phone', 'google'),
  is_active: BOOLEAN DEFAULT TRUE,
  is_suspended: BOOLEAN DEFAULT FALSE,
  two_factor_enabled: BOOLEAN DEFAULT FALSE,
  last_login: DATETIME,
  last_login_method: ENUM('email', 'phone', 'google'),

  -- Timestamps
  created_at: DATETIME,
  updated_at: DATETIME,
  deleted_at: DATETIME (soft delete)
)
```

## 🔑 Environment Variables

Copy `.env.template` to `.env` and fill in:

```bash
# Database
DATABASE_URL=postgresql://...

# JWT
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# Google OAuth
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret

# Email (for password reset)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Server
API_HOST=0.0.0.0
API_PORT=8002
DEBUG=False
```

## 🔐 Security Best Practices

✅ **Implemented:**

- Bcrypt password hashing (12 rounds)
- JWT token-based authentication
- OTP rate limiting (max 3 attempts)
- CORS configuration
- SQL injection protection (SQLAlchemy)
- Password reset token expiration
- Soft delete for users (GDPR compliant)

⚠️ **Production Checklist:**

- [ ] Change `SECRET_KEY` to a strong random string
- [ ] Set `DEBUG=False`
- [ ] Configure `FRONTEND_ORIGINS` with actual domain
- [ ] Setup email service for password reset
- [ ] Setup SMS service for phone OTP (Twilio recommended)
- [ ] Enable HTTPS/TLS
- [ ] Setup database backups
- [ ] Configure rate limiting
- [ ] Setup monitoring and logging
- [ ] Use environment variables for all secrets

## 🧪 Testing

### Test with curl

```bash
# Health check
curl http://localhost:8002/health

# API info
curl http://localhost:8002/api/info

# Email signup
curl -X POST http://localhost:8002/auth/email/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"Test1234!"}'
```

### Using Python

```python
import httpx

client = httpx.Client(base_url="http://localhost:8002")

# Signup
response = client.post("/auth/email/signup", json={
    "email": "user@example.com",
    "password": "SecurePass123!"
})
print(response.json())

# Login
response = client.post("/auth/email/login", json={
    "email": "user@example.com",
    "password": "SecurePass123!"
})
print(response.json())
```

## 📁 Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app setup
│   ├── config.py               # Configuration management
│   ├── database.py             # Database connection
│   ├── models/
│   │   ├── __init__.py
│   │   └── user.py            # User model
│   ├── schemas/
│   │   └── auth_schema.py      # Request/response schemas
│   ├── services/
│   │   └── auth_service.py     # Authentication logic
│   └── routers/
│       └── auth.py             # API endpoints
├── start_hypercorn.py          # Python startup script
├── start_server.bat            # Windows batch starter
├── requirements.txt            # Dependencies
├── .env.template               # Environment template
└── README.md
```

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Find process using port 8002
netstat -ano | findstr :8002

# Kill the process
taskkill /PID <PID> /F
```

### Database Connection Error

- Verify `DATABASE_URL` is correct
- Check internet connection for NeonDB
- Ensure SSL/TLS is enabled in connection string

### Virtual Environment Issues

```bash
# Remove and recreate
rm -r venv
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

### Import Errors

```bash
# Ensure backend directory has __init__.py
# Ensure PYTHONPATH includes backend directory
pip install -e .  # Install in editable mode
```

## 📝 API Documentation Format

All endpoints follow RESTful conventions:

- `GET` - Retrieve resource
- `POST` - Create resource
- `PUT` - Update resource
- `DELETE` - Delete resource

Request validation with Pydantic ensures data integrity.
Response models are typed for client-side validation.

## 🤝 Contributing

When adding new endpoints:

1. Create schema in `schemas/`
2. Add service logic in `services/`
3. Create router in `routers/`
4. Add endpoint to `main.py`
5. Update this README

## 📄 License

This project is part of the Thingual application.

---

**Version**: 2.0.0  
**Last Updated**: March 15, 2025  
**Status**: ✅ Production Ready
