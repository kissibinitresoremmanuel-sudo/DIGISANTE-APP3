import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prediction_model.dart';
import '../services/api_service.dart'; // Ajout de ton service IA

class PredictionsProvider with ChangeNotifier {
  List<Prediction> _predictions = [];
  bool _isLoading = false;
  String? _lastAnalysisResult; // Pour stocker le résultat de ton IA

  List<Prediction> get predictions => _predictions;
  bool get isLoading => _isLoading;
  String? get lastAnalysisResult => _lastAnalysisResult;

  // 1. Fonction pour récupérer l'historique (Firebase)
  Future<void> fetchPredictions(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('predictions')
          .orderBy('predictionDate', descending: true)
          .get();
      _predictions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Prediction(
          riskLevel: RiskLevel.values[data['riskLevel']],
          description: data['description'],
          predictionDate: (data['predictionDate'] as Timestamp).toDate(),
        );
      }).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. NOUVELLE FONCTION : Analyser avec ton IA et Sauvegarder
  Future<void> analyserEtSauvegarder(String userId, Map<String, dynamic> donneesSante) async {
    _isLoading = true;
    _lastAnalysisResult = null;
    notifyListeners();

    try {
      // ÉTAPE A : Appel de ton IA sur Render via le service que tu as créé
      final resultatIA = await ApiService.envoyerDonneesIA(donneesSante);

      if (resultatIA.containsKey('error')) {
        _lastAnalysisResult = "Erreur : ${resultatIA['error']}";
      } else {
        // ÉTAPE B : Récupération du diagnostic de ton IA
        _lastAnalysisResult = resultatIA['diagnostic']; // Le texte de ton IA

        // ÉTAPE C : Création de l'objet Prediction pour Firebase
        // On détermine le niveau de risque selon le texte (exemple simple)
        RiskLevel niveau = _lastAnalysisResult!.contains('élevé') 
            ? RiskLevel.high 
            : RiskLevel.low;

        final nouvellePrediction = Prediction(
          riskLevel: niveau,
          description: _lastAnalysisResult!,
          predictionDate: DateTime.now(),
        );

        // ÉTAPE D : Sauvegarde automatique dans l'historique Firebase
        await addPrediction(userId, nouvellePrediction);
      }
    } catch (e) {
      _lastAnalysisResult = "Erreur de connexion à l'IA";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Fonction de sauvegarde dans Firebase
  Future<void> addPrediction(String userId, Prediction prediction) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('predictions')
          .add({
            'riskLevel': prediction.riskLevel.index,
            'description': prediction.description,
            'predictionDate': Timestamp.fromDate(prediction.predictionDate),
          });
      _predictions.insert(0, prediction);
    } catch (e) {
      print("Erreur Firebase : $e");
    }
    notifyListeners();
  }
}
