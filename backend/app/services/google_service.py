import httpx
from typing import Optional
from google.oauth2 import id_token
from google.auth.transport import requests
from ..config import get_settings

settings = get_settings()

# Android client ID for verification (audience in token from Android app)
ANDROID_CLIENT_ID = "309791423651-9b2mv3h7q23lgc4e98c63vciqdaemq2h.apps.googleusercontent.com"


async def verify_google_token(token: str) -> Optional[dict]:
    """
    Verify Google ID token and return user info.
    
    Returns dict with 'email', 'name', 'picture', 'sub' (Google user ID) if valid.
    Returns None if token is invalid.
    """
    try:
        # Try verifying with Web Client ID first (serverClientId)
        idinfo = None
        for client_id in [settings.google_client_id, ANDROID_CLIENT_ID]:
            try:
                idinfo = id_token.verify_oauth2_token(
                    token,
                    requests.Request(),
                    client_id
                )
                break  # Successfully verified
            except ValueError:
                continue  # Try next client ID
        
        if idinfo is None:
            # Fall back to API verification
            return await verify_google_token_with_api(token)
        
        # Verify the issuer
        if idinfo['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
            return None
        
        return {
            'email': idinfo.get('email'),
            'name': idinfo.get('name'),
            'picture': idinfo.get('picture'),
            'google_id': idinfo.get('sub'),
            'email_verified': idinfo.get('email_verified', False)
        }
    except ValueError:
        # Invalid token - try API method
        return await verify_google_token_with_api(token)
    except Exception:
        # Any other error - try API method
        return await verify_google_token_with_api(token)


async def verify_google_token_with_api(token: str) -> Optional[dict]:
    """
    Alternative method: Verify Google token using Google's tokeninfo API.
    Use this if you don't want to use the google-auth library.
    """
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"https://oauth2.googleapis.com/tokeninfo?id_token={token}"
            )
            
            if response.status_code != 200:
                return None
            
            data = response.json()
            
            # Verify the audience matches one of our client IDs
            valid_client_ids = [settings.google_client_id, ANDROID_CLIENT_ID]
            if data.get('aud') not in valid_client_ids:
                return None
            
            return {
                'email': data.get('email'),
                'name': data.get('name'),
                'picture': data.get('picture'),
                'google_id': data.get('sub'),
                'email_verified': data.get('email_verified') == 'true'
            }
    except Exception:
        return None
