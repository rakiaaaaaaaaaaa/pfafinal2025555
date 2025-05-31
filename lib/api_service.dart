import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  final String baseUrl = 'http://192.168.100.77:5000';

  Future<String> sendMRIData({
    required double age,
    required String gender,
    required double weight,
    required String filePath,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));

      request.fields['age'] = age.toString();
      request.fields['sex'] = gender;
      request.fields['weight'] = weight.toString();

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();

      String responseStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(responseStr);
          return jsonData['normalized_csa'] != null
              ? ' CSA Normalisée: ${jsonData['normalized_csa']}'
              : ' Réponse: $jsonData';
        } catch (e) {
          return '❌ Erreur de décodage JSON : $e\nRéponse brute : $responseStr';
        }
      } else {
        return '❌ Erreur serveur (${response.statusCode}) : $responseStr';
      }
    } catch (e) {
      return '❌ Exception lors de l\'envoi : ${e.toString()}';
    }
  }
}
