from fastapi import APIRouter
from sqlalchemy import text
from redis.asyncio import from_url

from app.core.config import settings
from app.core.database import engine

router = APIRouter()


@router.get("/health")
async def health_check():
    database_status = "disconnected"
    redis_status = "disconnected"

    # Check PostgreSQL
    try:
        async with engine.connect() as connection:
            await connection.execute(text("SELECT 1"))
            database_status = "connected"
    except Exception as e:
        print(f"Health DB Exception: {e}")
        database_status = "disconnected"

    # Check Redis
    redis_client = from_url(settings.REDIS_URL)

    try:
        await redis_client.ping()
        redis_status = "connected"
    except Exception:
        redis_status = "disconnected"
    finally:
        await redis_client.aclose()

    overall_status = (
        "ok"
        if database_status == "connected"
        and redis_status == "connected"
        else "degraded"
    )

    return {
        "status": overall_status,
        "database": database_status,
        "redis": redis_status,
    }