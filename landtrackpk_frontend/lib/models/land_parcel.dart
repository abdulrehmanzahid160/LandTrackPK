class LandParcel {
  final String plotNumber;
  final double area;
  final String areaUnit;
  final String landType;
  final String district;
  final String tehsil;
  final String registeredDate;
  final String? ownerName;
  final String? ownerCnic;
  final String? acquiredDate;
  final List<Map<String, dynamic>> history;

  LandParcel({
    required this.plotNumber,
    required this.area,
    required this.areaUnit,
    required this.landType,
    required this.district,
    required this.tehsil,
    required this.registeredDate,
    this.ownerName,
    this.ownerCnic,
    this.acquiredDate,
    this.history = const [],
  });

  factory LandParcel.fromJson(Map<String, dynamic> json) {
    return LandParcel(
      plotNumber: json['plot_number'] ?? '',
      area: (json['area'] ?? 0).toDouble(),
      areaUnit: json['area_unit'] ?? '',
      landType: json['land_type'] ?? '',
      district: json['district'] ?? '',
      tehsil: json['tehsil'] ?? '',
      registeredDate: json['registered_date'] ?? '',
      ownerName: json['owner_name'],
      ownerCnic: json['owner_cnic'],
      acquiredDate: json['acquired_date'],
      history: json['history'] != null
          ? List<Map<String, dynamic>>.from(json['history'])
          : [],
    );
  }
}
