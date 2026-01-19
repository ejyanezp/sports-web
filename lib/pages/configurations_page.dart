import 'package:flutter/material.dart';

class ConfigurationsPage extends StatefulWidget {
  const ConfigurationsPage({super.key});

  @override
  State<ConfigurationsPage> createState() => _ConfigurationsPageState();
}

class _ConfigurationsPageState extends State<ConfigurationsPage> {
  // ---- Mocked user state ----
  String alias = "Pedro"; // Alias original, inmutable
  String language = "en";
  String? selectedCountryCode = "ES";
  String aliasSuffix = "";
  int selectedAvatarSeed = 0;

  int iconIndex = 0;
  int iconColorIndex = 0;
  int bgColorIndex = 0;

  // ---- Historial (mock) ----
  final List<PublicNameHistoryEntry> publicNameHistory = [
    PublicNameHistoryEntry(publicName: "ES.Pedro", from: DateTime(2024, 1, 1), to: DateTime(2024, 6, 1)),
    PublicNameHistoryEntry(publicName: "US.Pedro1", from: DateTime(2024, 6, 1), to: DateTime(2024, 9, 1)),
    PublicNameHistoryEntry(publicName: "MX.Pedro", from: DateTime(2024, 9, 1), to: DateTime(2024, 12, 1)),
    PublicNameHistoryEntry(publicName: "CA.Pedro_can", from: DateTime(2024, 12, 1), to: null),
  ];

  // ---- Catálogos ----
  final List<Map<String, String>> supportedLanguages = [
    {"code": "en", "label": "English", "flag": "🇺🇸"},
    {"code": "es", "label": "Español", "flag": "🇪🇸"},
    {"code": "pt", "label": "Português", "flag": "🇧🇷"},
    {"code": "de", "label": "Deutsch", "flag": "🇩🇪"},
    {"code": "fr", "label": "Français", "flag": "🇫🇷"},
    {"code": "it", "label": "Italiano", "flag": "🇮🇹"},
  ];

  final List<Map<String, String>> countries = [
    {"code": "ES", "name": "Spain", "flag": "🇪🇸"},
    {"code": "US", "name": "United States", "flag": "🇺🇸"},
    {"code": "MX", "name": "Mexico", "flag": "🇲🇽"},
    {"code": "CA", "name": "Canada", "flag": "🇨🇦"},
    {"code": "BR", "name": "Brazil", "flag": "🇧🇷"},
    {"code": "AR", "name": "Argentina", "flag": "🇦🇷"},
  ];

  // ---- Mock de validación ----
  Future<PublicNameValidationResult> validatePublicName(String countryCode, String alias, String suffix) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final base = "$countryCode.$alias";
    final candidate = suffix.isEmpty ? base : "$base$suffix";

    const taken = {"US.Pedro", "US.Pedro1", "ES.Pedro", "ES.Pedro_Rod"};

    final isTaken = taken.contains(candidate);

    String? suggestion;
    if (isTaken) {
      int n = 1;
      while (taken.contains("$base$n")) {
        n++;
      }
      suggestion = "$base$n";
    }

    return PublicNameValidationResult(candidate: candidate, isTaken: isTaken, suggestion: suggestion);
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF21262D);

    return Container(
      color: background,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildLanguageSection(),
          const SizedBox(height: 32),

          _buildAvatarSection(),
          const SizedBox(height: 32),

          _buildPublicNameSection(),
          const SizedBox(height: 32),

          _buildPublicNameHistorySection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return AvatarConfigurator(
      iconIndex: iconIndex,
      iconColorIndex: iconColorIndex,
      bgColorIndex: bgColorIndex,
      onChanged: (icon, iconColor, bgColor) {
        setState(() {
          iconIndex = icon;
          iconColorIndex = iconColor;
          bgColorIndex = bgColor;
        });
      },
    );
  }

  // ---------------- LANGUAGE ----------------

  Widget _buildLanguageSection() {
    const selectedBg = Color(0xFF238636); // gris oscuro Coinbase
    const unselectedBg = Color(0xFF1F2937);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Language", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: supportedLanguages.map((lang) {
            final isSelected = language == lang["code"];
            return GestureDetector(
              onTap: () => setState(() => language = lang["code"]!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBg : unselectedBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? selectedBg : Colors.grey[300]!, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lang["flag"]!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      lang["label"]!,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------- PUBLIC NAME ----------------

  Widget _buildPublicNameSection() {
    final country = countries.firstWhere((c) => c["code"] == selectedCountryCode, orElse: () => countries.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Public name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),

        _buildReadOnlyField("Alias", alias),
        const SizedBox(height: 16),

        _buildCountrySelector(),
        const SizedBox(height: 16),

        _buildSuffixField(),
        const SizedBox(height: 16),

        if (selectedCountryCode != null)
          FutureBuilder<PublicNameValidationResult>(
            future: validatePublicName(selectedCountryCode!, alias, aliasSuffix),
            builder: (context, snapshot) {
              final base = "${selectedCountryCode!}.$alias";
              final candidate = aliasSuffix.isEmpty ? base : "$base$aliasSuffix";

              if (!snapshot.hasData) {
                return _buildPublicNamePreview(flag: country["flag"]!, publicName: candidate, loading: true);
              }

              final result = snapshot.data!;
              return _buildPublicNamePreview(
                flag: country["flag"]!,
                publicName: result.candidate,
                loading: false,
                isTaken: result.isTaken,
                suggestion: result.suggestion,
              );
            },
          ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black, // const Color(0xFFFDFDFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(value, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildCountrySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Country", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black, // const Color(0xFFFDFDFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCountryCode,
              items: countries.map((c) {
                return DropdownMenuItem(
                  value: c["code"],
                  child: Row(
                    children: [
                      Text(c["flag"]!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(c["name"]!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCountryCode = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuffixField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Alias suffix (optional)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: "_can, 1, _mx, etc.",
            filled: true,
            fillColor: Colors.black, // const Color(0xFFFDFDFE),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
          ),
          onChanged: (value) => setState(() => aliasSuffix = value.trim()),
        ),
      ],
    );
  }

  Widget _buildPublicNamePreview({
    required String flag,
    required String publicName,
    bool loading = false,
    bool isTaken = false,
    String? suggestion,
  }) {
    final hasError = isTaken;
    final bgColor = hasError ? Colors.red[50] : Colors.blue[50];
    final iconColor = hasError ? Colors.red : Colors.blue;
    final textColor = hasError ? Colors.red[900] : Colors.blue[900];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Preview", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              if (loading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(hasError ? Icons.error_outline : Icons.check_circle_outline, color: iconColor),
              const SizedBox(width: 12),
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                publicName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
              ),
            ],
          ),
        ),

        if (hasError && suggestion != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange),
              const SizedBox(width: 6),
              Expanded(
                child: Text("This public name is already taken. Suggested: $suggestion", style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ---------------- HISTORY ----------------

  Widget _buildPublicNameHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Public name history", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.black,  // const Color(0xFFFDFDFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: publicNameHistory.map((entry) {
              final isCurrent = entry.to == null;
              final period = _formatPeriod(entry.from, entry.to);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: entry == publicNameHistory.last ? Colors.transparent : Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 16,
                      color: isCurrent ? Colors.blue : Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.publicName, style: TextStyle(fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    Text(period, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _formatPeriod(DateTime from, DateTime? to) {
    String format(DateTime d) => "${_monthShort(d.month)} ${d.year}";
    final fromStr = format(from);
    final toStr = to == null ? "Present" : format(to);
    return "$fromStr – $toStr";
  }

  String _monthShort(int m) {
    const names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return names[m - 1];
  }
}

// ---------------- MODELOS ----------------

class PublicNameHistoryEntry {
  final String publicName;
  final DateTime from;
  final DateTime? to;

  PublicNameHistoryEntry({required this.publicName, required this.from, required this.to});
}

class PublicNameValidationResult {
  final String candidate;
  final bool isTaken;
  final String? suggestion;

  PublicNameValidationResult({required this.candidate, required this.isTaken, required this.suggestion});
}

// ---------------- AVATAR CONFIGURATOR ----------------

class AvatarConfigurator extends StatefulWidget {
  final int iconIndex;
  final int iconColorIndex;
  final int bgColorIndex;
  final Function(int icon, int iconColor, int bgColor) onChanged;

  const AvatarConfigurator({
    super.key,
    required this.iconIndex,
    required this.iconColorIndex,
    required this.bgColorIndex,
    required this.onChanged,
  });

  @override
  State<AvatarConfigurator> createState() => _AvatarConfiguratorState();
}

class _AvatarConfiguratorState extends State<AvatarConfigurator> {
  late int iconIndex;
  late int iconColorIndex;
  late int bgColorIndex;

  final icons = [
    Icons.emoji_events_outlined,
    Icons.star_outline,
    Icons.shield_outlined,
    Icons.sports_soccer,
    Icons.sports_basketball,
    Icons.sports_baseball,
    Icons.sports_football,
    Icons.rocket_launch_outlined,
    Icons.bolt_outlined,
    Icons.track_changes_outlined,
  ];

  final iconColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
    Colors.pink,
  ];

  final bgColors = [
    Color(0xFFBBDEFB), // azul claro saturado
    Color(0xFFC8E6C9), // verde claro saturado
    Color(0xFFFFE0B2), // naranja claro saturado
    Color(0xFFE1BEE7), // violeta claro saturado
    Color(0xFFFFCDD2), // rojo claro saturado
    Color(0xFFB2DFDB), // teal claro saturado
    Color(0xFFD1C4E9), // púrpura suave saturado
    Color(0xFFFFF9C4), // amarillo suave saturado
    Color(0xFFB3E5FC), // celeste saturado
    Color(0xFFF8BBD0), // rosa saturado
  ];

  @override
  void initState() {
    super.initState();
    iconIndex = widget.iconIndex;
    iconColorIndex = widget.iconColorIndex;
    bgColorIndex = widget.bgColorIndex;
  }

  void _update() {
    widget.onChanged(iconIndex, iconColorIndex, bgColorIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Usamos Flexible para que en pantallas pequeñas se encoja
        Flexible(
          child: ConstrainedBox(
            // Definimos el ancho ideal de tus selectores
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Avatar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Text("Icon", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                _buildIconSelector(),
                const SizedBox(height: 24),
                const Text("Icon color", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                _buildColorSelector(iconColors, (i) {
                  setState(() => iconColorIndex = i);
                  _update();
                }),
                const SizedBox(height: 24),
                const Text("Background color", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                _buildColorSelector(bgColors, (i) {
                  setState(() => bgColorIndex = i);
                  _update();
                }),
              ],
            ),
          ),
        ),
        // Preview
        SizedBox(
          width: 80, // ancho fijo para evitar que flote
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: bgColors[bgColorIndex],
                child: Icon(icons[iconIndex], size: 36, color: iconColors[iconColorIndex]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: icons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final isSelected = i == iconIndex;
          return GestureDetector(
            onTap: () {
              setState(() => iconIndex = i);
              _update();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!, width: 1.5),
              ),
              child: Icon(icons[i], size: 28, color: iconColors[iconColorIndex]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector(List<Color> colors, Function(int) onTap) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
          );
        },
      ),
    );
  }
}
