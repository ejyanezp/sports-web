class Championship {
  static final String defaultLogoUrl = "default-logo.png";

  String _id;          // key
  String _name;        // mandatory
  String _sport;       // mandatory (foreign key to Sport.name)
  String? _scope;      // optional
  String? _logoUrl;    // optional

  String get id => _id;
  String get name => _name;
  String get sport => _sport;
  String? get scope => _scope;
  String? get logoUrl => _logoUrl;

  void setName(String name) => _name = name;
  void setSport(String sport) => _sport = sport;
  void setScope(String? scope) => _scope = scope;
  void setLogoUrl(String? logoUrl) => _logoUrl = logoUrl;

  Championship({
    required String id,
    required String name,
    required String sport,
    String? scope,
    String? logoUrl,
  })  : _id = id,
        _name = name,
        _sport = sport,
        _scope = scope,
        _logoUrl = logoUrl ?? defaultLogoUrl;

  Championship copyWith({
    String? id,
    String? name,
    String? sport,
    String? scope,
    String? logoUrl,
  }) {
    return Championship(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      scope: scope ?? this.scope,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sport': sport,
    'scope': scope,
    'logoUrl': logoUrl,
  };

  factory Championship.fromJson(Map<String, dynamic> json) {
    return Championship(
      id: json['id'],
      name: json['name'],
      sport: json['sport'],
      scope: json['scope'],
      logoUrl: json['logoUrl'],
    );
  }
}