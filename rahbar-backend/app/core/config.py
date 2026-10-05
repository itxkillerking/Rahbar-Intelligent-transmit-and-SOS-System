from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import field_validator

class Settings(BaseSettings):
    APP_NAME: str = "The Rahbar Backend"
    APP_ENV: str = "development"
    APP_DEBUG: bool = True
    API_V1_PREFIX: str = "/api/v1"
    DATABASE_URL: str
    DATABASE_DIRECT_URL: str | None = None
    REDIS_URL: str
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    OTP_EXPIRE_SECONDS: int = 300
    OTP_RESEND_COOLDOWN_SECONDS: int = 60
    OTP_MAX_ATTEMPTS: int = 5
    OTP_HMAC_SECRET: str
    SMS_PROVIDER: str = "none"
    
    @field_validator("DATABASE_URL", "DATABASE_DIRECT_URL", mode="before")
    @classmethod
    def convert_postgres_url(cls, v: str | None) -> str | None:
        if isinstance(v, str):
            if v.startswith("postgres://"):
                v = v.replace("postgres://", "postgresql+asyncpg://", 1)
            elif v.startswith("postgresql://") and not v.startswith("postgresql+asyncpg://"):
                v = v.replace("postgresql://", "postgresql+asyncpg://", 1)

            import urllib.parse
            parsed = urllib.parse.urlparse(v)
            query = urllib.parse.parse_qs(parsed.query)
            
            # Convert sslmode to ssl, and remove incompatible asyncpg kwargs
            has_sslmode = query.pop("sslmode", None)
            query.pop("options", None)
            query.pop("endpoint", None)
            query.pop("channel_binding", None)
            
            if has_sslmode and has_sslmode[0] == "require":
                query["ssl"] = ["require"]
                
            new_query = urllib.parse.urlencode(query, doseq=True)
            v = urllib.parse.urlunparse(parsed._replace(query=new_query))
        return v
    
    model_config = SettingsConfigDict(env_file=".env")
settings = Settings()
