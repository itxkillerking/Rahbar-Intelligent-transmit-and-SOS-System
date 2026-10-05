class RahbarException(Exception): pass

class OtpRateLimitError(RahbarException): pass

class OtpCooldownError(RahbarException): pass

class OtpDeliveryError(RahbarException): pass
