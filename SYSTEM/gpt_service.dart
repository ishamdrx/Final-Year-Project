import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> getTrainingPlan({required String goal}) async {
  const apiUrl = "http://172.18.84.131:5000/generate-plan"; // Local IP

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"prompt": goal}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["response"];
    } else {
      print("Error ${response.statusCode}: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception: $e");
    return null;
  }
}
