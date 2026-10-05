from app.core.redis import redis_client


class RateLimiter:
    def __init__(self, requests: int, window: int):
        self.requests = requests
        self.window = window

    async def check(self, identifier: str) -> bool:
        key = f"rate_limit:{identifier}"

        current = await redis_client.incr(key)

        if current == 1:
            await redis_client.expire(key, self.window)

        return current <= self.requests