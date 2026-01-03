class Sport {
  final String name;       // key
  final String? logoId;    // optional

  Sport({
    required this.name,
    this.logoId,
  });

  Sport copyWith({String? name, String? logoId}) {
    return Sport(
      name: name ?? this.name,
      logoId: logoId ?? this.logoId,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'logoId': logoId,
  };

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      name: json['name'],
      logoId: json['logoId'],
    );
  }
}