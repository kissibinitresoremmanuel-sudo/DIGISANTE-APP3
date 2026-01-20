enum RiskLevel {
  low,
  medium,
  high,
}

class Prediction {
  final RiskLevel riskLevel;
  final String description;
  final DateTime predictionDate;

  // --- AJOUT DES PARAMÈTRES POUR TON IA ---
  final double? temperature;
  final int? spo2;
  final int? bpm;
  final int? age;
  // Tu peux ajouter les autres ici (sexe, toux, etc.)

  Prediction({
    required this.riskLevel,
    required this.description,
    required this.predictionDate,
    this.temperature,
    this.spo2,
    this.bpm,
    this.age,
  });

  // --- CETTE FONCTION TRANSFORME LES DONNÉES POUR TON PYTHON ---
  Map<String, dynamic> toMapPourIA() {
    return {
      "age": age ?? 30, // Valeur par défaut si vide
      "sexe": 1, 
      "fumeur": 0,
      "annees_tabagisme": 0,
      "temperature_corporelle": temperature ?? 37.0,
      "toux": 1,
      "essoufflement": 1,
      "fatigue": 1,
      "douleur_thoracique": 1,
      "frequence_cardiaque": bpm ?? 80,
      "spo2": spo2 ?? 98,
      "temperature_ambiante": 25,
      "humidite": 50,
    };
  }
}
