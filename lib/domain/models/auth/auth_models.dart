class OtpRequestResponse {
  final String message;
  final int expiresIn;
  final int resendAfter;

  OtpRequestResponse({
    required this.message,
    required this.expiresIn,
    required this.resendAfter,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      message: json['message'],
      expiresIn: json['expires_in'],
      resendAfter: json['resend_after'],
    );
  }
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final bool isNewUser;
  final bool profileCompleted;
  final String nextStep;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.isNewUser,
    required this.profileCompleted,
    required this.nextStep,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      isNewUser: json['is_new_user'] ?? false,
      profileCompleted: json['profile_completed'] ?? false,
      nextStep: json['next_step'] ?? 'home',
    );
  }
}

class TokenRefreshResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  TokenRefreshResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
    );
  }
}

class UserProfile {
  final String? id;
  final String phoneNumber;
  final bool phoneVerified;
  final bool profileCompleted;
  final String? fullName;
  final String? username;
  final String? cnic;
  final String? province;
  final String? city;
  
  final String? email;
  final String? gender;
  final String? dateOfBirth;
  final String? district;
  final String? address;
  final String? emergencyContactNumber;
  final String? emergencyContactRelationship;
  final String? bloodGroup;
  final String? profession;
  final String? instituteOrganization;
  
  final String? medicalConditions;
  final String? disability;

  UserProfile({
    this.id,
    required this.phoneNumber,
    required this.phoneVerified,
    required this.profileCompleted,
    this.fullName,
    this.username,
    this.cnic,
    this.province,
    this.city,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.district,
    this.address,
    this.emergencyContactNumber,
    this.emergencyContactRelationship,
    this.bloodGroup,
    this.profession,
    this.instituteOrganization,
    this.medicalConditions,
    this.disability,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString(),
      phoneNumber: json['phone_number'],
      phoneVerified: json['phone_verified'],
      profileCompleted: json['profile_completed'],
      fullName: json['full_name'],
      username: json['username'],
      cnic: json['cnic'],
      province: json['province'],
      city: json['city'],
      email: json['email'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      district: json['district'],
      address: json['address'],
      emergencyContactNumber: json['emergency_contact_number'],
      emergencyContactRelationship: json['emergency_contact_relationship'],
      bloodGroup: json['blood_group'],
      profession: json['profession'],
      instituteOrganization: json['institute_organization'],
      medicalConditions: json['medical_conditions'],
      disability: json['disability'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'phone_number': phoneNumber,
      'phone_verified': phoneVerified,
      'profile_completed': profileCompleted,
      'full_name': fullName,
      'username': username,
      'cnic': cnic,
      'province': province,
      'city': city,
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'district': district,
      'address': address,
      'emergency_contact_number': emergencyContactNumber,
      'emergency_contact_relationship': emergencyContactRelationship,
      'blood_group': bloodGroup,
      'profession': profession,
      'institute_organization': instituteOrganization,
      'medical_conditions': medicalConditions,
      'disability': disability,
    };
  }

  int get completionPercentage {
    int filled = 0;
    int total = 15;

    if (fullName != null && fullName!.trim().isNotEmpty) filled++;
    if (username != null && username!.trim().isNotEmpty) filled++;
    if (cnic != null && cnic!.trim().isNotEmpty) filled++;
    if (province != null && province!.trim().isNotEmpty) filled++;
    if (city != null && city!.trim().isNotEmpty) filled++;

    if (email != null && email!.trim().isNotEmpty) filled++;
    if (gender != null && gender!.trim().isNotEmpty) filled++;
    if (dateOfBirth != null && dateOfBirth!.trim().isNotEmpty) filled++;
    if (district != null && district!.trim().isNotEmpty) filled++;
    if (address != null && address!.trim().isNotEmpty) filled++;
    if (emergencyContactNumber != null && emergencyContactNumber!.trim().isNotEmpty) filled++;
    if (emergencyContactRelationship != null && emergencyContactRelationship!.trim().isNotEmpty) filled++;
    if (bloodGroup != null && bloodGroup!.trim().isNotEmpty) filled++;
    if (profession != null && profession!.trim().isNotEmpty) filled++;
    if (instituteOrganization != null && instituteOrganization!.trim().isNotEmpty) filled++;

    return ((filled / total) * 100).round();
  }
}
