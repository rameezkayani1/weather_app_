import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherServices {
  final String apikey = "e6322b6496a34db6b3e155726241006";
  final String forecastingbasedURL =
      "http://api.weatherapi.com/v1/forecast.json";
  final String SearchbasedUrl = "http://api.weatherapi.com/v1/search.json";

  Future<Map<String, dynamic>> fatchcurrentWehater(String city) async {
    final url =
        '$forecastingbasedURL?key=$apikey&q=$city&days=1&api=no&alerts=no';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Faild to load Weather Api");
    }
  }

  Future<List<dynamic>?> fetchCitysuggestion(String query) async {
    final url = '$SearchbasedUrl?key=$apikey&q=query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
