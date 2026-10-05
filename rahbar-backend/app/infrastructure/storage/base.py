from abc import ABC, abstractmethod
from typing import BinaryIO
class StorageService(ABC):
    @abstractmethod
    async def upload_profile_image(self, user_id: str, file: BinaryIO, content_type: str) -> str: pass
    @abstractmethod
    async def delete_profile_image(self, user_id: str) -> bool: pass
