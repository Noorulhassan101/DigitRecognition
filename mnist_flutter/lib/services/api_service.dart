import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService extends ChangeNotifier {
  // Configurable base URL for API. On Vercel this could be your deployed url.
  // Using localhost by default for local development.
  // Note: For Chrome Flutter web, 127.0.0.1 might need to be replaced with localhost or your local IP.
  String baseUrl = "http://127.0.0.1:8000";

  bool isPredicting = false;
  int? predictedDigit;
  List<double>? confidences;
  
  bool isLoadingMetrics = false;
  List<double>? accuracy;
  List<double>? loss;
  List<double>? valAccuracy;
  List<double>? valLoss;
  List<List<int>>? confusionMatrix;
  String? errorMessage;

  ApiService() {
    // Fetch metrics automatically when the service starts
    fetchMetrics();
  }

  void setBaseUrl(String url) {
    baseUrl = url;
    notifyListeners();
  }

  Future<void> predict(String base64Image) async {
    isPredicting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        predictedDigit = data["predicted_digit"];
        confidences = List<double>.from(
          data["confidences"].map((x) => (x as num).toDouble()),
        );
      } else {
        errorMessage = "Prediction failed: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      errorMessage = "Error connecting to server. Is the backend running?";
    } finally {
      isPredicting = false;
      notifyListeners();
    }
  }

  void clearPrediction() {
    predictedDigit = null;
    confidences = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchMetrics() async {
    isLoadingMetrics = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("$baseUrl/metrics"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        accuracy = List<double>.from(data["accuracy"].map((x) => (x as num).toDouble()));
        valAccuracy = List<double>.from(data["val_accuracy"].map((x) => (x as num).toDouble()));
        loss = List<double>.from(data["loss"].map((x) => (x as num).toDouble()));
        valLoss = List<double>.from(data["val_loss"].map((x) => (x as num).toDouble()));
        
        confusionMatrix = [];
        for (var row in data["confusion_matrix"]) {
          confusionMatrix!.add(List<int>.from(row.map((x) => x as int)));
        }
      } else {
         debugPrint("Metrics failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Could not fetch metrics: $e");
    } finally {
      isLoadingMetrics = false;
      notifyListeners();
    }
  }
}
