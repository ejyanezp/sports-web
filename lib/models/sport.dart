class Sport {
  static final String defaultLogoUrl = "default-logo.png";

  String _name;       // key
  String? _logoUrl;    // optional

  String get name => _name;
  String? get logoUrl => _logoUrl;

  void setName(String name) { _name = name; }
  void setLogoId(String? logoUrl) {_logoUrl = logoUrl; }

  Sport({
    required String name,
    String? logoUrl,
  }) : _name = name, _logoUrl = logoUrl?? defaultLogoUrl;

  Sport copyWith({String? name, String? logoUrl}) {
    return Sport(
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'logoUrl': logoUrl,
  };

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      name: json['name'],
      logoUrl: json['logoUrl'],
    );
  }
}