import logging
class SensitiveDataFilter(logging.Filter):
    def filter(self, record):
        if isinstance(record.msg, str):
            sensitive_terms = ["password", "otp", "token", "secret", "bearer"]
            if any(term in record.msg.lower() for term in sensitive_terms):
                record.msg = "*** SENSITIVE DATA REDACTED ***"
        return True
def setup_logging():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    logger = logging.getLogger("rahbar")
    logger.addFilter(SensitiveDataFilter())
    return logger
logger = setup_logging()
