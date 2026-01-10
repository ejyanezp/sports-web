class Sport {
  String _name;       // key
  String? _logoId;    // optional

  String get name => _name;
  String? get logoId => _logoId;

  void setName(String name) { _name = name; }
  void setLogoId(String? logoId) {_logoId = logoId; }

  Sport({
    required String name,
    String? logoId,
  }) : _name = name, _logoId = logoId;

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