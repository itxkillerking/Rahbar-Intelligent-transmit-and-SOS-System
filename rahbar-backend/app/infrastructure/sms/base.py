from abc import ABC, abstractmethod
class SmsService(ABC):
    @abstractmethod
    async def send_otp(self, phone_number: str, otp: str) -> bool: pass
    @abstractmethod
    async def send_emergency_message(self, phone_number: str, message: str) -> bool: pass
