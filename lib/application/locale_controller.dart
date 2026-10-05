import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<bool> {
  LocaleNotifier() : super(false) {
    _loadLocale();
  }

  static const _key = 'rahbar_is_urdu';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  void setUrdu(bool isUrdu) async {
    if (kDebugMode) debugPrint('LOCALE: ${state ? "ur" : "en"} → ${isUrdu ? "ur" : "en"}');
    state = isUrdu;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isUrdu);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, bool>((ref) => LocaleNotifier());

class AppStrings {
  static const Map<String, String> _en = {
    'home': 'Home',
    'my_profile': 'My Profile',
    'live_tracking': 'Live Tracking',
    'guardians': 'Guardians / Family Safety',
    'evidence': 'Evidence',
    'settings': 'Settings & Safety',
    'about': 'About RAHBAR',
    'privacy': 'Privacy Policy',
    'information': 'INFORMATION',
    'login_register': 'Login or Register',
    'login_subtitle': 'Enter your phone number to continue',
    'phone_number': 'Phone Number',
    'send_otp': 'Send OTP',
    'enter_otp': 'Enter OTP',
    'verify': 'Verify',
    'resend_otp': 'Resend OTP',
    'complete_profile': 'Complete Profile',
    'personal_information': 'Personal Information',
    'location': 'Location',
    'emergency_contact': 'Emergency Contact',
    'health_information': 'Health Information',
    'professional_information': 'Professional Information',
    'edit_profile': 'Edit Profile',
    'profile_completion': 'Profile Completion',
    'retry': 'Retry',
    'profile_load_error': 'Unable to load your profile',
    'province': 'Province',
    'city': 'City',
    'sending_otp': 'Sending code...',
    'secure_login_msg': 'A 6-digit OTP will be sent to your phone number for secure login or registration.',
    'app_subtitle': 'Intelligent Transit Security and SOS System',
    'app_name': 'The Rahbar',
    'english': 'English',
    'urdu': 'Urdu',
    'logout': 'Logout',
    'account_profile': 'Account & Profile',
    'safety_features': 'Safety Features',
    'developer_tools': 'Developer & Prototype Tools',
    'live_telemetry': 'Live Telemetry',
    'telemetry': 'Telemetry',
    'system_active': 'System Active',
    'fake_call_protection': 'Fake Call Protection',
    'user_profile': 'User Profile',
    'safety_network_ready': 'Safety Network Ready',
    'vault_locked': 'Vault Locked',
    'save_changes': 'Save Changes',
    'save_continue': 'Save & Continue',
    'blood_group': 'Blood Group',
    'medical_conditions': 'Medical Conditions',
    'disability': 'Disability',
    'profession': 'Profession',
    'institute_organization': 'Institute / Organization',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'prefer_not_to_say': 'Prefer not to say',
    'district': 'District',
    'address': 'Address',
    'not_provided': 'Not provided',
  };

  static const Map<String, String> _ur = {
    'home': 'ہوم',
    'my_profile': 'میری پروفائل',
    'live_tracking': 'لائیو ٹریکنگ',
    'guardians': 'سرپرست / خاندانی تحفظ',
    'evidence': 'شواہد',
    'settings': 'ترتیبات اور تحفظ',
    'about': 'رہبر کے بارے میں',
    'privacy': 'رازداری کی پالیسی',
    'information': 'معلومات',
    'login_register': 'لاگ ان / رجسٹر',
    'login_subtitle': 'جاری رکھنے کے لیے اپنا فون نمبر درج کریں',
    'phone_number': 'فون نمبر',
    'send_otp': 'OTP بھیجیں',
    'enter_otp': 'OTP درج کریں',
    'verify': 'تصدیق کریں',
    'resend_otp': 'OTP دوبارہ بھیجیں',
    'complete_profile': 'پروفائل مکمل کریں',
    'personal_information': 'ذاتی معلومات',
    'location': 'مقام',
    'emergency_contact': 'ہنگامی رابطہ',
    'health_information': 'صحت کی معلومات',
    'professional_information': 'پیشہ ورانہ معلومات',
    'edit_profile': 'پروفائل میں ترمیم کریں',
    'profile_completion': 'پروفائل کی تکمیل',
    'retry': 'دوبارہ کوشش کریں',
    'profile_load_error': 'آپ کی پروفائل لوڈ کرنے سے قاصر',
    'province': 'صوبہ',
    'city': 'شہر',
    'sending_otp': 'بھیج رہا ہے...',
    'secure_login_msg': 'محفوظ لاگ ان کے لیے 6 ہندسوں کا OTP بھیجا جائے گا۔',
    'app_subtitle': 'ذہین ٹرانزٹ سیکیورٹی اور ایس او ایس سسٹم',
    'app_name': 'رہبر',
    'english': 'English',
    'urdu': 'اردو',
    'logout': 'لاگ آؤٹ',
    'account_profile': 'اکاؤنٹ اور پروفائل',
    'safety_features': 'حفاظتی خصوصیات',
    'developer_tools': 'ڈیولپر اور پروٹوٹائپ ٹولز',
    'live_telemetry': 'لائیو ٹیلی میٹری',
    'telemetry': 'ٹیلی میٹری',
    'system_active': 'سسٹم ایکٹو',
    'fake_call_protection': 'جعلی کال پروٹیکشن',
    'user_profile': 'صارف کی پروفائل',
    'safety_network_ready': 'سیفٹی نیٹ ورک تیار ہے',
    'vault_locked': 'والٹ لاکڈ',
    'save_changes': 'تبدیلیاں محفوظ کریں',
    'save_continue': 'محفوظ کریں اور جاری رکھیں',
    'blood_group': 'بلڈ گروپ',
    'medical_conditions': 'طبی حالات',
    'disability': 'معذوری',
    'profession': 'پیشہ',
    'institute_organization': 'ادارہ / تنظیم',
    'gender': 'صنف',
    'male': 'مرد',
    'female': 'عورت',
    'other': 'دیگر',
    'prefer_not_to_say': 'بتانا پسند نہیں کروں گا',
    'district': 'ضلع',
    'address': 'پتہ',
    'not_provided': 'فراہم نہیں کیا گیا',
  };

  static String get(bool isUrdu, String key) {
    if (isUrdu) {
      return _ur[key] ?? key;
    }
    return _en[key] ?? key;
  }
}
