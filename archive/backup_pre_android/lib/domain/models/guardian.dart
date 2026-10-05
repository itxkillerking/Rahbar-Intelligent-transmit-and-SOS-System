class Guardian {
  final String id;
  final String name;
  final String relationship;
  final String phoneNumber;
  final bool isPrimary;
  final bool isVerified;

  Guardian({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.isPrimary = false,
    this.isVerified = false,
  });

  Guardian copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phoneNumber,
    bool? isPrimary,
    bool? isVerified,
  }) {
    return Guardian(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPrimary: isPrimary ?? this.isPrimary,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
