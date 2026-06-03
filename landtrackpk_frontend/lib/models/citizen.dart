class Citizen {
  final int? citizenId;
  final String fullName;
  final String cnic;
  final String street;
  final String city;
  final String district;
  final String postalCode;
  final List<String> phones;
  final String role;
  final List<Map<String, dynamic>> properties;

  Citizen({
    this.citizenId,
    required this.fullName,
    required this.cnic,
    this.street = '',
    this.city = '',
    this.district = '',
    this.postalCode = '',
    this.phones = const [],
    this.role = 'Citizen',
    this.properties = const [],
  });

  factory Citizen.fromJson(Map<String, dynamic> json) {
    return Citizen(
      citizenId: json['citizen_id'],
      fullName: json['full_name'] ?? '',
      cnic: json['cnic'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      postalCode: json['postal_code'] ?? '',
      phones: json['phones'] != null
          ? List<String>.from(json['phones'])
          : [],
      role: json['role'] ?? 'Citizen',
      properties: json['properties'] != null
          ? List<Map<String, dynamic>>.from(json['properties'])
          : [],
    );
  }
}
