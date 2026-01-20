import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // L'adresse de ton IA sur Render
  static const String _baseUrl = "https://ia-bronchite-esante.onrender.com/predict";
  
  // Ta clé de sécurité secrète
  static const String _apiKey = "MA_CLE_SUPER_SECURISEE_2026";

  static Future<Map<String, dynamic>> envoyerDonneesIA(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _apiKey, // Ton verrou de sécurité
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Erreur serveur: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Erreur de connexion réseau"};
    }
  }
}
