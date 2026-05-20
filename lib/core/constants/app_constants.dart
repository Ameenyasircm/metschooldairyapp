class AppConstants {
  static const Map<String, List<String>> religionCasteMap = {
    "ISLAM": [
      "MAPPILA",
      "MUSLIM",
      "OTHER"
    ],
    "HINDU": [
      "EZHAVA",
      "NAIR",
      "THIYYA",
      "VISWAKARMA",
      "BRAHMIN",
      "PULAYA",
      "KANAKKAN",
      "VETTUVA",
      "OTHER"
    ],
    "CHRISTIAN": [
      "SYRIAN",
      "LATIN CATHOLIC",
      "RCSC",
      "CSI",
      "PENTECOST",
      "OTHER"
    ],
    "OTHER": ["OTHER"]
  };

  // Dynamically derived from the map keys to avoid manual list duplication
  static List<String> get religions => religionCasteMap.keys.toList();

  static const Map<String, String> feeTypes = {
    "Monthly": "monthly",
    "Installment": "installment",
  };
}