#!/usr/bin/env python
"""
Thingual Backend Verification Script
Checks if all components are properly configured before starting the server
"""
import sys
import os
from pathlib import Path

def print_header(text):
    """Print formatted header"""
    print("\n" + "=" * 80)
    print(f"  {text}")
    print("=" * 80)

def check_python_version():
    """Check Python version"""
    print("\n📌 Checking Python version...")
    version = sys.version_info
    if version.major >= 3 and version.minor >= 10:
        print(f"✅ Python {version.major}.{version.minor}.{version.micro} - OK")
        return True
    else:
        print(f"❌ Python 3.10+ required, found {version.major}.{version.minor}")
        return False

def check_dependencies():
    """Check if all required packages are installed"""
    print("\n📌 Checking dependencies...")
    required_packages = [
        'fastapi',
        'hypercorn',
        'sqlalchemy',
        'psycopg2',
        'bcrypt',
        'pydantic',
        'python-jose',
    ]
    
    missing = []
    for package in required_packages:
        try:
            __import__(package)
            print(f"✅ {package}")
        except ImportError:
            print(f"❌ {package} - MISSING")
            missing.append(package)
    
    if missing:
        print(f"\n⚠️  Missing packages: {', '.join(missing)}")
        print("Run: pip install -r requirements.txt")
        return False
    return True

def check_database_config():
    """Check database configuration"""
    print("\n📌 Checking database configuration...")
    
    db_url = os.getenv('DATABASE_URL')
    if not db_url:
        print("❌ DATABASE_URL not set in environment")
        print("   Create .env file with DATABASE_URL")
        return False
    
    if 'neon' in db_url.lower():
        print("✅ NeonDB PostgreSQL URL configured")
    else:
        print("⚠️  Non-Neon database URL detected")
    
    print(f"✅ Database URL length: {len(db_url)} chars")
    return True

def check_jwt_config():
    """Check JWT configuration"""
    print("\n📌 Checking JWT configuration...")
    
    secret_key = os.getenv('SECRET_KEY')
    if not secret_key:
        print("⚠️  SECRET_KEY not set - using default")
        print("   WARNING: Use unique SECRET_KEY in production!")
        return True
    
    if len(secret_key) < 32:
        print("⚠️  SECRET_KEY too short (< 32 chars)")
        print("   Use: python -c \"import secrets; print(secrets.token_urlsafe(32))\"")
    else:
        print("✅ SECRET_KEY configured (>=32 chars)")
    
    return True

def check_file_structure():
    """Check if all required files exist"""
    print("\n📌 Checking file structure...")
    
    required_files = [
        'app/__init__.py',
        'app/main.py',
        'app/config.py',
        'app/database.py',
        'app/models/user.py',
        'app/schemas/auth_schema.py',
        'app/services/auth_service.py',
        'app/routers/auth.py',
        'requirements.txt',
        'start_hypercorn.py',
    ]
    
    missing = []
    for file in required_files:
        if Path(file).exists():
            print(f"✅ {file}")
        else:
            print(f"❌ {file} - MISSING")
            missing.append(file)
    
    if missing:
        print(f"\n⚠️  Missing files: {', '.join(missing)}")
        return False
    return True

def test_database_connection():
    """Test database connection"""
    print("\n📌 Testing database connection...")
    
    try:
        from app.database import engine
        from sqlalchemy import text
        
        with engine.connect() as connection:
            result = connection.execute(text("SELECT version();"))
            version = result.scalar()
            print("✅ Database connection successful")
            print(f"   PostgreSQL version: {version[:20]}...")
            return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        print("   Check DATABASE_URL and internet connection")
        return False

def main():
    """Run all checks"""
    print_header("Thingual Backend Verification")
    
    checks = [
        ("Python Version", check_python_version),
        ("Dependencies", check_dependencies),
        ("Database Config", check_database_config),
        ("JWT Config", check_jwt_config),
        ("File Structure", check_file_structure),
        ("Database Connection", test_database_connection),
    ]
    
    results = []
    for name, check_func in checks:
        try:
            result = check_func()
            results.append((name, result))
        except Exception as e:
            print(f"\n❌ {name} check failed: {e}")
            results.append((name, False))
    
    # Summary
    print_header("Verification Summary")
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status:8} - {name}")
    
    print(f"\nResult: {passed}/{total} checks passed")
    
    if passed == total:
        print("\n🚀 All checks passed! You can start the server with:")
        print("   python start_hypercorn.py")
        print("   OR")
        print("   start_server.bat")
        print("   OR")
        print("   powershell -ExecutionPolicy Bypass -File start_server.ps1")
        sys.exit(0)
    else:
        print("\n⚠️  Some checks failed. Please fix the issues above.")
        sys.exit(1)

if __name__ == "__main__":
    main()
