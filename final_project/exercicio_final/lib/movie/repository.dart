import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/model.dart';

class MoviesRepository {
  static const String _apiUrl = 'https://ghibliapi.vercel.app/films';

  Future<List<Movie>> fetchMovies() async {
    
    try {
      final response = await http.get(Uri.parse(_apiUrl));

        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          return Movie(
            id: json['id'] ?? '',
            title: json['title'] ?? '',
            image: json['image'] ?? '',
          );
        }).toList();
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }
}
